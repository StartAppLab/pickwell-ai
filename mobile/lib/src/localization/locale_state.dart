import 'dart:ui';

import '../resources/_resources.dart';
import '_localization.dart';

class LocaleState {
  final int id;
  final String title;
  final String image;
  final Locale locale;

  const LocaleState({
    required this.id,
    required this.title,
    required this.image,
    required this.locale,
  });

  static List<LocaleState> get locales {
    // 12 total languages
    return [
      LocaleState(
        id: 0,
        title: 'English',
        image: AppAssets.icons.flags.icUs.path,
        locale: AppLocale.english,
      ),
      LocaleState(
        id: 1,
        title: 'Spanish',
        image: AppAssets.icons.flags.icEs.path,
        locale: AppLocale.spanish,
      ),
      LocaleState(
        id: 2,
        title: 'Chinese',
        image: AppAssets.icons.flags.icCn.path,
        locale: AppLocale.chinese,
      ),
      LocaleState(
        id: 3,
        title: 'French',
        image: AppAssets.icons.flags.icFr.path,
        locale: AppLocale.french,
      ),
      LocaleState(
        id: 4,
        title: 'German',
        image: AppAssets.icons.flags.icDe.path,
        locale: AppLocale.german,
      ),
      LocaleState(
        id: 5,
        title: 'Portuguese',
        image: AppAssets.icons.flags.icPt.path,
        locale: AppLocale.portuguese,
      ),
      LocaleState(
        id: 6,
        title: 'Arabic',
        image: AppAssets.icons.flags.icAe.path,
        locale: AppLocale.arabic,
      ),
      LocaleState(
        id: 7,
        title: 'Hindi',
        image: AppAssets.icons.flags.icIn.path,
        locale: AppLocale.hindi,
      ),
      LocaleState(
        id: 8,
        title: 'Russian',
        image: AppAssets.icons.flags.icRu.path,
        locale: AppLocale.russian,
      ),
      LocaleState(
        id: 9,
        title: 'Japanese',
        image: AppAssets.icons.flags.icJp.path,
        locale: AppLocale.japanese,
      ),
      LocaleState(
        id: 10,
        title: 'Korean',
        image: AppAssets.icons.flags.icKr.path,
        locale: AppLocale.korean,
      ),
      LocaleState(
        id: 11,
        title: 'Italian',
        image: AppAssets.icons.flags.icIt.path,
        locale: AppLocale.italian,
      ),
    ];
  }
}
