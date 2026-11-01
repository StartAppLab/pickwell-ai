import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/_core.dart';
import '../../../app/app.dart';
import '../blocs/_blocs.dart';
import '../widgets/_widgets.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    context.read<ForgotPasswordCubit>().setErrorText(null);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MaterialAppBar(title: Text(context.l10n.forgotPassword)),
      body: SafeArea(
        child: BlocListener<ForgotPasswordCubit, ForgotPasswordState>(
          listener: (context, state) {
            state.whenOrNull(
              success: () {
                _clearTextFields();
                context.pop();
                AppWidgets.showSuccessSnackBar(context, context.l10n.resetPasswordSuccessMessage);
              },
              error: (error) {
                var message = context.l10n.errorServerAccess;
                if (error.message?.isNotEmpty ?? false) {
                  message = error.message!;
                }
                context.read<ForgotPasswordCubit>().setErrorText(message);
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
                      // Forgot Password Description
                      Text(
                        context.l10n.forgotPasswordDesc,
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Gap(context.themeData.dimensionsData.mediumSpacing),
                      // Email Text Field
                      ForgotPasswordEmailTextField(
                        controller: _emailController,
                        focusNode: _emailFocusNode,
                      ),
                      // Error Text
                      BlocSelector<ForgotPasswordCubit, ForgotPasswordState, String?>(
                        selector: (state) {
                          if (state is ForgotPasswordStateIdle) {
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
                      // Submit Button
                      BlocSelector<ForgotPasswordCubit, ForgotPasswordState, ForgotPasswordState>(
                        selector: (state) => state,
                        builder: (context, state) {
                          return ElevatedButton(
                            onPressed: state.isValid ? _submit : null,
                            child: state.maybeWhen(
                              loading: () => AppWidgets.loadingIndicator(context),
                              orElse: () => Text(context.l10n.submit),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              // Absorb Pointer
              BlocSelector<ForgotPasswordCubit, ForgotPasswordState, ForgotPasswordState>(
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

  void _submit() {
    _removeFocus();
    context.read<ForgotPasswordCubit>().setErrorText(null);
    context.read<ForgotPasswordCubit>().submit();
  }

  void _removeFocus() {
    _emailFocusNode.unfocus();
  }

  void _clearTextFields() {
    _emailController.clear();
  }
}
