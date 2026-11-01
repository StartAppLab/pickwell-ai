import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../../config/_config.dart';
import '../../../../core/_core.dart';
import '../../../../resources/assets.gen.dart';
import '../../../app/app.dart';
import '../../../onboarding/onboarding.dart';
import '../blocs/_blocs.dart';
import 'social_auth_button.dart';

class SocialSignInWidget extends StatefulWidget {
  const SocialSignInWidget({
    super.key,
    this.showSkip = false,
    this.showCreateAccount = false,
    this.onboarding = false,
    this.isActive = true,
  });

  final bool showSkip;
  final bool showCreateAccount;
  final bool onboarding;
  final bool isActive;

  @override
  State<SocialSignInWidget> createState() => _SocialSignInWidgetState();
}

class _SocialSignInWidgetState extends State<SocialSignInWidget> {
  late final AppSession _session = getIt<AppSession>();
  bool _busy = false;
  bool _completionAttempted = false;

  @override
  void initState() {
    super.initState();
    _session.addListener(_checkAuthentication);
    _checkAuthentication();
  }

  @override
  void didUpdateWidget(SocialSignInWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _checkAuthentication();
  }

  @override
  void dispose() {
    _session.removeListener(_checkAuthentication);
    super.dispose();
  }

  void _checkAuthentication() {
    if (!widget.onboarding ||
        !widget.isActive ||
        !_session.hasAuthenticatedUi ||
        _session.recoveringPassword ||
        _completionAttempted) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          !widget.isActive ||
          _busy ||
          _completionAttempted ||
          !_session.hasAuthenticatedUi ||
          _session.recoveringPassword) {
        return;
      }
      _completionAttempted = true;
      // Email auth can be pushed above this page. Reveal onboarding so a failed
      // completion write leaves its retry action visible.
      if (ModalRoute.of(context)?.isCurrent != true) {
        context.goNamed(AppRouter.onboardingRoute);
      }
      _run(_finishOnboarding);
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  @override
  Widget build(BuildContext context) {
    final features = getIt<AppConfig>().features;
    final spacing = context.themeData.dimensionsData;
    return BlocListener<SignInCubit, SignInState>(
      bloc: getIt<SignInCubit>(),
      listenWhen: (previous, current) =>
          previous.maybeWhen(idle: (_, _, _, _, error) => error, orElse: () => null) !=
          current.maybeWhen(idle: (_, _, _, _, error) => error, orElse: () => null),
      listener: (context, state) {
        final error = state.maybeWhen(idle: (_, _, _, _, error) => error, orElse: () => null);
        if (error?.isNotEmpty ?? false) AppWidgets.showErrorSnackBar(context, error!);
      },
      child: BlocSelector<SignInCubit, SignInState, bool>(
        bloc: getIt<SignInCubit>(),
        selector: (state) =>
            state.maybeWhen(idle: (_, _, _, loading, _) => loading, orElse: () => true),
        builder: (context, socialBusy) {
          final busy = _busy || socialBusy;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.onboarding && _session.hasAuthenticatedUi)
                ElevatedButton(
                  onPressed: busy ? null : () => _run(_finishOnboarding),
                  child: Text(context.l10n.continueButton),
                )
              else if (features.authEnabled) ...[
                // Keep the branded Apple appearance; Supabase owns the OAuth flow.
                if (features.appleSignInEnabled) ...[
                  AbsorbPointer(
                    absorbing: busy,
                    child: Opacity(
                      opacity: busy ? 0.5 : 1,
                      child: SignInWithAppleButton(
                        style: SignInWithAppleButtonStyle.black,
                        text: context.l10n.signInWithProvider(context.l10n.apple),
                        height: spacing.buttonHeight,
                        borderRadius: BorderRadius.circular(spacing.cornerRadius),
                        onPressed: () => _run(() => _social(getIt<SignInCubit>().signInWithApple)),
                      ),
                    ),
                  ),
                  Gap(spacing.smallSpacing),
                ],
                if (features.googleSignInEnabled) ...[
                  SocialAuthButton(
                    text: context.l10n.signInWithProvider(context.l10n.google),
                    image: AppAssets.icons.icGoogle.svg(width: 24, height: 24),
                    style: SocialAuthButtonStyle.whiteOutlined,
                    height: spacing.buttonHeight,
                    borderRadius: BorderRadius.circular(spacing.cornerRadius),
                    onPressed: busy
                        ? null
                        : () => _run(() => _social(getIt<SignInCubit>().signInWithGoogle)),
                  ),
                  Gap(spacing.smallSpacing),
                ],
                SocialAuthButton(
                  text: context.l10n.continueWithEmail,
                  icon: Icons.mail_outline,
                  style: SocialAuthButtonStyle.whiteOutlined,
                  height: spacing.buttonHeight,
                  borderRadius: BorderRadius.circular(spacing.cornerRadius),
                  onPressed: busy ? null : () => _run(() => _email(AppRouter.signInRoute)),
                ),
              ],
              if (kDebugMode && features.authEnabled && !_session.hasAuthenticatedUi) ...[
                Gap(spacing.smallSpacing),
                OutlinedButton(
                  onPressed: busy ? null : () => _run(_skipSignInForDebug),
                  child: const Text('[DEV] Skip Sign In'),
                ),
              ],
              if (widget.showSkip &&
                  features.authMode == AuthMode.optional &&
                  !_session.isAuthenticated) ...[
                const Gap(32),
                _footer(
                  context.l10n.signInLaterPrompt,
                  context.l10n.skipButton,
                  busy ? null : () => _run(_finishOnboarding),
                ),
              ],
              if (busy) ...[
                Gap(spacing.smallSpacing),
                const Center(child: CircularProgressIndicator()),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _footer(String text, String action, VoidCallback? onTap) {
    return Semantics(
      button: true,
      enabled: onTap != null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Text.rich(
            TextSpan(
              text: '$text ',
              children: [
                TextSpan(
                  text: action,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } catch (_) {
      if (mounted) AppWidgets.showErrorSnackBar(context, context.l10n.authContinueError);
    } finally {
      if (mounted) {
        setState(() => _busy = false);
        _checkAuthentication();
      }
    }
  }

  Future<void> _saveAnswers() async {
    if (widget.onboarding) await getIt<OnboardingCubit>().save();
  }

  Future<void> _email(String route) async {
    await _saveAnswers();
    if (!mounted) return;
    // Navigation itself is synchronous; do not hold the busy state until pop.
    context
        .pushNamed(
          route,
          queryParameters: {
            if (route == AppRouter.signInRoute && !widget.showCreateAccount)
              'showCreateAccount': 'false',
          },
        )
        .then((_) {
          if (mounted) _checkAuthentication();
        });
  }

  Future<void> _social(Future<void> Function() signIn) async {
    await _saveAnswers();
    if (mounted) await signIn();
  }

  Future<void> _skipSignInForDebug() async {
    if (!kDebugMode || _session.recoveringPassword) return;
    _session.enableDebugGuestMode();
    if (widget.onboarding) {
      _completionAttempted = true;
      await _finishOnboarding();
    } else if (mounted) {
      context.goNamed(
        AppFlowResolver.afterAuthentication(
          features: getIt<AppConfig>().features,
          onboardingCompleted: _session.onboardingCompleted,
        ),
      );
    }
  }

  Future<void> _finishOnboarding() async {
    final features = getIt<AppConfig>().features;
    if (!widget.onboarding ||
        _session.recoveringPassword ||
        (features.authMode == AuthMode.required && !_session.hasAuthenticatedUi)) {
      return;
    }
    await _saveAnswers();
    // Saving can yield while auth changes (including a recovery link).
    if (_session.recoveringPassword ||
        (features.authMode == AuthMode.required && !_session.hasAuthenticatedUi)) {
      return;
    }
    await _session.completeOnboarding();
    final destination = await AppFlowResolver.resolve();
    if (!mounted ||
        _session.recoveringPassword ||
        (features.authMode == AuthMode.required && !_session.hasAuthenticatedUi)) {
      return;
    }
    context.go(AppFlowResolver.takeLocation(destination));
  }
}
