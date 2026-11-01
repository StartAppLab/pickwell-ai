import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

import '_localization.dart';

class AppLocale {
  static final _rtlLanguageCodes = ['ar', 'fa', 'he', 'ps', 'ur'];

  static const english = Locale.fromSubtags(languageCode: 'en');
  static const spanish = Locale.fromSubtags(languageCode: 'es');
  static const chinese = Locale.fromSubtags(languageCode: 'zh');
  static const french = Locale.fromSubtags(languageCode: 'fr');
  static const german = Locale.fromSubtags(languageCode: 'de');
  static const portuguese = Locale.fromSubtags(languageCode: 'pt');
  static const arabic = Locale.fromSubtags(languageCode: 'ar');
  static const hindi = Locale.fromSubtags(languageCode: 'hi');
  static const russian = Locale.fromSubtags(languageCode: 'ru');
  static const japanese = Locale.fromSubtags(languageCode: 'ja');
  static const korean = Locale.fromSubtags(languageCode: 'ko');
  static const italian = Locale.fromSubtags(languageCode: 'it');

  static List<Locale> supportedLocales = const [
    english,
    spanish,
    chinese,
    french,
    german,
    portuguese,
    arabic,
    hindi,
    russian,
    japanese,
    korean,
    italian,
  ];

  static List<LocalizationsDelegate<dynamic>> localizationsDelegates = const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static AppLocalizations of(BuildContext context) => AppLocalizations.of(context)!;

  static bool isRtl(BuildContext context) {
    return _rtlLanguageCodes.contains(Localizations.localeOf(context).languageCode.toLowerCase());
  }
}
