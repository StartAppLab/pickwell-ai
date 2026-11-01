import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/_config.dart';
import '../../../../core/_core.dart';
import '../../../../resources/_resources.dart';
import '../../../app/app.dart';
import '../blocs/_blocs.dart';
import '../widgets/_widgets.dart';

class SignInView extends StatefulWidget {
  const SignInView({super.key, this.showCreateAccount = true});

  final bool showCreateAccount;

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    context.read<SignInCubit>().setErrorText(null);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MaterialAppBar(leading: context.canPop() ? null : const SizedBox.shrink()),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: BlocListener<SignInCubit, SignInState>(
          listener: (context, state) {
            state.whenOrNull(
              success: () {
                _clearTextFields();
                // AppSession and the router preserve the requested destination.
              },
              error: (error) {
                var message = context.l10n.errorServerAccess;
                if (error.message?.isNotEmpty ?? false) {
                  message = error.message!;
                }
                context.read<SignInCubit>().setErrorText(message);
              },
            );
          },
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: context.themeData.edgeInsetsData.pagePadding,
                  child: Column(
                    children: [
                      // Sign In Image
                      AppAssets.images.appIcon.image(height: 100),
                      Gap(context.themeData.dimensionsData.smallSpacing),
                      // Sign In Title
                      Text(
                        context.l10n.signInTitle,
                        textAlign: TextAlign.center,
                        style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Gap(context.themeData.dimensionsData.smallSpacing),
                      // Sign In Description
                      Text(
                        context.l10n.signInDesc,
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Gap(context.themeData.dimensionsData.mediumSpacing),
                      // Email Text Field
                      SignInEmailTextField(
                        controller: _emailController,
                        focusNode: _emailFocusNode,
                      ),
                      Gap(context.themeData.dimensionsData.smallSpacing),
                      // Password Text Field
                      SignInPasswordTextField(
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                      ),
                      Gap(context.themeData.dimensionsData.mediumSpacing),
                      // Forgot Password Button
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _navigateToForgotPassword,
                          child: Text(context.l10n.forgotPassword),
                        ),
                      ),
                      // Error Text
                      BlocSelector<SignInCubit, SignInState, String?>(
                        selector: (state) {
                          if (state is SignInStateIdle) {
                            return state.errorText;
                          }
                          return null;
                        },
                        builder: (context, errorText) {
                          return Visibility(
                            visible: errorText?.isNotEmpty ?? false,
                            child: Column(
                              children: [
                                Gap(context.themeData.dimensionsData.mediumSpacing),
                                Text(
                                  errorText ?? '',
                                  textAlign: TextAlign.center,
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    color: context.colorScheme.error,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      Gap(context.themeData.dimensionsData.mediumSpacing),
                      // Sign In Button
                      BlocSelector<SignInCubit, SignInState, SignInState>(
                        selector: (state) => state,
                        builder: (context, state) {
                          return ElevatedButton(
                            onPressed: state.isValid ? _signIn : null,
                            child: state.maybeWhen(
                              loading: () => AppWidgets.loadingIndicator(context),
                              orElse: () => Text(context.l10n.signIn),
                            ),
                          );
                        },
                      ),
                      if (kDebugMode) ...[
                        Gap(context.themeData.dimensionsData.smallSpacing),
                        OutlinedButton(
                          onPressed: _skipSignInForDebug,
                          child: Text(
                            '[DEV] Skip Sign In',
                            style: context.themeData.textStyleData.buttonTextStyle.copyWith(
                              color: context.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                      Gap(context.themeData.dimensionsData.mediumSpacing),
                      // Social Media Sign In
                      const SignInSocialMediaIcons(),
                      Gap(context.themeData.dimensionsData.largeSpacing),
                      // Create Account Button
                      if (widget.showCreateAccount)
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(context.l10n.dontHaveAnAccount, textAlign: TextAlign.center),
                            TextButton(
                              onPressed: _navigateToSignUp,
                              child: Text(context.l10n.createAccount),
                            ),
                          ],
                        ),
                      // Bottom Insets
                      SizedBox(height: MediaQuery.viewInsetsOf(context).bottom),
                    ],
                  ),
                ),
              ),
              // Absorb Pointer
              BlocSelector<SignInCubit, SignInState, SignInState>(
                selector: (state) => state,
                builder: (context, state) {
                  return SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: AbsorbPointer(
                      absorbing: state.maybeWhen(loading: () => true, orElse: () => false),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _signIn() {
    _removeFocus();
    context.read<SignInCubit>().setErrorText(null);
    context.read<SignInCubit>().signIn();
  }

  void _skipSignInForDebug() {
    final session = getIt<AppSession>();
    if (session.recoveringPassword) return;
    session.enableDebugGuestMode();
    context.goNamed(
      AppFlowResolver.afterAuthentication(
        features: getIt<AppConfig>().features,
        onboardingCompleted: session.onboardingCompleted,
      ),
    );
  }

  void _navigateToSignUp() {
    _removeFocus();
    context.read<SignInCubit>().setErrorText(null);
    context.pushNamed(AppRouter.signUpRoute);
  }

  void _navigateToForgotPassword() {
    _removeFocus();
    context.read<SignInCubit>().setErrorText(null);
    context.pushNamed(AppRouter.forgotPasswordRoute);
  }

  void _removeFocus() {
    _emailFocusNode.unfocus();
    _passwordFocusNode.unfocus();
  }

  void _clearTextFields() {
    _emailController.clear();
    _passwordController.clear();
  }
}
