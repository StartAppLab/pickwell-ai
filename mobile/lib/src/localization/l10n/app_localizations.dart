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

  /// No description provided for @pkScan.
  ///
  /// In en, this message translates to:
  /// **'Scan barcode'**
  String get pkScan;

  /// No description provided for @pkEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your next food find starts here'**
  String get pkEmptyTitle;

  /// No description provided for @pkEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Scan a food barcode to see its label information. Products you open will appear here.'**
  String get pkEmptyBody;

  /// No description provided for @pkSearch.
  ///
  /// In en, this message translates to:
  /// **'Search your products'**
  String get pkSearch;

  /// No description provided for @pkAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get pkAll;

  /// No description provided for @pkFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get pkFood;

  /// No description provided for @pkNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get pkNewest;

  /// No description provided for @pkPhotoPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Product photo unavailable'**
  String get pkPhotoPlaceholder;

  /// No description provided for @pkLemonPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Lemon logo placeholder'**
  String get pkLemonPlaceholder;

  /// No description provided for @pkFoodProduct.
  ///
  /// In en, this message translates to:
  /// **'Food product'**
  String get pkFoodProduct;

  /// No description provided for @pkNoMatches.
  ///
  /// In en, this message translates to:
  /// **'No matching products'**
  String get pkNoMatches;

  /// No description provided for @pkChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking barcode…'**
  String get pkChecking;

  /// No description provided for @pkPoint.
  ///
  /// In en, this message translates to:
  /// **'Align the food barcode inside the frame'**
  String get pkPoint;

  /// No description provided for @pkTorch.
  ///
  /// In en, this message translates to:
  /// **'Flashlight'**
  String get pkTorch;

  /// No description provided for @pkGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose barcode photo'**
  String get pkGallery;

  /// No description provided for @pkManual.
  ///
  /// In en, this message translates to:
  /// **'Enter barcode'**
  String get pkManual;

  /// No description provided for @pkCameraDenied.
  ///
  /// In en, this message translates to:
  /// **'Camera access is off'**
  String get pkCameraDenied;

  /// No description provided for @pkCameraHint.
  ///
  /// In en, this message translates to:
  /// **'Allow camera access in device settings, choose a photo, or enter the barcode.'**
  String get pkCameraHint;

  /// No description provided for @pkOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open device settings'**
  String get pkOpenSettings;

  /// No description provided for @pkRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get pkRetry;

  /// No description provided for @pkError.
  ///
  /// In en, this message translates to:
  /// **'We could not complete this lookup. Check your connection and try again.'**
  String get pkError;

  /// No description provided for @pkProcessing.
  ///
  /// In en, this message translates to:
  /// **'This product is being processed. Try a fresh lookup shortly.'**
  String get pkProcessing;

  /// No description provided for @pkDenied.
  ///
  /// In en, this message translates to:
  /// **'Lookup limit reached. Please try again after the reset time.'**
  String get pkDenied;

  /// No description provided for @pkStoredUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Your recent products could not be loaded.'**
  String get pkStoredUnavailable;

  /// No description provided for @pkRecentNotSaved.
  ///
  /// In en, this message translates to:
  /// **'Product loaded, but the recent reference could not be saved.'**
  String get pkRecentNotSaved;

  /// No description provided for @pkUnknown.
  ///
  /// In en, this message translates to:
  /// **'This product is not in the catalogue yet'**
  String get pkUnknown;

  /// No description provided for @pkNutrition.
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get pkNutrition;

  /// No description provided for @pkIngredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get pkIngredients;

  /// No description provided for @pkBarcode.
  ///
  /// In en, this message translates to:
  /// **'Barcode'**
  String get pkBarcode;

  /// No description provided for @pkNutritionHint.
  ///
  /// In en, this message translates to:
  /// **'Capture the complete nutrition panel with serving size and units, then the ingredients and allergen statement.'**
  String get pkNutritionHint;

  /// No description provided for @pkCapture.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get pkCapture;

  /// No description provided for @pkLabelsReady.
  ///
  /// In en, this message translates to:
  /// **'Labels captured'**
  String get pkLabelsReady;

  /// No description provided for @pkUnknownAllergens.
  ///
  /// In en, this message translates to:
  /// **'Not stated'**
  String get pkUnknownAllergens;

  /// No description provided for @pkUnknownValue.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get pkUnknownValue;

  /// No description provided for @pkDemo.
  ///
  /// In en, this message translates to:
  /// **'Demo product — fictional data'**
  String get pkDemo;

  /// No description provided for @pkFindings.
  ///
  /// In en, this message translates to:
  /// **'Findings'**
  String get pkFindings;

  /// No description provided for @pkOverview.
  ///
  /// In en, this message translates to:
  /// **'Product overview'**
  String get pkOverview;

  /// No description provided for @pkBasis.
  ///
  /// In en, this message translates to:
  /// **'Nutrition basis'**
  String get pkBasis;

  /// No description provided for @pkLocalRef.
  ///
  /// In en, this message translates to:
  /// **'Open to refresh product details'**
  String get pkLocalRef;

  /// No description provided for @pkCloseSearch.
  ///
  /// In en, this message translates to:
  /// **'Close search'**
  String get pkCloseSearch;

  /// No description provided for @pkCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get pkCancel;

  /// No description provided for @pkNoBarcode.
  ///
  /// In en, this message translates to:
  /// **'No readable barcode in this photo'**
  String get pkNoBarcode;

  /// No description provided for @pkContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get pkContinue;

  /// No description provided for @pkBarcodeDone.
  ///
  /// In en, this message translates to:
  /// **'Barcode ✓'**
  String get pkBarcodeDone;

  /// No description provided for @pkCapturePrivacy.
  ///
  /// In en, this message translates to:
  /// **'Photos are temporary. Submitting sends them securely for label extraction; they are not kept as product photos.'**
  String get pkCapturePrivacy;

  /// No description provided for @pkCaveat.
  ///
  /// In en, this message translates to:
  /// **'Label information is not medical advice.'**
  String get pkCaveat;

  /// No description provided for @pkBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get pkBack;

  /// No description provided for @pkCopyBarcode.
  ///
  /// In en, this message translates to:
  /// **'Copy barcode'**
  String get pkCopyBarcode;

  /// No description provided for @pkInvalidBarcode.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid EAN or UPC barcode.'**
  String get pkInvalidBarcode;

  /// No description provided for @pkRetake.
  ///
  /// In en, this message translates to:
  /// **'Retake photo'**
  String get pkRetake;

  /// No description provided for @pkCaptureStepBarcode.
  ///
  /// In en, this message translates to:
  /// **'Step 1 · Barcode ✓'**
  String get pkCaptureStepBarcode;

  /// No description provided for @pkCaptureStepNutrition.
  ///
  /// In en, this message translates to:
  /// **'Step 2 · Nutrition'**
  String get pkCaptureStepNutrition;

  /// No description provided for @pkCaptureStepIngredients.
  ///
  /// In en, this message translates to:
  /// **'Step 3 · Ingredients'**
  String get pkCaptureStepIngredients;

  /// No description provided for @pkCaptureProgress.
  ///
  /// In en, this message translates to:
  /// **'Label capture progress'**
  String get pkCaptureProgress;

  /// No description provided for @pkIngredientsHint.
  ///
  /// In en, this message translates to:
  /// **'Capture the complete ingredient list and any allergen statements. Keep all text sharp and readable.'**
  String get pkIngredientsHint;

  /// No description provided for @pkCaptureSizeError.
  ///
  /// In en, this message translates to:
  /// **'This photo is empty or larger than 5 MiB. Please retake it.'**
  String get pkCaptureSizeError;

  /// No description provided for @pkCaptureFormatError.
  ///
  /// In en, this message translates to:
  /// **'This photo could not be read. Retake it as a JPEG or PNG image.'**
  String get pkCaptureFormatError;

  /// No description provided for @pkCaptureDimensionsError.
  ///
  /// In en, this message translates to:
  /// **'This photo is too large. Retake it with a maximum dimension of 2400 pixels.'**
  String get pkCaptureDimensionsError;

  /// No description provided for @pkCaptureExpired.
  ///
  /// In en, this message translates to:
  /// **'Your capture draft expired. Please capture both labels again.'**
  String get pkCaptureExpired;

  /// No description provided for @pkCaptureCleanupError.
  ///
  /// In en, this message translates to:
  /// **'Temporary photos could not be cleared. Please try again before taking more photos.'**
  String get pkCaptureCleanupError;

  /// No description provided for @pkCaptureCameraError.
  ///
  /// In en, this message translates to:
  /// **'The camera could not capture a photo. Check camera permission and try again.'**
  String get pkCaptureCameraError;

  /// No description provided for @pkCapturePreviewMissing.
  ///
  /// In en, this message translates to:
  /// **'Photo unavailable. Please retake this label.'**
  String get pkCapturePreviewMissing;

  /// No description provided for @pkCaptureReviewHint.
  ///
  /// In en, this message translates to:
  /// **'Check that both labels are readable. You can retake either photo without losing the other.'**
  String get pkCaptureReviewHint;

  /// No description provided for @pkCaptureSubmissionPending.
  ///
  /// In en, this message translates to:
  /// **'Choose Analyze Product to verify your email. Email verification does not upload these photos.'**
  String get pkCaptureSubmissionPending;

  /// No description provided for @pkDiscardPhotos.
  ///
  /// In en, this message translates to:
  /// **'Discard both photos'**
  String get pkDiscardPhotos;

  /// No description provided for @pkAnalyzeProduct.
  ///
  /// In en, this message translates to:
  /// **'Analyze Product'**
  String get pkAnalyzeProduct;

  /// No description provided for @pkAnalysisPending.
  ///
  /// In en, this message translates to:
  /// **'Email verified. Analysis is not available yet; no photos have been submitted.'**
  String get pkAnalysisPending;

  /// No description provided for @pkOtpTitle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Email'**
  String get pkOtpTitle;

  /// No description provided for @pkOtpDraftSafe.
  ///
  /// In en, this message translates to:
  /// **'Your captured labels stay on this device while you sign in. Cancel returns to your photos.'**
  String get pkOtpDraftSafe;

  /// No description provided for @pkOtpCode.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get pkOtpCode;

  /// No description provided for @pkOtpCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6- or 8-digit code from your email.'**
  String get pkOtpCodeHint;

  /// No description provided for @pkOtpVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get pkOtpVerify;

  /// No description provided for @pkOtpSend.
  ///
  /// In en, this message translates to:
  /// **'Send Code'**
  String get pkOtpSend;

  /// No description provided for @pkOtpResend.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get pkOtpResend;

  /// No description provided for @pkOtpChangeEmail.
  ///
  /// In en, this message translates to:
  /// **'Change email'**
  String get pkOtpChangeEmail;

  /// No description provided for @pkOtpInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get pkOtpInvalidEmail;

  /// No description provided for @pkOtpInvalidCode.
  ///
  /// In en, this message translates to:
  /// **'The code is incorrect or expired. Try again or request another code.'**
  String get pkOtpInvalidCode;

  /// No description provided for @pkOtpRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Please wait before requesting another code. Email delivery is rate limited.'**
  String get pkOtpRateLimited;

  /// No description provided for @pkOtpUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Email sign-in is unavailable in this build.'**
  String get pkOtpUnavailable;

  /// No description provided for @pkOtpNetworkError.
  ///
  /// In en, this message translates to:
  /// **'We could not verify your sign-in. Check your connection and try again.'**
  String get pkOtpNetworkError;

  /// No description provided for @pkAnalysisSubmitHint.
  ///
  /// In en, this message translates to:
  /// **'Both label photos will be sent securely for analysis. Sign in only when you submit.'**
  String get pkAnalysisSubmitHint;

  /// No description provided for @pkAnalysisAuthenticating.
  ///
  /// In en, this message translates to:
  /// **'Verifying your email session…'**
  String get pkAnalysisAuthenticating;

  /// No description provided for @pkAnalysisSubmitting.
  ///
  /// In en, this message translates to:
  /// **'Sending labels and preparing your analysis…'**
  String get pkAnalysisSubmitting;

  /// No description provided for @pkAnalysisProcessing.
  ///
  /// In en, this message translates to:
  /// **'Your request is processing. Check again after a moment; the same request will be reused.'**
  String get pkAnalysisProcessing;

  /// No description provided for @pkAnalysisRetake.
  ///
  /// In en, this message translates to:
  /// **'Please retake the indicated photo. Keep the other accepted photo.'**
  String get pkAnalysisRetake;

  /// No description provided for @pkAnalysisAuthRequired.
  ///
  /// In en, this message translates to:
  /// **'Your session needs verification. Sign in again to resume the same photos.'**
  String get pkAnalysisAuthRequired;

  /// No description provided for @pkAnalysisUncertain.
  ///
  /// In en, this message translates to:
  /// **'We could not confirm the outcome. Your photos are retained temporarily. Check again safely using the same request.'**
  String get pkAnalysisUncertain;

  /// No description provided for @pkAnalysisDisabled.
  ///
  /// In en, this message translates to:
  /// **'New analyses are temporarily unavailable. Your photos have not been submitted for AI processing.'**
  String get pkAnalysisDisabled;

  /// No description provided for @pkAnalysisReview.
  ///
  /// In en, this message translates to:
  /// **'This request cannot be retried automatically. It may need review. Cached products remain available.'**
  String get pkAnalysisReview;

  /// No description provided for @pkAnalysisCheckAgain.
  ///
  /// In en, this message translates to:
  /// **'Check request again'**
  String get pkAnalysisCheckAgain;

  /// No description provided for @pkAnalysisRetryCleanup.
  ///
  /// In en, this message translates to:
  /// **'Retry photo cleanup'**
  String get pkAnalysisRetryCleanup;

  /// No description provided for @pkAnalysisRetryLimit.
  ///
  /// In en, this message translates to:
  /// **'The request-check limit has been reached. Keep this request for review; do not repeatedly submit it.'**
  String get pkAnalysisRetryLimit;

  /// No description provided for @pkFindingGreen.
  ///
  /// In en, this message translates to:
  /// **'Favourable finding'**
  String get pkFindingGreen;

  /// No description provided for @pkFindingYellow.
  ///
  /// In en, this message translates to:
  /// **'Needs context'**
  String get pkFindingYellow;

  /// No description provided for @pkFindingRed.
  ///
  /// In en, this message translates to:
  /// **'Concern'**
  String get pkFindingRed;

  /// No description provided for @pkEvidence.
  ///
  /// In en, this message translates to:
  /// **'Label evidence and rule'**
  String get pkEvidence;

  /// No description provided for @pkRule.
  ///
  /// In en, this message translates to:
  /// **'Rule'**
  String get pkRule;

  /// No description provided for @pkNoProductPhoto.
  ///
  /// In en, this message translates to:
  /// **'Product photo unavailable; showing a placeholder'**
  String get pkNoProductPhoto;

  /// No description provided for @pkPer100g.
  ///
  /// In en, this message translates to:
  /// **'Per 100 g'**
  String get pkPer100g;

  /// No description provided for @pkPer100ml.
  ///
  /// In en, this message translates to:
  /// **'Per 100 mL'**
  String get pkPer100ml;

  /// No description provided for @pkPerServing.
  ///
  /// In en, this message translates to:
  /// **'Per serving'**
  String get pkPerServing;

  /// No description provided for @pkNoFindings.
  ///
  /// In en, this message translates to:
  /// **'No supported colour findings for the available label context.'**
  String get pkNoFindings;

  /// No description provided for @pkRawLabel.
  ///
  /// In en, this message translates to:
  /// **'Printed ingredient text'**
  String get pkRawLabel;

  /// No description provided for @pkDeclaredAllergens.
  ///
  /// In en, this message translates to:
  /// **'Declared allergens'**
  String get pkDeclaredAllergens;

  /// No description provided for @pkServingSize.
  ///
  /// In en, this message translates to:
  /// **'Serving size'**
  String get pkServingSize;

  /// No description provided for @pkMissingInformation.
  ///
  /// In en, this message translates to:
  /// **'Missing information'**
  String get pkMissingInformation;

  /// No description provided for @pkNoMissingReported.
  ///
  /// In en, this message translates to:
  /// **'No additional missing fields were reported. This is not a guarantee of completeness.'**
  String get pkNoMissingReported;

  /// No description provided for @pkAnalysisMethod.
  ///
  /// In en, this message translates to:
  /// **'Analysis and provenance'**
  String get pkAnalysisMethod;

  /// No description provided for @pkAnalysisDate.
  ///
  /// In en, this message translates to:
  /// **'Analyzed'**
  String get pkAnalysisDate;

  /// No description provided for @pkModelVersion.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get pkModelVersion;

  /// No description provided for @pkRulesVersion.
  ///
  /// In en, this message translates to:
  /// **'Rules version'**
  String get pkRulesVersion;

  /// No description provided for @pkPromptVersion.
  ///
  /// In en, this message translates to:
  /// **'Prompt version'**
  String get pkPromptVersion;

  /// No description provided for @pkAnalysisDenied.
  ///
  /// In en, this message translates to:
  /// **'An analysis limit is active. Please try later; your photos are retained temporarily.'**
  String get pkAnalysisDenied;

  /// No description provided for @pkQuotaAnalysis.
  ///
  /// In en, this message translates to:
  /// **'New-product analysis allowance'**
  String get pkQuotaAnalysis;

  /// No description provided for @pkQuotaBarcode.
  ///
  /// In en, this message translates to:
  /// **'Barcode lookup allowance'**
  String get pkQuotaBarcode;

  /// No description provided for @pkQuotaRemaining.
  ///
  /// In en, this message translates to:
  /// **'{remaining} of {limit} remaining'**
  String pkQuotaRemaining(int remaining, int limit);

  /// No description provided for @pkQuotaReserved.
  ///
  /// In en, this message translates to:
  /// **'{count} currently reserved for processing'**
  String pkQuotaReserved(int count);

  /// No description provided for @pkQuotaReset.
  ///
  /// In en, this message translates to:
  /// **'Resets at {time} (your local time)'**
  String pkQuotaReset(String time);

  /// No description provided for @pkQuotaReported.
  ///
  /// In en, this message translates to:
  /// **'Last server report; other activity may change this allowance.'**
  String get pkQuotaReported;

  /// No description provided for @pkQuotaExhausted.
  ///
  /// In en, this message translates to:
  /// **'Daily allowance reached. New requests can resume after the server reset.'**
  String get pkQuotaExhausted;

  /// No description provided for @pkQuotaRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Requests are temporarily limited. Please try later; this may be a network or service limit.'**
  String get pkQuotaRateLimited;

  /// No description provided for @pkQuotaGuestFairUse.
  ///
  /// In en, this message translates to:
  /// **'Public lookups use fair-use and network rate limits. Guests do not have a guaranteed personal daily counter.'**
  String get pkQuotaGuestFairUse;

  /// No description provided for @pkQuotaGuestLimited.
  ///
  /// In en, this message translates to:
  /// **'Public requests from this network are temporarily limited. This is not a personal daily allowance.'**
  String get pkQuotaGuestLimited;

  /// No description provided for @pkQuotaSignInAnalysis.
  ///
  /// In en, this message translates to:
  /// **'New analyses require verified email. No personal allowance is shown for a guest.'**
  String get pkQuotaSignInAnalysis;

  /// No description provided for @pkQuotaRefresh.
  ///
  /// In en, this message translates to:
  /// **'The previous report has passed its reset. Allowance will be checked on the next server request.'**
  String get pkQuotaRefresh;

  /// No description provided for @pkQuotaUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Usage is unavailable. It will be checked on the next server request; no allowance is assumed.'**
  String get pkQuotaUnavailable;

  /// No description provided for @pkQuotaLoadedAvailable.
  ///
  /// In en, this message translates to:
  /// **'Already loaded product information remains available without a new request.'**
  String get pkQuotaLoadedAvailable;

  /// No description provided for @pkQuotaHeld.
  ///
  /// In en, this message translates to:
  /// **'All slots are used or reserved. Processing may release a slot before the next reset.'**
  String get pkQuotaHeld;
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
