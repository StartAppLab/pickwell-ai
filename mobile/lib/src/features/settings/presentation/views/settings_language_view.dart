import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/_core.dart';
import '../../../../localization/_localization.dart';
import '../../../app/app.dart';
import '../blocs/_blocs.dart';

class SettingsLanguageView extends StatefulWidget {
  const SettingsLanguageView({super.key});

  @override
  State<SettingsLanguageView> createState() => _SettingsLanguageViewState();
}

class _SettingsLanguageViewState extends State<SettingsLanguageView> {
  late List<Widget> _list;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final locales = LocaleState.locales;
    _list = [
      BlocSelector<SettingsCubit, SettingsState, int>(
        selector: (state) => state.selectedLanguage,
        builder: (context, selectedLanguage) => ListChoiceItem(
          icon: AppIcon(
            icon: HugeIcons.strokeRoundedSmartPhone01,
            color: context.colorScheme.primary,
          ),
          text: 'System',
          isSelected: selectedLanguage == -1,
          onPressed: () => context.read<SettingsCubit>().setLanguage(null),
        ),
      ),
      Gap(context.themeData.dimensionsData.smallSpacing),
      ...List.generate(locales.length, (index) {
        final locale = locales[index];
        final lastItem = index == locales.length - 1;
        return Column(
          children: [
            BlocSelector<SettingsCubit, SettingsState, int>(
              selector: (state) => state.selectedLanguage,
              builder: (context, selectedLanguage) {
                return ListChoiceItem(
                  icon: SvgPicture.asset(locale.image, height: 20),
                  text: locale.title,
                  isSelected: locale.id == selectedLanguage,
                  onPressed: () => context.read<SettingsCubit>().setLanguage(locale),
                );
              },
            ),
            if (!lastItem) Gap(context.themeData.dimensionsData.smallSpacing),
          ],
        );
      }),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MaterialAppBar(title: Text(context.l10n.language)),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: context.themeData.edgeInsetsData.pagePadding,
            child: Column(children: _list),
          ),
        ),
      ),
    );
  }
}
