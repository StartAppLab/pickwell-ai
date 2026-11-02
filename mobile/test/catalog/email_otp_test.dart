import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import '../../lib/src/config/theme/_theme.dart';
import '../../lib/src/config/app_features.dart';
import '../../lib/src/config/router/consumer_route_policy.dart';
import '../../lib/src/core/errors/_errors.dart';
import '../../lib/src/features/auth/domain/repositories/email_otp_repository.dart';
import '../../lib/src/features/auth/domain/use_cases/email_otp_use_case.dart';
import '../../lib/src/features/auth/presentation/blocs/email_otp/email_otp_cubit.dart';
import '../../lib/src/features/auth/presentation/views/email_otp_gate_view.dart';
import '../../lib/src/features/catalog/domain/_domain.dart';
import '../../lib/src/features/catalog/presentation/views/capture_entry_view.dart';
import '../../lib/src/features/catalog/presentation/blocs/catalog/label_capture_cubit.dart';
import '../../lib/src/localization/l10n/app_localizations.dart';
import 'label_capture_test.dart' show DraftMedia, photo, pngFixture;

class OtpFixture extends EmailOtpRepository {
  int cooldown = 0, sends = 0, verifies = 0, checks = 0;
  bool authorized = false;
  String? failure;
  Completer<Either<Failure, bool>>? pending;
  @override
  int get resendAfter => cooldown;
  Either<Failure, bool> result(bool value) => failure == null
      ? Right(value)
      : Left(
          ServerFailure(
            error: DataError(stackTrace: 'fixture', statusCode: failure),
          ),
        );
  @override
  Future<Either<Failure, bool>> authorize() async {
    checks++;
    return result(authorized);
  }

  @override
  Future<Either<Failure, bool>> send(String email) async {
    sends++;
    if (pending != null) return pending!.future;
    if (cooldown > 0) {
      return Left(
        ServerFailure(
          error: const DataError(stackTrace: 'fixture', statusCode: 'rate_limited'),
        ),
      );
    }
    cooldown = 60;
    return result(true);
  }

  @override
  Future<Either<Failure, bool>> verify(String email, String code) async {
    verifies++;
    return pending?.future ?? result(true);
  }
}

void main() {
  test('guest check requires email while existing backend-authorized identity resumes', () async {
    for (final authorized in [false, true]) {
      final repository = OtpFixture()..authorized = authorized;
      final cubit = EmailOtpCubit(EmailOtpUseCase(repository));
      await cubit.check();
      expect(cubit.state.phase, authorized ? EmailOtpPhase.authorized : EmailOtpPhase.email);
      expect(repository.sends, 0);
      await cubit.close();
    }
  });
  test('send validates email, trims input and prevents duplicate requests while pending', () async {
    final repository = OtpFixture(), cubit = EmailOtpCubit(EmailOtpUseCase(OtpFixture()));
    final gate = EmailOtpCubit(EmailOtpUseCase(repository));
    await gate.check();
    await gate.send('bad');
    expect(repository.sends, 0);
    repository.pending = Completer();
    final send = gate.send(' fixture@example.invalid ');
    await gate.send('fixture@example.invalid');
    expect(repository.sends, 1);
    repository.pending!.complete(const Right(true));
    await send;
    expect(gate.state.email, 'fixture@example.invalid');
    expect(gate.state.phase, EmailOtpPhase.code);
    await gate.close();
    await cubit.close();
  });
  test(
    'six/eight-digit codes verify; malformed/incorrect/expired errors remain recoverable',
    () async {
      final repository = OtpFixture(), gate = EmailOtpCubit(EmailOtpUseCase(OtpFixture()));
      final cubit = EmailOtpCubit(EmailOtpUseCase(repository));
      await cubit.check();
      await cubit.send('fixture@example.invalid');
      for (final invalid in ['123', 'abcdef', '1234567']) {
        await cubit.verify(invalid);
      }
      expect(repository.verifies, 0);
      repository.failure = 'invalid_code';
      await cubit.verify('123456');
      expect(cubit.state.error, 'invalid_code');
      expect(cubit.state.phase, EmailOtpPhase.code);
      repository.failure = null;
      await cubit.verify('12345678');
      expect(cubit.state.phase, EmailOtpPhase.authorized);
      expect(repository.verifies, 2);
      await cubit.close();
      await gate.close();
    },
  );
  testWidgets('resend cooldown survives changing email and clears at the allowed time', (
    tester,
  ) async {
    final repository = OtpFixture(), cubit = EmailOtpCubit(EmailOtpUseCase(OtpFixture()));
    final gate = EmailOtpCubit(EmailOtpUseCase(repository));
    await gate.check();
    await gate.send('fixture@example.invalid');
    expect(gate.state.resendAfter, 60);
    gate.changeEmail();
    expect(gate.state.resendAfter, 60);
    repository.cooldown = 0;
    await tester.pump(const Duration(seconds: 1));
    expect(gate.state.resendAfter, 0);
    await gate.send('other@example.invalid');
    expect(repository.sends, 2);
    await gate.close();
    await cubit.close();
  });
  testWidgets('reopened email gate resumes countdown for the previous attempt', (tester) async {
    final repository = OtpFixture()..cooldown = 60;
    final gate = EmailOtpCubit(EmailOtpUseCase(repository));
    await gate.check();
    expect(gate.state.resendAfter, 60);
    repository.cooldown = 0;
    await tester.pump(const Duration(seconds: 1));
    expect(gate.state.resendAfter, 0);
    await gate.close();
  });
  test('network/authorization failures do not claim successful verification', () async {
    final repository = OtpFixture()..failure = 'unavailable';
    final cubit = EmailOtpCubit(EmailOtpUseCase(repository));
    await cubit.check();
    expect(cubit.state.error, 'unavailable');
    expect(cubit.state.phase, EmailOtpPhase.email);
    repository.failure = null;
    await cubit.send('fixture@example.invalid');
    repository.failure = 'unavailable';
    await cubit.verify('12345678');
    expect(cubit.state.phase, EmailOtpPhase.code);
    expect(cubit.state.error, 'unavailable');
    await cubit.close();
  });
  test('closed route drops a pending completion', () async {
    final repository = OtpFixture()..pending = Completer();
    final cubit = EmailOtpCubit(EmailOtpUseCase(repository));
    await cubit.check();
    final send = cubit.send('fixture@example.invalid');
    await cubit.close();
    repository.pending!.complete(const Right(true));
    await send;
    expect(cubit.isClosed, true);
  });
  test(
    'optional-auth session refresh leaves contribution gate and guest lookup routes in place',
    () {
      for (final authenticated in [false, true]) {
        for (final path in [
          '/capture-auth/00000096385074',
          '/capture/00000096385074',
          '/scan',
          '/home',
        ]) {
          expect(
            ConsumerRoutePolicy.redirect(
              features: const AppFeatures(authMode: AuthMode.optional),
              isAuthenticated: authenticated,
              recoveringPassword: false,
              onboardingCompleted: true,
              path: path,
            ),
            isNull,
          );
        }
      }
    },
  );
  for (final cancel in [true, false]) {
    testWidgets(
      'Analyze opens OTP only after photos; ${cancel ? 'cancel' : 'verify'} returns identical review',
      (tester) async {
        final dir = (await tester.runAsync(() => Directory.systemTemp.createTemp('otp_widget_')))!;
        final file = (await tester.runAsync(() => pngFixture(dir)))!;
        final repository = OtpFixture(), media = DraftMedia()..next = photo(file.path);
        final draft = LabelCaptureCubit(CaptureLabelUseCase(media));
        await draft.begin('96385074');
        await draft.capture(LabelKind.nutrition);
        await draft.capture(LabelKind.ingredients);
        final before = draft.state;
        final gate = EmailOtpCubit(EmailOtpUseCase(repository));
        final router = GoRouter(
          initialLocation: '/capture',
          routes: [
            GoRoute(
              path: '/capture',
              builder: (_, _) => BlocProvider.value(
                value: draft,
                child: const CaptureEntryView(barcode: '00000096385074'),
              ),
            ),
            GoRoute(
              path: '/capture-auth/:barcode',
              builder: (_, _) => BlocProvider.value(
                value: gate,
                child: const EmailOtpGateView(barcode: '00000096385074'),
              ),
            ),
          ],
        );
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
            theme: AppTheme.lightTheme(AppColorScheme.lightColorScheme),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Continue with Email'), findsNothing);
        expect(repository.sends, 0);
        await tester.scrollUntilVisible(find.text('Analyze Product'), 180);
        await tester.tap(find.text('Analyze Product'));
        await gate.check();
        await tester.pumpAndSettle();
        expect(find.text('Continue with Email'), findsOneWidget);
        await tester.enterText(find.byType(TextField), 'fixture@example.invalid');
        await tester.tap(find.text('Send Code'));
        await tester.pumpAndSettle();
        if (cancel) {
          await tester.tap(find.text('Cancel'));
        } else {
          await tester.enterText(find.byType(TextField), '12345678');
          await tester.tap(find.text('Verify'));
        }
        await tester.pumpAndSettle();
        expect(draft.state, same(before));
        expect(draft.state.ready, true);
        expect(find.text('Continue with Email'), findsNothing);
        if (!cancel) expect(find.textContaining('Email verified.'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        router.dispose();
        await gate.close();
        await draft.close();
        await tester.runAsync(() => dir.delete(recursive: true));
      },
    );
  }
}
