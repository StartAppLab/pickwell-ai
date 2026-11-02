// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

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
    return '계속하려면 $appName에 로그인하세요.';
  }

  @override
  String get saveProgressTitle => '진행 상황 저장';

  @override
  String get saveProgressDescription => '계정을 만들거나 로그인하여 설정을 완료하세요.';

  @override
  String signInWithProvider(String provider) {
    return '$provider로 로그인';
  }

  @override
  String get signInLaterPrompt => '나중에 로그인하시겠어요?';

  @override
  String get authContinueError => '계속할 수 없습니다. 다시 시도해 주세요.';

  @override
  String get continueWithEmail => '이메일로 계속';

  @override
  String get reviewPromptTitle => '짧은 리뷰를 남겨주실 수 있나요?';

  @override
  String reviewPromptBody1(String appName) {
    return '리뷰를 남겨 주시면 더 많은 사람들이 $appName을 발견하는 데 도움이 됩니다.';
  }

  @override
  String get reviewPromptMaybeLater => '나중에';

  @override
  String get reviewPromptAction => '리뷰 남기기';

  @override
  String get reviewPromptError => '리뷰를 열 수 없습니다. 다시 시도해 주세요.';

  @override
  String get welcomeGuideSubtitle => '일상의 메모를 위한 작은 영감.';

  @override
  String get welcomeGroceriesTitle => '장보기 목록';

  @override
  String get welcomeGroceriesDescription => '필요한 물품, 할 일, 식사 아이디어.';

  @override
  String get welcomeJournalTitle => '일기 쓰기';

  @override
  String get welcomeJournalDescription => '하루의 생각, 소중한 순간, 나의 성장.';

  @override
  String get welcomeStudyTitle => '공부';

  @override
  String get welcomeStudyDescription => '수업 노트, 핵심 개념, 복습 아이디어.';

  @override
  String get welcomeIdeasTitle => '아이디어 저장';

  @override
  String get welcomeIdeasDescription => '창의적인 영감과 다시 살펴볼 생각.';

  @override
  String get welcomeWorkTitle => '업무 메모';

  @override
  String get welcomeWorkDescription => '회의 요점, 프로젝트 아이디어, 다음 단계.';

  @override
  String get welcomePlanningTitle => '개인 계획';

  @override
  String get welcomePlanningDescription => '앞으로의 우선순위, 목표, 계획.';

  @override
  String get subscriptionSuccessTitle => '축하합니다!';

  @override
  String subscriptionSuccessBody(String appName) {
    return '모든 준비가 끝났습니다. $appName을 응원해 주셔서 감사합니다.';
  }

  @override
  String get restoreSuccessTitle => '이용 권한 복원 완료';

  @override
  String get restoreSuccessBody => '프리미엄 이용 권한이 복원되었습니다.';

  @override
  String get retryButton => '다시 시도';

  @override
  String get pkScan => 'Scan barcode';

  @override
  String get pkEmptyTitle => 'Your next food find starts here';

  @override
  String get pkEmptyBody =>
      'Scan a food barcode to see its label information. Products you open will appear here.';

  @override
  String get pkSearch => 'Search your products';

  @override
  String get pkAll => 'All';

  @override
  String get pkFood => 'Food';

  @override
  String get pkNewest => 'Newest';

  @override
  String get pkPhotoPlaceholder => 'Product photo unavailable';

  @override
  String get pkLemonPlaceholder => 'Lemon logo placeholder';

  @override
  String get pkFoodProduct => 'Food product';

  @override
  String get pkNoMatches => 'No matching products';

  @override
  String get pkChecking => 'Checking barcode…';

  @override
  String get pkPoint => 'Align the food barcode inside the frame';

  @override
  String get pkTorch => 'Flashlight';

  @override
  String get pkGallery => 'Choose barcode photo';

  @override
  String get pkManual => 'Enter barcode';

  @override
  String get pkCameraDenied => 'Camera access is off';

  @override
  String get pkCameraHint =>
      'Allow camera access in device settings, choose a photo, or enter the barcode.';

  @override
  String get pkOpenSettings => 'Open device settings';

  @override
  String get pkRetry => 'Try again';

  @override
  String get pkError => 'We could not complete this lookup. Check your connection and try again.';

  @override
  String get pkProcessing => 'This product is being processed. Try a fresh lookup shortly.';

  @override
  String get pkDenied => 'Lookup limit reached. Please try again after the reset time.';

  @override
  String get pkStoredUnavailable => 'Your recent products could not be loaded.';

  @override
  String get pkRecentNotSaved => 'Product loaded, but the recent reference could not be saved.';

  @override
  String get pkUnknown => 'This product is not in the catalogue yet';

  @override
  String get pkNutrition => 'Nutrition';

  @override
  String get pkIngredients => 'Ingredients';

  @override
  String get pkBarcode => 'Barcode';

  @override
  String get pkNutritionHint =>
      'Capture the complete nutrition panel with serving size and units, then the ingredients and allergen statement.';

  @override
  String get pkCapture => 'Take photo';

  @override
  String get pkLabelsReady => 'Labels captured';

  @override
  String get pkUnknownAllergens => 'Not stated';

  @override
  String get pkUnknownValue => 'Unknown';

  @override
  String get pkDemo => 'Demo product — fictional data';

  @override
  String get pkFindings => 'Findings';

  @override
  String get pkOverview => 'Product overview';

  @override
  String get pkBasis => 'Nutrition basis';

  @override
  String get pkLocalRef => 'Open to refresh product details';

  @override
  String get pkCloseSearch => 'Close search';

  @override
  String get pkCancel => 'Cancel';

  @override
  String get pkNoBarcode => 'No readable barcode in this photo';

  @override
  String get pkContinue => 'Continue';

  @override
  String get pkBarcodeDone => 'Barcode ✓';

  @override
  String get pkCapturePrivacy => 'Photos stay on this device. No analysis has been submitted.';

  @override
  String get pkCaveat => 'Label information is not medical advice.';

  @override
  String get pkBack => 'Back';

  @override
  String get pkCopyBarcode => 'Copy barcode';

  @override
  String get pkInvalidBarcode => 'Enter a valid EAN or UPC barcode.';

  @override
  String get pkRetake => 'Retake labels';
}
