import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../core/_core.dart';
import '../../../app/app.dart';
import '../../../catalog/presentation/widgets/scanner_circle_button.dart';
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
    final colors = context.colorScheme;
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(d.nestedCornerRadius),
      borderSide: BorderSide(color: colors.outlineVariant),
    );
    return Scaffold(
      backgroundColor: Color.lerp(colors.surfaceContainerLowest, colors.surface, .3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        forceMaterialTransparency: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: d.minimumTouchTarget + d.paddingXs * 2,
        leadingWidth: d.minimumTouchTarget + d.paddingMd * 2,
        leading: Padding(
          padding: EdgeInsets.symmetric(horizontal: d.paddingMd, vertical: d.paddingXs),
          child: ScannerCircleButton(
            icon: CupertinoIcons.chevron_back,
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: () => _back(),
          ),
        ),
      ),
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
                    Gap(d.spacingLg),
                    Center(
                      child: Container(
                        padding: EdgeInsets.all(d.paddingLg),
                        decoration: BoxDecoration(
                          color: colors.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: AppIcon(
                          icon: enteringCode
                              ? HugeIcons.strokeRoundedMailValidation01
                              : HugeIcons.strokeRoundedMail01,
                          size: d.iconLarge,
                          color: colors.onPrimaryContainer,
                        ),
                      ),
                    ),
                    Gap(d.spacingLg),
                    Text(
                      enteringCode
                          ? l.pkOtpCodeTitle
                          : widget.barcode == null
                          ? l.signIn
                          : l.pkOtpTitle,
                      textAlign: TextAlign.center,
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.primary,
                      ),
                    ),
                    Gap(d.spacingSm),
                    Text(
                      enteringCode ? l.pkOtpCodeIntro : l.pkOtpEmailIntro,
                      textAlign: TextAlign.center,
                      style: context.textTheme.bodyLarge?.copyWith(
                        color: colors.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    Gap(d.spacingLg),
                    if (enteringCode) ...[
                      Text(
                        state.email,
                        textAlign: TextAlign.center,
                        style: context.textTheme.titleMedium,
                      ),
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
                        textAlign: TextAlign.center,
                        style: context.textTheme.headlineSmall?.copyWith(letterSpacing: 2),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(8),
                        ],
                        decoration: InputDecoration(
                          labelText: l.pkOtpCode,
                          helperText: l.pkOtpCodeHint,
                          helperMaxLines: 3,
                          filled: true,
                          fillColor: colors.surfaceContainerLowest,
                          border: inputBorder,
                          enabledBorder: inputBorder,
                        ),
                      ),
                      Gap(d.spacingMd),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          minimumSize: Size.fromHeight(d.minimumTouchTarget),
                          shape: const StadiumBorder(),
                        ),
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
                        decoration: InputDecoration(
                          labelText: l.email,
                          filled: true,
                          fillColor: colors.surfaceContainerLowest,
                          border: inputBorder,
                          enabledBorder: inputBorder,
                        ),
                      ),
                      Gap(d.spacingMd),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          minimumSize: Size.fromHeight(d.minimumTouchTarget),
                          shape: const StadiumBorder(),
                        ),
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
                    if (state.busy) ...[Gap(d.spacingMd), const LinearProgressIndicator()],
                    if (message != null) ...[
                      Gap(d.spacingMd),
                      Semantics(
                        liveRegion: true,
                        child: Container(
                          padding: EdgeInsets.all(d.paddingMd),
                          decoration: BoxDecoration(
                            color: colors.errorContainer,
                            borderRadius: BorderRadius.circular(d.nestedCornerRadius),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppIcon(
                                icon: HugeIcons.strokeRoundedAlertCircle,
                                color: colors.onErrorContainer,
                              ),
                              Gap(d.spacingSm),
                              Expanded(
                                child: Text(
                                  message,
                                  style: TextStyle(color: colors.onErrorContainer),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (state.error == 'unavailable')
                        TextButton(
                          onPressed: state.busy ? null : cubit.check,
                          child: Text(l.pkRetry),
                        ),
                    ],
                    Gap(d.spacingMd),
                    if (widget.barcode != null) ...[
                      Text(
                        l.pkOtpDraftSafe,
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                      Gap(d.spacingSm),
                    ],
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
