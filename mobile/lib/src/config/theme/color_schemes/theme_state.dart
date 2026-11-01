import 'package:flutter/material.dart';

import '../_theme.dart';

class ThemeState {
  final int id;
  final String title;
  final ThemeData lightTheme;
  final ThemeData darkTheme;

  const ThemeState({
    required this.id,
    required this.title,
    required this.lightTheme,
    required this.darkTheme,
  });

  static final List<ThemeState> themes = List.unmodifiable([
    ThemeState(
      id: 0,
      title: 'Default',
      lightTheme: AppTheme.lightTheme(AppColorScheme.lightColorScheme),
      darkTheme: AppTheme.darkTheme(AppColorScheme.darkColorScheme),
    ),
    ThemeState(
      id: 1,
      title: 'Midnight',
      lightTheme: AppTheme.lightTheme(MidnightColorScheme.lightColorScheme),
      darkTheme: AppTheme.darkTheme(MidnightColorScheme.darkColorScheme),
    ),
    ThemeState(
      id: 2,
      title: 'Deep Blue Sea',
      lightTheme: AppTheme.lightTheme(DeepBlueSeaColorScheme.lightColorScheme),
      darkTheme: AppTheme.darkTheme(DeepBlueSeaColorScheme.darkColorScheme),
    ),
    ThemeState(
      id: 3,
      title: 'Pink Sakura',
      lightTheme: AppTheme.lightTheme(PinkSakuraColorScheme.lightColorScheme),
      darkTheme: AppTheme.darkTheme(PinkSakuraColorScheme.darkColorScheme),
    ),
    ThemeState(
      id: 4,
      title: 'Red Red Wine',
      lightTheme: AppTheme.lightTheme(RedRedWineColorScheme.lightColorScheme),
      darkTheme: AppTheme.darkTheme(RedRedWineColorScheme.darkColorScheme),
    ),
    ThemeState(
      id: 5,
      title: 'Willow and Wasabi',
      lightTheme: AppTheme.lightTheme(WillowAndWasabiColorScheme.lightColorScheme),
      darkTheme: AppTheme.darkTheme(WillowAndWasabiColorScheme.darkColorScheme),
    ),
    ThemeState(
      id: 6,
      title: 'Amber Blue',
      lightTheme: AppTheme.lightTheme(AmberBlueColorScheme.lightColorScheme),
      darkTheme: AppTheme.darkTheme(AmberBlueColorScheme.darkColorScheme),
    ),
    ThemeState(
      id: 7,
      title: 'Mallard and Valencia',
      lightTheme: AppTheme.lightTheme(MallardAndValenciaColorScheme.lightColorScheme),
      darkTheme: AppTheme.darkTheme(MallardAndValenciaColorScheme.darkColorScheme),
    ),
    ThemeState(
      id: 8,
      title: 'Espresso and Crema',
      lightTheme: AppTheme.lightTheme(EspressoAndCremaColorScheme.lightColorScheme),
      darkTheme: AppTheme.darkTheme(EspressoAndCremaColorScheme.darkColorScheme),
    ),
    ThemeState(
      id: 9,
      title: 'Eggplant Purple',
      lightTheme: AppTheme.lightTheme(EggplantPurpleColorScheme.lightColorScheme),
      darkTheme: AppTheme.darkTheme(EggplantPurpleColorScheme.darkColorScheme),
    ),
  ]);
}
