import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../../../core/_core.dart';
import '../../../app/app.dart';
import '../blocs/_blocs.dart';
import '../widgets/_widgets.dart';

class OtpView extends StatefulWidget {
  final String fromRoute;

  const OtpView({super.key, required this.fromRoute});

  @override
  State<OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends State<OtpView> {
  final _pinController = TextEditingController();
  final _pinFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    context.read<OtpCubit>().setErrorText(null);
  }

  @override
  void dispose() {
    _pinController.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MaterialAppBar(title: Text(context.l10n.otpVerification)),
      body: SafeArea(
        child: BlocListener<OtpCubit, OtpState>(
          listener: (context, state) {
            state.whenOrNull(
              success: () {
                _clearTextFields();
                // The auth event refreshes the router after verification.
              },
              error: (error) {
                var message = context.l10n.errorServerAccess;
                if (error.message?.isNotEmpty ?? false) {
                  message = error.message!;
                }
                context.read<OtpCubit>().setErrorText(message);
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
                      // OTP Title
                      Text(
                        context.l10n.enterCode,
                        textAlign: TextAlign.center,
                        style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Gap(context.themeData.dimensionsData.smallSpacing),
                      // OTP Description
                      Text(
                        context.l10n.enterCodeDesc,
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      // OTP Email
                      BlocSelector<OtpCubit, OtpState, String?>(
                        selector: (state) {
                          if (state is OtpStateIdle) {
                            return state.email;
                          }
                          return null;
                        },
                        builder: (context, email) {
                          return Text(
                            email ?? '',
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          );
                        },
                      ),
                      Gap(context.themeData.dimensionsData.mediumSpacing),
                      // Otp Pin Input Field
                      OtpPinInputField(controller: _pinController, focusNode: _pinFocusNode),
                      // Error Text
                      BlocSelector<OtpCubit, OtpState, String?>(
                        selector: (state) {
                          if (state is OtpStateIdle) {
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
                      // Verify Button
                      BlocSelector<OtpCubit, OtpState, OtpState>(
                        selector: (state) => state,
                        builder: (context, state) {
                          return ElevatedButton(
                            onPressed: state.isValid ? _verify : null,
                            child: state.maybeWhen(
                              loading: () => AppWidgets.loadingIndicator(context),
                              orElse: () => Text(context.l10n.verify),
                            ),
                          );
                        },
                      ),
                      Gap(context.themeData.dimensionsData.largeSpacing),
                      // Resend Button and Countdown
                      BlocSelector<OtpCubit, OtpState, bool?>(
                        selector: (state) {
                          if (state is OtpStateIdle) {
                            return state.canResend;
                          }
                          return null;
                        },
                        builder: (context, canResend) {
                          if (canResend != null && !canResend) {
                            return const OtpResendCountdown(resendTime: 60);
                          } else {
                            return OtpResendButton(onPressed: _resendCode);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              // Absorb Pointer
              BlocSelector<OtpCubit, OtpState, OtpState>(
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

  void _verify() {
    _removeFocus();
    context.read<OtpCubit>().setErrorText(null);
    context.read<OtpCubit>().otpVerify();
  }

  void _resendCode() {
    _removeFocus();
    context.read<OtpCubit>().setCanResend(false);
    context.read<OtpCubit>().otpResend();
  }

  void _removeFocus() {
    _pinFocusNode.unfocus();
  }

  void _clearTextFields() {
    _pinController.clear();
  }
}
