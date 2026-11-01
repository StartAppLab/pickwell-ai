import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../../../../core/_core.dart';
import '../../blocs/_blocs.dart';

class OtpResendCountdown extends StatelessWidget {
  final int resendTime;

  const OtpResendCountdown({super.key, required this.resendTime});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          context.l10n.resendOtpIn,
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium,
        ),
        Gap(context.themeData.dimensionsData.textSpacing),
        TweenAnimationBuilder<Duration>(
          tween: Tween(
            begin: Duration(seconds: resendTime),
            end: Duration.zero,
          ),
          duration: Duration(seconds: resendTime),
          onEnd: () {
            if (context.mounted) context.read<OtpCubit>().setCanResend(true);
          },
          builder: (BuildContext context, Duration value, Widget? child) {
            final seconds = value.inSeconds % 60;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Text(
                '$seconds',
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            );
          },
        ),
      ],
    );
  }
}
