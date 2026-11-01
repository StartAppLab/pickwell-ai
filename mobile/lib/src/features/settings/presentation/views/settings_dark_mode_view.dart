import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/_core.dart';
import '../../../app/app.dart';
import '../../domain/entities/_entities.dart';
import '../blocs/_blocs.dart';

class SettingsDarkModeView extends StatefulWidget {
  const SettingsDarkModeView({super.key});

  @override
  State<SettingsDarkModeView> createState() => _SettingsDarkModeViewState();
}

class _SettingsDarkModeViewState extends State<SettingsDarkModeView> {
  late List<Widget> _list;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final themeModes = [
      SettingsEntity(
        id: 0,
        icon: HugeIcons.strokeRoundedSmartPhone01,
        title: 'System',
        isSelected: true,
        onPressed: () => context.read<SettingsCubit>().setDarkMode(ThemeMode.system),
      ),
      SettingsEntity(
        id: 1,
        icon: HugeIcons.strokeRoundedSun03,
        title: 'Light',
        isSelected: false,
        onPressed: () => context.read<SettingsCubit>().setDarkMode(ThemeMode.light),
      ),
      SettingsEntity(
        id: 2,
        icon: HugeIcons.strokeRoundedMoon02,
        title: 'Dark',
        isSelected: false,
        onPressed: () => context.read<SettingsCubit>().setDarkMode(ThemeMode.dark),
      ),
    ];

    _list = List.generate(themeModes.length, (index) {
      final settings = themeModes[index];
      final lastItem = index == themeModes.length - 1;
      return Column(
        children: [
          BlocSelector<SettingsCubit, SettingsState, int>(
            selector: (state) => state.selectedDarkMode,
            builder: (context, selectedDarkMode) {
              return ListChoiceItem(
                icon: AppIcon(icon: settings.icon!, color: context.colorScheme.primary),
                text: settings.title,
                isSelected: settings.id == selectedDarkMode,
                onPressed: settings.onPressed,
              );
            },
          ),
          if (!lastItem) Gap(context.themeData.dimensionsData.smallSpacing),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MaterialAppBar(title: Text(context.l10n.darkMode)),
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
