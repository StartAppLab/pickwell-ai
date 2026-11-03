import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/_core.dart';
import '../../../app/app.dart';
import '../blocs/email_otp/email_otp_cubit.dart';

class EmailOtpGateView extends StatefulWidget {
  final String? barcode;
  const EmailOtpGateView({super.key, this.barcode});
  @override
  State<EmailOtpGateView> createState() => _EmailOtpGateViewState();
}

class _EmailOtpGateViewState extends State<EmailOtpGateView> {
  final _email = TextEditingController(), _code = TextEditingController();
  void _back([bool authorized = false]) {
    if (context.canPop()) {
      context.pop(authorized);
    } else {
      context.go(widget.barcode == null ? '/settings' : '/capture/${widget.barcode}');
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _code.clear();
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n, d = context.themeData.dimensionsData;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: BlocConsumer<EmailOtpCubit, EmailOtpState>(
          listener: (context, state) {
            if (state.phase == EmailOtpPhase.authorized) {
              _code.clear();
              _back(true);
            }
          },
          builder: (context, state) {
            final cubit = context.read<EmailOtpCubit>();
            final enteringCode = [
              EmailOtpPhase.code,
              EmailOtpPhase.verifying,
            ].contains(state.phase);
            final message = switch (state.error) {
              null => null,
              'invalid_email' => l.pkOtpInvalidEmail,
              'invalid_code' => l.pkOtpInvalidCode,
              'rate_limited' => l.pkOtpRateLimited,
              'auth_disabled' => l.pkOtpUnavailable,
              _ => l.pkOtpNetworkError,
            };
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: d.maxWidth),
                child: ListView(
                  padding: context.themeData.edgeInsetsData.pagePadding,
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  children: [
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Container(
                        padding: EdgeInsets.all(d.paddingMd),
                        decoration: BoxDecoration(
                          color: context.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(d.cardCornerRadius),
                        ),
                        child: AppIcon(
                          icon: Icons.mail_outline,
                          size: d.iconLarge,
                          color: context.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    Gap(d.spacingLg),
                    Text(
                      widget.barcode == null ? l.signIn : l.pkOtpTitle,
                      style: context.textTheme.headlineSmall,
                    ),
                    Gap(d.spacingSm),
                    if (widget.barcode != null) Text(l.pkOtpDraftSafe),
                    Gap(d.spacingLg),
                    if (enteringCode) ...[
                      Text(state.email),
                      Gap(d.spacingMd),
                      TextField(
                        controller: _code,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) {
                          if (!state.busy) cubit.verify(_code.text);
                        },
                        enabled: !state.busy,
                        autofillHints: const [AutofillHints.oneTimeCode],
                        autocorrect: false,
                        enableSuggestions: false,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(8),
                        ],
                        decoration: InputDecoration(
                          labelText: l.pkOtpCode,
                          helperText: l.pkOtpCodeHint,
                        ),
                      ),
                      Gap(d.spacingMd),
                      FilledButton(
                        onPressed: state.busy ? null : () => cubit.verify(_code.text),
                        child: Text(l.pkOtpVerify),
                      ),
                      TextButton(
                        onPressed: state.busy || state.resendAfter > 0
                            ? null
                            : () {
                                _code.clear();
                                cubit.send(state.email);
                              },
                        child: Text(
                          state.resendAfter > 0
                              ? '${l.resendOtpIn}${state.resendAfter}s'
                              : l.pkOtpResend,
                        ),
                      ),
                      TextButton(
                        onPressed: state.busy
                            ? null
                            : () {
                                _code.clear();
                                cubit.changeEmail();
                              },
                        child: Text(l.pkOtpChangeEmail),
                      ),
                    ] else if (state.phase != EmailOtpPhase.checking) ...[
                      TextField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) {
                          if (!state.busy && state.resendAfter == 0) cubit.send(_email.text);
                        },
                        enabled: !state.busy,
                        autofillHints: const [AutofillHints.email],
                        autocorrect: false,
                        textCapitalization: TextCapitalization.none,
                        decoration: InputDecoration(labelText: l.email),
                      ),
                      Gap(d.spacingMd),
                      FilledButton(
                        onPressed: state.busy || state.resendAfter > 0
                            ? null
                            : () => cubit.send(_email.text),
                        child: Text(
                          state.resendAfter > 0
                              ? '${l.resendOtpIn}${state.resendAfter}s'
                              : l.pkOtpSend,
                        ),
                      ),
                    ],
                    if (state.busy) ...[
                      Gap(d.spacingMd),
                      const Center(child: CircularProgressIndicator()),
                    ],
                    if (message != null) ...[
                      Semantics(liveRegion: true, child: Text(message)),
                      if (state.error == 'unavailable')
                        TextButton(
                          onPressed: state.busy ? null : cubit.check,
                          child: Text(l.pkRetry),
                        ),
                    ],
                    Gap(d.spacingMd),
                    TextButton(onPressed: () => _back(), child: Text(l.pkCancel)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
