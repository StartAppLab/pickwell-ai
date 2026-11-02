import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import '../../../../core/_core.dart';
import '../blocs/catalog/label_capture_cubit.dart';

class CaptureEntryView extends StatelessWidget {
  final String barcode;
  const CaptureEntryView({super.key, required this.barcode});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(),
    body: SafeArea(
      child: BlocBuilder<LabelCaptureCubit, LabelCaptureState>(
        builder: (context, state) {
          final l = context.l10n;
          final d = context.themeData.dimensionsData;
          return ListView(
            padding: context.themeData.edgeInsetsData.pagePadding,
            children: [
              Text(l.pkUnknown, style: context.textTheme.headlineSmall),
              Gap(d.spacingMd),
              Text(barcode),
              Gap(d.spacingLg),
              Wrap(
                spacing: d.spacingXs,
                children: [
                  Chip(label: Text(l.pkBarcodeDone)),
                  Chip(label: Text(l.pkNutrition)),
                  Chip(label: Text(l.pkIngredients)),
                ],
              ),
              Gap(d.spacingLg),
              Text(l.pkNutritionHint),
              Gap(d.spacingLg),
              for (var i = 0; i < state.labels.length; i++)
                Padding(
                  padding: EdgeInsets.only(bottom: d.paddingMd),
                  child: Column(
                    children: [
                      Text(i == 0 ? l.pkNutrition : l.pkIngredients),
                      Image.memory(
                        state.labels[i],
                        height: 160,
                        fit: BoxFit.contain,
                        excludeFromSemantics: true,
                      ),
                    ],
                  ),
                ),
              if (state.failed) Text(l.pkError),
              if (state.busy) const Center(child: CircularProgressIndicator()),
              if (!state.busy && state.labels.length < 2)
                FilledButton(
                  onPressed: () => context.read<LabelCaptureCubit>().capture(),
                  child: Text(
                    '${l.pkCapture}: ${state.labels.isEmpty ? l.pkNutrition : l.pkIngredients}',
                  ),
                ),
              if (!state.busy && state.labels.length == 2) ...[
                Text(l.pkLabelsReady, style: context.textTheme.titleLarge),
                TextButton(
                  onPressed: () => context.read<LabelCaptureCubit>().reset(),
                  child: Text(l.pkRetake),
                ),
              ],
              Gap(d.spacingMd),
              Text(l.pkCapturePrivacy),
            ],
          );
        },
      ),
    ),
  );
}
