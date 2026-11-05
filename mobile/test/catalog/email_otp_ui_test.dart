import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/features/auth/domain/use_cases/email_otp_use_case.dart';
import '../../lib/src/features/auth/presentation/blocs/email_otp/email_otp_cubit.dart';
import '../../lib/src/features/auth/presentation/views/email_otp_gate_view.dart';
import 'email_otp_test.dart' show OtpFixture;
import 'ui_polish_test.dart' show host, snapshot;

void main() {
  setUpAll(() async {
    await (FontLoader(
      'Manrope',
    )..addFont(rootBundle.load('assets/fonts/Manrope/Manrope-Regular.ttf'))).load();
    await (FontLoader(
      'packages/cupertino_icons/CupertinoIcons',
    )..addFont(rootBundle.load('packages/cupertino_icons/assets/CupertinoIcons.ttf'))).load();
  });

  for (final dark in [false, true]) {
    for (final size in [const Size(320, 690), const Size(780, 360)]) {
      testWidgets('email and code recovery fit $size, large text, keyboard, dark=$dark', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = size;
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        final repository = OtpFixture();
        final gate = EmailOtpCubit(EmailOtpUseCase(repository));
        await gate.check();
        await tester.pumpWidget(
          host(
            BlocProvider.value(
              value: gate,
              child: const EmailOtpGateView(barcode: '00000096385074'),
            ),
            dark: dark,
            scale: 2,
            keyboard: size.height > 400 ? 260 : 120,
          ),
        );
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.byType(TextField),
          100,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.enterText(find.byType(TextField), 'fixture@example.invalid');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
        expect(repository.sends, 1);
        expect(gate.state.phase, EmailOtpPhase.code);
        await tester.scrollUntilVisible(
          find.byType(TextField),
          100,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.enterText(find.byType(TextField), '12');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
        expect(repository.verifies, 0);
        expect(find.byType(Semantics), findsWidgets);
        await tester.scrollUntilVisible(
          find.text('Change email'),
          100,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(find.text('Change email'));
        await tester.pumpAndSettle();
        expect(gate.state.phase, EmailOtpPhase.email);
        await tester.scrollUntilVisible(
          find.text('Cancel'),
          100,
          scrollable: find.byType(Scrollable).first,
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        await gate.close();
      });
    }
  }

  testWidgets('email and code presentation retain cooldown and readable error recovery', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final repository = OtpFixture();
    final gate = EmailOtpCubit(EmailOtpUseCase(repository));
    await gate.check();
    final key = GlobalKey();
    await tester.pumpWidget(
      host(
        RepaintBoundary(
          key: key,
          child: BlocProvider.value(
            value: gate,
            child: const EmailOtpGateView(barcode: '00000096385074'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await snapshot(tester, key, 'email-polished');
    await tester.enterText(find.byType(TextField), 'fixture@example.invalid');
    await tester.tap(find.widgetWithText(FilledButton, 'Send Code'));
    await tester.pumpAndSettle();
    expect(find.text('Check your email'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).autofillHints,
      contains(AutofillHints.oneTimeCode),
    );
    final resend = find.byWidgetPredicate(
      (widget) =>
          widget is TextButton &&
          widget.child is Text &&
          ((widget.child! as Text).data?.contains('60s') ?? false),
    );
    expect(resend, findsOneWidget);
    expect(tester.widget<TextButton>(resend).onPressed, isNull);
    await snapshot(tester, key, 'otp-polished');
    await tester.enterText(find.byType(TextField), '12');
    await tester.tap(find.text('Verify'));
    await tester.pumpAndSettle();
    final message = find.byWidgetPredicate(
      (widget) => widget is Semantics && widget.properties.liveRegion == true,
    );
    expect(message, findsOneWidget);
    await tester.ensureVisible(message);
    await snapshot(tester, key, 'otp-error-polished');
    expect(repository.verifies, 0);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await gate.close();
  });
}
