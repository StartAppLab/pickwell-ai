import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/_config.dart';
import '../../../../core/_core.dart';
import '../../../app/app.dart';
import '../blocs/_blocs.dart';
import '../widgets/_widgets.dart';

class ChangePasswordView extends StatefulWidget {
  final String? code;
  final String? tokenHash;

  const ChangePasswordView({super.key, this.code, this.tokenHash});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    context.read<ChangePasswordCubit>().setErrorText(null);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MaterialAppBar(title: Text(context.l10n.changePassword)),
      body: SafeArea(
        child: BlocListener<ChangePasswordCubit, ChangePasswordState>(
          listener: (context, state) {
            state.whenOrNull(
              success: () {
                final session = getIt<AppSession>();
                _clearTextFields();
                if (!session.recoveringPassword) {
                  context.goNamed(AppRouter.settingsAccountRoute);
                  return;
                }
                session.finishRecovery();
                context.goNamed(
                  AppFlowResolver.afterAuthentication(
                    features: session.config.features,
                    onboardingCompleted: session.onboardingCompleted,
                  ),
                );
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
                context.read<ChangePasswordCubit>().setErrorText(message);
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
                      // Change Password Description
                      Text(
                        context.l10n.changePasswordDesc,
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Gap(context.themeData.dimensionsData.mediumSpacing),
                      // Password Text Field
                      ChangePasswordPasswordTextField(
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                      ),
                      Gap(context.themeData.dimensionsData.smallSpacing),
                      // Confirm Password Text Field
                      ChangePasswordPasswordConfirmTextField(
                        controller: _confirmPasswordController,
                        focusNode: _confirmPasswordFocusNode,
                      ),
                      // Error Text
                      BlocSelector<ChangePasswordCubit, ChangePasswordState, String?>(
                        selector: (state) {
                          if (state is ChangePasswordStateIdle) {
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
                      // Confirm Button
                      BlocSelector<ChangePasswordCubit, ChangePasswordState, ChangePasswordState>(
                        selector: (state) => state,
                        builder: (context, state) {
                          return ElevatedButton(
                            onPressed: state.isValid ? _confirm : null,
                            child: state.maybeWhen(
                              loading: () => AppWidgets.loadingIndicator(context),
                              orElse: () => Text(context.l10n.confirm),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              // Absorb Pointer
              BlocSelector<ChangePasswordCubit, ChangePasswordState, ChangePasswordState>(
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

  void _confirm() {
    _removeFocus();
    context.read<ChangePasswordCubit>().setErrorText(null);
    context.read<ChangePasswordCubit>().changePassword();
  }

  void _removeFocus() {
    _passwordFocusNode.unfocus();
    _confirmPasswordFocusNode.unfocus();
  }

  void _clearTextFields() {
    _passwordController.clear();
    _confirmPasswordController.clear();
  }
}
