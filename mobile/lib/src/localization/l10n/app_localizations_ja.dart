// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Pickwell';

  @override
  String get appWebsite => 'www.pickwell.com';

  @override
  String get skipButton => 'Skip';

  @override
  String get continueButton => 'Continue';

  @override
  String welcomeTitle(String appTitle) {
    return 'Welcome to $appTitle';
  }

  @override
  String get welcomeDesc =>
      'We\'re thrilled to have you on board. Get ready to turn your startup ideas into reaility.';

  @override
  String get getStarted => 'Get Started';

  @override
  String get dontHaveAnAccount => 'Don\'t have an account?';

  @override
  String get alreadyHaveAnAccount => 'Already have an account?';

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get signOut => 'Sign Out';

  @override
  String get signInTitle => 'Welcome Back';

  @override
  String get signInDesc => 'Sign in to continue your startup journey';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get or => 'or';

  @override
  String get createAccount => 'Create Account';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get optional => '(Optional)';

  @override
  String get termsAndPrivacyDesc => 'By signing up, you agree to our';

  @override
  String get and => 'and';

  @override
  String get loading => 'Loading...';

  @override
  String signingInWith(String provider) {
    return 'Signing in with $provider...';
  }

  @override
  String signingUpWith(String provider) {
    return 'Signing up with $provider...';
  }

  @override
  String get google => 'Google';

  @override
  String get apple => 'Apple';

  @override
  String get forgotPassword => 'Forgot Password';

  @override
  String get forgotPasswordDesc =>
      'Please enter your account\'s email address and we will send a link to reset your password';

  @override
  String get resetPasswordSuccessTitle => 'Success!';

  @override
  String get resetPasswordSuccessMessage => 'Reset password link successfully sent to your email';

  @override
  String get changePassword => 'Change Password';

  @override
  String get changePasswordDesc => 'Please enter your new password';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmNewPassword => 'Confirm New Password';

  @override
  String get otpVerification => 'OTP Verification';

  @override
  String get enterCode => 'Enter Code';

  @override
  String get resendCode => 'Resend Code';

  @override
  String get enterCodeDesc => 'Enter the code sent to your email address';

  @override
  String get didntReceiveCode => 'Didn\'t receive code?';

  @override
  String get resendOtpIn => 'Resend OTP in ';

  @override
  String get verify => 'Verify';

  @override
  String get submit => 'Submit';

  @override
  String get confirm => 'Confirm';

  @override
  String get home => 'Home';

  @override
  String get message => 'Message';

  @override
  String get calendar => 'Calendar';

  @override
  String get settings => 'Settings';

  @override
  String greetings(String timeOfDay, String name) {
    return 'Good $timeOfDay $name!';
  }

  @override
  String get subscription => 'Subscription';

  @override
  String get profile => 'Profile';

  @override
  String get account => 'Account';

  @override
  String get notifications => 'Notifications';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get rateApp => 'Rate App';

  @override
  String get shareApp => 'Share App';

  @override
  String get contactUs => 'Contact Us';

  @override
  String get help => 'Help';

  @override
  String get about => 'About';

  @override
  String get termsOfUse => 'Terms of Use';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get dataDeletion => 'Data Deletion';

  @override
  String get editAccount => 'Edit Account';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get changeEmail => 'Change Email';

  @override
  String appVersion(String version, String buildNumber) {
    return 'v$version($buildNumber)';
  }

  @override
  String get errorTitleOops => 'Oops!';

  @override
  String get errorServerAccess =>
      'An error occured during server access. Please try again or come back later.';

  @override
  String errorCannotBeEmpty(String value) {
    return '$value cannot be empty';
  }

  @override
  String errorEnterValidValue(String value) {
    return 'Please enter a valid $value';
  }

  @override
  String errorLettersOnly(String value) {
    return '$value should be letters only';
  }

  @override
  String errorTooShort(String value) {
    return '$value is too short';
  }

  @override
  String errorTooLong(String value) {
    return '$value is too long';
  }

  @override
  String errorDoNotMatch(String value) {
    return '$value do not match';
  }

  @override
  String errorWeakPassword(String value) {
    return 'Password should contain $value';
  }

  @override
  String get errorPasswordRequirement =>
      'uppercase letters, lowercase letters, numbers, and symbols';

  @override
  String get welcomeToPickwell => 'Welcome to Pickwell';

  @override
  String authOptionsDescription(String appName) {
    return '続行するには$appNameにサインインしてください。';
  }

  @override
  String get saveProgressTitle => '進行状況を保存';

  @override
  String get saveProgressDescription => 'アカウントを作成するかサインインして設定を完了してください。';

  @override
  String signInWithProvider(String provider) {
    return '$providerでサインイン';
  }

  @override
  String get signInLaterPrompt => '後でサインインしますか？';

  @override
  String get authContinueError => '続行できませんでした。もう一度お試しください。';

  @override
  String get continueWithEmail => 'メールで続行';

  @override
  String get reviewPromptTitle => '簡単なレビューをお願いできますか？';

  @override
  String reviewPromptBody1(String appName) {
    return 'レビューは、より多くの人が $appName を見つけるきっかけになります。';
  }

  @override
  String get reviewPromptMaybeLater => 'また今度';

  @override
  String get reviewPromptAction => 'レビューする';

  @override
  String get reviewPromptError => 'レビューを開けませんでした。もう一度お試しください。';

  @override
  String get welcomeGuideSubtitle => '毎日のメモに、ちょっとしたヒントを。';

  @override
  String get welcomeGroceriesTitle => '買い物リスト';

  @override
  String get welcomeGroceriesDescription => '必要な買い物、用事、献立のアイデア。';

  @override
  String get welcomeJournalTitle => '日記';

  @override
  String get welcomeJournalDescription => '日々の振り返り、思い出、自分の成長。';

  @override
  String get welcomeStudyTitle => '勉強';

  @override
  String get welcomeStudyDescription => '授業のノート、重要なポイント、復習のヒント。';

  @override
  String get welcomeIdeasTitle => 'アイデアの保存';

  @override
  String get welcomeIdeasDescription => 'ひらめきや、あとで振り返りたい考え。';

  @override
  String get welcomeWorkTitle => '仕事のメモ';

  @override
  String get welcomeWorkDescription => '会議の要点、企画のアイデア、次のアクション。';

  @override
  String get welcomePlanningTitle => '日々の計画';

  @override
  String get welcomePlanningDescription => 'これからの優先事項、目標、予定。';

  @override
  String get subscriptionSuccessTitle => 'おめでとうございます！';

  @override
  String subscriptionSuccessBody(String appName) {
    return '準備ができました。$appName を応援していただきありがとうございます。';
  }

  @override
  String get restoreSuccessTitle => 'アクセスを復元しました';

  @override
  String get restoreSuccessBody => 'プレミアム機能へのアクセスを復元しました。';

  @override
  String get retryButton => '再試行';
}
