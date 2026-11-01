import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('pt'),
    Locale('ru'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Pickwell'**
  String get appTitle;

  /// No description provided for @appWebsite.
  ///
  /// In en, this message translates to:
  /// **'www.pickwell.com'**
  String get appWebsite;

  /// No description provided for @skipButton.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skipButton;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// A welcome message for users
  ///
  /// In en, this message translates to:
  /// **'Welcome to {appTitle}'**
  String welcomeTitle(String appTitle);

  /// No description provided for @welcomeDesc.
  ///
  /// In en, this message translates to:
  /// **'We\'\'re thrilled to have you on board. Get ready to turn your startup ideas into reaility.'**
  String get welcomeDesc;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @dontHaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'\'t have an account?'**
  String get dontHaveAnAccount;

  /// No description provided for @alreadyHaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAnAccount;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @signInTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get signInTitle;

  /// No description provided for @signInDesc.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue your startup journey'**
  String get signInDesc;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'(Optional)'**
  String get optional;

  /// No description provided for @termsAndPrivacyDesc.
  ///
  /// In en, this message translates to:
  /// **'By signing up, you agree to our'**
  String get termsAndPrivacyDesc;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get and;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @signingInWith.
  ///
  /// In en, this message translates to:
  /// **'Signing in with {provider}...'**
  String signingInWith(String provider);

  /// No description provided for @signingUpWith.
  ///
  /// In en, this message translates to:
  /// **'Signing up with {provider}...'**
  String signingUpWith(String provider);

  /// No description provided for @google.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get google;

  /// No description provided for @apple.
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get apple;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPassword;

  /// No description provided for @forgotPasswordDesc.
  ///
  /// In en, this message translates to:
  /// **'Please enter your account\'\'s email address and we will send a link to reset your password'**
  String get forgotPasswordDesc;

  /// No description provided for @resetPasswordSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Success!'**
  String get resetPasswordSuccessTitle;

  /// No description provided for @resetPasswordSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Reset password link successfully sent to your email'**
  String get resetPasswordSuccessMessage;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @changePasswordDesc.
  ///
  /// In en, this message translates to:
  /// **'Please enter your new password'**
  String get changePasswordDesc;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @otpVerification.
  ///
  /// In en, this message translates to:
  /// **'OTP Verification'**
  String get otpVerification;

  /// No description provided for @enterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter Code'**
  String get enterCode;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get resendCode;

  /// No description provided for @enterCodeDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter the code sent to your email address'**
  String get enterCodeDesc;

  /// No description provided for @didntReceiveCode.
  ///
  /// In en, this message translates to:
  /// **'Didn\'\'t receive code?'**
  String get didntReceiveCode;

  /// No description provided for @resendOtpIn.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP in '**
  String get resendOtpIn;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// A greeting message for users
  ///
  /// In en, this message translates to:
  /// **'Good {timeOfDay} {name}!'**
  String greetings(String timeOfDay, String name);

  /// No description provided for @subscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscription;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @rateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate App'**
  String get rateApp;

  /// No description provided for @shareApp.
  ///
  /// In en, this message translates to:
  /// **'Share App'**
  String get shareApp;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsOfUse;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @dataDeletion.
  ///
  /// In en, this message translates to:
  /// **'Data Deletion'**
  String get dataDeletion;

  /// No description provided for @editAccount.
  ///
  /// In en, this message translates to:
  /// **'Edit Account'**
  String get editAccount;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @changeEmail.
  ///
  /// In en, this message translates to:
  /// **'Change Email'**
  String get changeEmail;

  /// The app version text info
  ///
  /// In en, this message translates to:
  /// **'v{version}({buildNumber})'**
  String appVersion(String version, String buildNumber);

  /// No description provided for @errorTitleOops.
  ///
  /// In en, this message translates to:
  /// **'Oops!'**
  String get errorTitleOops;

  /// No description provided for @errorServerAccess.
  ///
  /// In en, this message translates to:
  /// **'An error occured during server access. Please try again or come back later.'**
  String get errorServerAccess;

  /// No description provided for @errorCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'{value} cannot be empty'**
  String errorCannotBeEmpty(String value);

  /// No description provided for @errorEnterValidValue.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid {value}'**
  String errorEnterValidValue(String value);

  /// No description provided for @errorLettersOnly.
  ///
  /// In en, this message translates to:
  /// **'{value} should be letters only'**
  String errorLettersOnly(String value);

  /// No description provided for @errorTooShort.
  ///
  /// In en, this message translates to:
  /// **'{value} is too short'**
  String errorTooShort(String value);

  /// No description provided for @errorTooLong.
  ///
  /// In en, this message translates to:
  /// **'{value} is too long'**
  String errorTooLong(String value);

  /// No description provided for @errorDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'{value} do not match'**
  String errorDoNotMatch(String value);

  /// No description provided for @errorWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password should contain {value}'**
  String errorWeakPassword(String value);

  /// No description provided for @errorPasswordRequirement.
  ///
  /// In en, this message translates to:
  /// **'uppercase letters, lowercase letters, numbers, and symbols'**
  String get errorPasswordRequirement;

  /// No description provided for @welcomeToPickwell.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Pickwell'**
  String get welcomeToPickwell;

  /// No description provided for @authOptionsDescription.
  ///
  /// In en, this message translates to:
  /// **'Sign in to {appName} to continue.'**
  String authOptionsDescription(String appName);

  /// No description provided for @saveProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Save your progress'**
  String get saveProgressTitle;

  /// No description provided for @saveProgressDescription.
  ///
  /// In en, this message translates to:
  /// **'Create an account or sign in to finish your setup.'**
  String get saveProgressDescription;

  /// No description provided for @signInWithProvider.
  ///
  /// In en, this message translates to:
  /// **'Sign in with {provider}'**
  String signInWithProvider(String provider);

  /// No description provided for @signInLaterPrompt.
  ///
  /// In en, this message translates to:
  /// **'Would you like to sign in later?'**
  String get signInLaterPrompt;

  /// No description provided for @authContinueError.
  ///
  /// In en, this message translates to:
  /// **'Unable to continue. Please try again.'**
  String get authContinueError;

  /// No description provided for @continueWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Continue with email'**
  String get continueWithEmail;

  /// No description provided for @reviewPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Would you leave a quick review?'**
  String get reviewPromptTitle;

  /// No description provided for @reviewPromptBody1.
  ///
  /// In en, this message translates to:
  /// **'Your review helps more people discover {appName}.'**
  String reviewPromptBody1(String appName);

  /// No description provided for @reviewPromptMaybeLater.
  ///
  /// In en, this message translates to:
  /// **'Maybe later'**
  String get reviewPromptMaybeLater;

  /// No description provided for @reviewPromptAction.
  ///
  /// In en, this message translates to:
  /// **'Leave a review'**
  String get reviewPromptAction;

  /// No description provided for @reviewPromptError.
  ///
  /// In en, this message translates to:
  /// **'Unable to open reviews. Please try again.'**
  String get reviewPromptError;

  /// No description provided for @welcomeGuideSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A little inspiration for your everyday notes.'**
  String get welcomeGuideSubtitle;

  /// No description provided for @welcomeGroceriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Grocery lists'**
  String get welcomeGroceriesTitle;

  /// No description provided for @welcomeGroceriesDescription.
  ///
  /// In en, this message translates to:
  /// **'Shopping essentials, errands, and meal ideas.'**
  String get welcomeGroceriesDescription;

  /// No description provided for @welcomeJournalTitle.
  ///
  /// In en, this message translates to:
  /// **'Journaling'**
  String get welcomeJournalTitle;

  /// No description provided for @welcomeJournalDescription.
  ///
  /// In en, this message translates to:
  /// **'Daily reflections, memorable moments, and personal growth.'**
  String get welcomeJournalDescription;

  /// No description provided for @welcomeStudyTitle.
  ///
  /// In en, this message translates to:
  /// **'Studying'**
  String get welcomeStudyTitle;

  /// No description provided for @welcomeStudyDescription.
  ///
  /// In en, this message translates to:
  /// **'Class notes, key concepts, and revision ideas.'**
  String get welcomeStudyDescription;

  /// No description provided for @welcomeIdeasTitle.
  ///
  /// In en, this message translates to:
  /// **'Storing ideas'**
  String get welcomeIdeasTitle;

  /// No description provided for @welcomeIdeasDescription.
  ///
  /// In en, this message translates to:
  /// **'Creative sparks and thoughts worth returning to.'**
  String get welcomeIdeasDescription;

  /// No description provided for @welcomeWorkTitle.
  ///
  /// In en, this message translates to:
  /// **'Work notes'**
  String get welcomeWorkTitle;

  /// No description provided for @welcomeWorkDescription.
  ///
  /// In en, this message translates to:
  /// **'Meeting takeaways, project ideas, and next steps.'**
  String get welcomeWorkDescription;

  /// No description provided for @welcomePlanningTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal planning'**
  String get welcomePlanningTitle;

  /// No description provided for @welcomePlanningDescription.
  ///
  /// In en, this message translates to:
  /// **'Priorities, goals, and plans for the days ahead.'**
  String get welcomePlanningDescription;

  /// No description provided for @subscriptionSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get subscriptionSuccessTitle;

  /// No description provided for @subscriptionSuccessBody.
  ///
  /// In en, this message translates to:
  /// **'You’re all set. Thank you for supporting {appName}.'**
  String subscriptionSuccessBody(String appName);

  /// Title confirming restored existing premium access, rather than a new purchase.
  ///
  /// In en, this message translates to:
  /// **'Access Restored'**
  String get restoreSuccessTitle;

  /// Confirmation after restoring verified premium access. Does not imply a new purchase or charge.
  ///
  /// In en, this message translates to:
  /// **'Your premium access has been restored.'**
  String get restoreSuccessBody;

  /// No description provided for @retryButton.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retryButton;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fr',
    'hi',
    'it',
    'ja',
    'ko',
    'pt',
    'ru',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
