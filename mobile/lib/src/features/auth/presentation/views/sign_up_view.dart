import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/_config.dart';
import '../../../../core/_core.dart';
import '../../../app/app.dart';
import '../blocs/_blocs.dart';
import '../widgets/_widgets.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  final _firstNameFocusNode = FocusNode();
  final _lastNameFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    context.read<SignUpCubit>().setErrorText(null);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();

    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MaterialAppBar(title: Text(context.l10n.createAccount)),
      body: SafeArea(
        child: BlocListener<SignUpCubit, SignUpState>(
          listener: (context, state) {
            state.whenOrNull(
              success: () {
                if (getIt<AppSession>().isAuthenticated) {
                  _clearTextFields();
                  // The reactive router handles the authenticated destination.
                  return;
                }
                getIt<OtpCubit>().setEmail(_emailController.text.trim());
                _clearTextFields();
                context.goNamed(AppRouter.otpRoute, extra: AppRouter.signUpRoute);
              },
              error: (error) {
                var message = context.l10n.errorServerAccess;
                if (error.message?.isNotEmpty ?? false) {
                  if (error.statusCode == '422' &&
                      error.message!.contains(context.l10n.errorWeakPassword(''))) {
                    message = context.l10n.errorWeakPassword(context.l10n.errorPasswordRequirement);
                  } else {
                    message = error.message!;
                  }
                }
                context.read<SignUpCubit>().setErrorText(message);
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
                      // Email Text Field
                      SignUpEmailTextField(
                        controller: _emailController,
                        focusNode: _emailFocusNode,
                      ),
                      Gap(context.themeData.dimensionsData.smallSpacing),
                      // Password Text Field
                      SignUpPasswordTextField(
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                      ),
                      Gap(context.themeData.dimensionsData.smallSpacing),
                      // Confirm Password Text Field
                      SignUpPasswordConfirmTextField(
                        controller: _confirmPasswordController,
                        focusNode: _confirmPasswordFocusNode,
                      ),
                      Gap(context.themeData.dimensionsData.smallSpacing),
                      // First Name Text Field
                      SignUpFirstNameTextField(
                        controller: _firstNameController,
                        focusNode: _firstNameFocusNode,
                      ),
                      Gap(context.themeData.dimensionsData.smallSpacing),
                      // Last Name Text Field
                      SignUpLastNameTextField(
                        controller: _lastNameController,
                        focusNode: _lastNameFocusNode,
                      ),
                      Gap(context.themeData.dimensionsData.mediumSpacing),
                      Text.rich(
                        textAlign: TextAlign.center,
                        TextSpan(
                          text: '${context.l10n.termsAndPrivacyDesc}\n',
                          children: [
                            // Terms of Use
                            TextSpan(
                              text: context.l10n.termsOfUse,
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  context.pushNamed(AppRouter.termsOfUseRoute);
                                },
                              style: context.themeData.textStyleData.buttonTextStyle.copyWith(
                                color: context.colorScheme.primary,
                                fontSize: 14,
                              ),
                            ),
                            TextSpan(text: ' ${context.l10n.and} '),
                            // Privacy Policy
                            TextSpan(
                              text: context.l10n.privacyPolicy,
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  context.pushNamed(AppRouter.privacyPolicyRoute);
                                },
                              style: context.themeData.textStyleData.buttonTextStyle.copyWith(
                                color: context.colorScheme.primary,
                                fontSize: 14,
                              ),
                            ),
                            const TextSpan(text: '.'),
                          ],
                        ),
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      // Error Text
                      BlocSelector<SignUpCubit, SignUpState, String?>(
                        selector: (state) {
                          if (state is SignUpStateIdle) {
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
                      // Sign Up Button
                      BlocSelector<SignUpCubit, SignUpState, SignUpState>(
                        selector: (state) => state,
                        builder: (context, state) {
                          return ElevatedButton(
                            onPressed: state.isValid ? _signUp : null,
                            child: state.maybeWhen(
                              loading: () => AppWidgets.loadingIndicator(context),
                              orElse: () => Text(context.l10n.signUp),
                            ),
                          );
                        },
                      ),
                      Gap(context.themeData.dimensionsData.mediumSpacing),
                      // Social Media Sign Up
                      const SignUpSocialMediaIcons(),
                    ],
                  ),
                ),
              ),
              // Absorb Pointer
              BlocSelector<SignUpCubit, SignUpState, SignUpState>(
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

  void _signUp() {
    _removeFocus();
    context.read<SignUpCubit>().setErrorText(null);
    context.read<SignUpCubit>().signUp();
  }

  void _removeFocus() {
    _emailFocusNode.unfocus();
    _passwordFocusNode.unfocus();
    _confirmPasswordFocusNode.unfocus();
    _firstNameFocusNode.unfocus();
    _lastNameFocusNode.unfocus();
  }

  void _clearTextFields() {
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    _firstNameController.clear();
    _lastNameController.clear();
  }
}
