import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../../../config/_config.dart';
import '../../../../core/_core.dart';
import '../../../app/app.dart';
import '../blocs/_blocs.dart';

class SettingsThemeView extends StatefulWidget {
  const SettingsThemeView({super.key});

  @override
  State<SettingsThemeView> createState() => _SettingsThemeViewState();
}

class _SettingsThemeViewState extends State<SettingsThemeView> {
  late List<Widget> _list;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final themes = ThemeState.themes;
    _list = List.generate(themes.length, (index) {
      final theme = themes[index];
      final lastItem = index == themes.length - 1;
      final colorList = [
        ColoredBox(
          color:
              (context.colorScheme.brightness == Brightness.light
                      ? theme.lightTheme
                      : theme.darkTheme)
                  .colorScheme
                  .primary,
        ),
        ColoredBox(
          color:
              (context.colorScheme.brightness == Brightness.light
                      ? theme.lightTheme
                      : theme.darkTheme)
                  .colorScheme
                  .primaryContainer,
        ),
        ColoredBox(
          color:
              (context.colorScheme.brightness == Brightness.light
                      ? theme.lightTheme
                      : theme.darkTheme)
                  .colorScheme
                  .secondary,
        ),
        ColoredBox(
          color:
              (context.colorScheme.brightness == Brightness.light
                      ? theme.lightTheme
                      : theme.darkTheme)
                  .colorScheme
                  .tertiary,
        ),
      ];
      return Column(
        children: [
          BlocSelector<SettingsCubit, SettingsState, int>(
            selector: (state) => state.selectedTheme,
            builder: (context, selectedTheme) {
              return ListChoiceItem(
                icon: SizedBox(
                  width: 30,
                  height: 30,
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 1,
                    crossAxisSpacing: 1,
                    physics: const NeverScrollableScrollPhysics(),
                    children: colorList,
                  ),
                ),
                text: theme.title,
                isSelected: theme.id == selectedTheme,
                onPressed: () => context.read<SettingsCubit>().setTheme(theme),
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
      appBar: MaterialAppBar(title: Text(context.l10n.theme)),
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
