// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

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
    return 'سجّل الدخول إلى $appName للمتابعة.';
  }

  @override
  String get saveProgressTitle => 'احفظ تقدمك';

  @override
  String get saveProgressDescription => 'أنشئ حسابًا أو سجّل الدخول لإكمال الإعداد.';

  @override
  String signInWithProvider(String provider) {
    return 'تسجيل الدخول باستخدام $provider';
  }

  @override
  String get signInLaterPrompt => 'هل ترغب في تسجيل الدخول لاحقًا؟';

  @override
  String get authContinueError => 'تعذّرت المتابعة. يُرجى المحاولة مرة أخرى.';

  @override
  String get continueWithEmail => 'المتابعة بالبريد الإلكتروني';

  @override
  String get reviewPromptTitle => 'هل تترك لنا مراجعة سريعة؟';

  @override
  String reviewPromptBody1(String appName) {
    return 'تساعد مراجعتك المزيد من الأشخاص على اكتشاف $appName.';
  }

  @override
  String get reviewPromptMaybeLater => 'ربما لاحقًا';

  @override
  String get reviewPromptAction => 'اترك مراجعة';

  @override
  String get reviewPromptError => 'تعذّر فتح المراجعات. يُرجى المحاولة مرة أخرى.';

  @override
  String get welcomeGuideSubtitle => 'بعض الإلهام لملاحظاتك اليومية.';

  @override
  String get welcomeGroceriesTitle => 'قوائم التسوق';

  @override
  String get welcomeGroceriesDescription => 'المشتريات الأساسية والمهمات وأفكار الوجبات.';

  @override
  String get welcomeJournalTitle => 'اليوميات';

  @override
  String get welcomeJournalDescription => 'تأملات يومية ولحظات مميزة ونمو شخصي.';

  @override
  String get welcomeStudyTitle => 'الدراسة';

  @override
  String get welcomeStudyDescription => 'ملاحظات الدروس والمفاهيم الأساسية وأفكار المراجعة.';

  @override
  String get welcomeIdeasTitle => 'حفظ الأفكار';

  @override
  String get welcomeIdeasDescription => 'إلهام إبداعي وأفكار تستحق العودة إليها.';

  @override
  String get welcomeWorkTitle => 'ملاحظات العمل';

  @override
  String get welcomeWorkDescription => 'خلاصات الاجتماعات وأفكار المشاريع والخطوات التالية.';

  @override
  String get welcomePlanningTitle => 'التخطيط الشخصي';

  @override
  String get welcomePlanningDescription => 'الأولويات والأهداف والخطط للأيام المقبلة.';

  @override
  String get subscriptionSuccessTitle => 'تهانينا!';

  @override
  String subscriptionSuccessBody(String appName) {
    return 'كل شيء جاهز. شكرًا لدعمك $appName.';
  }

  @override
  String get restoreSuccessTitle => 'تمت استعادة الوصول';

  @override
  String get restoreSuccessBody => 'تمت استعادة وصولك إلى الميزات المميزة.';

  @override
  String get retryButton => 'حاول مجددًا';

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
  String get pkCapturePrivacy =>
      'Photos are temporary. Submitting sends them securely for label extraction; they are not kept as product photos.';

  @override
  String get pkCaveat => 'Label information is not medical advice.';

  @override
  String get pkBack => 'Back';

  @override
  String get pkCopyBarcode => 'Copy barcode';

  @override
  String get pkInvalidBarcode => 'Enter a valid EAN or UPC barcode.';

  @override
  String get pkRetake => 'Retake photo';

  @override
  String get pkCaptureStepBarcode => 'Step 1 · Barcode ✓';

  @override
  String get pkCaptureStepNutrition => 'Step 2 · Nutrition';

  @override
  String get pkCaptureStepIngredients => 'Step 3 · Ingredients';

  @override
  String get pkCaptureProgress => 'Label capture progress';

  @override
  String get pkIngredientsHint =>
      'Capture the complete ingredient list and any allergen statements. Keep all text sharp and readable.';

  @override
  String get pkCaptureSizeError => 'This photo is empty or larger than 5 MiB. Please retake it.';

  @override
  String get pkCaptureFormatError =>
      'This photo could not be read. Retake it as a JPEG or PNG image.';

  @override
  String get pkCaptureDimensionsError =>
      'This photo is too large. Retake it with a maximum dimension of 2400 pixels.';

  @override
  String get pkCaptureExpired => 'Your capture draft expired. Please capture both labels again.';

  @override
  String get pkCaptureCleanupError =>
      'Temporary photos could not be cleared. Please try again before taking more photos.';

  @override
  String get pkCaptureCameraError =>
      'The camera could not capture a photo. Check camera permission and try again.';

  @override
  String get pkCapturePreviewMissing => 'Photo unavailable. Please retake this label.';

  @override
  String get pkCaptureReviewHint =>
      'Check that both labels are readable. You can retake either photo without losing the other.';

  @override
  String get pkCaptureSubmissionPending =>
      'Choose Analyze Product to verify your email. Email verification does not upload these photos.';

  @override
  String get pkDiscardPhotos => 'Discard both photos';

  @override
  String get pkAnalyzeProduct => 'Analyze Product';

  @override
  String get pkAnalysisPending =>
      'Email verified. Analysis is not available yet; no photos have been submitted.';

  @override
  String get pkOtpTitle => 'Continue with Email';

  @override
  String get pkOtpDraftSafe =>
      'Your captured labels stay on this device while you sign in. Cancel returns to your photos.';

  @override
  String get pkOtpCode => 'Verification code';

  @override
  String get pkOtpCodeHint => 'Enter the 6- or 8-digit code from your email.';

  @override
  String get pkOtpVerify => 'Verify';

  @override
  String get pkOtpSend => 'Send Code';

  @override
  String get pkOtpResend => 'Resend Code';

  @override
  String get pkOtpChangeEmail => 'Change email';

  @override
  String get pkOtpInvalidEmail => 'Enter a valid email address.';

  @override
  String get pkOtpInvalidCode =>
      'The code is incorrect or expired. Try again or request another code.';

  @override
  String get pkOtpRateLimited =>
      'Please wait before requesting another code. Email delivery is rate limited.';

  @override
  String get pkOtpUnavailable => 'Email sign-in is unavailable in this build.';

  @override
  String get pkOtpNetworkError =>
      'We could not verify your sign-in. Check your connection and try again.';

  @override
  String get pkAnalysisSubmitHint =>
      'Both label photos will be sent securely for analysis. Sign in only when you submit.';

  @override
  String get pkAnalysisAuthenticating => 'Verifying your email session…';

  @override
  String get pkAnalysisSubmitting => 'Sending labels and preparing your analysis…';

  @override
  String get pkAnalysisProcessing =>
      'Your request is processing. Check again after a moment; the same request will be reused.';

  @override
  String get pkAnalysisRetake =>
      'Please retake the indicated photo. Keep the other accepted photo.';

  @override
  String get pkAnalysisAuthRequired =>
      'Your session needs verification. Sign in again to resume the same photos.';

  @override
  String get pkAnalysisUncertain =>
      'We could not confirm the outcome. Your photos are retained temporarily. Check again safely using the same request.';

  @override
  String get pkAnalysisDisabled =>
      'New analyses are temporarily unavailable. Your photos have not been submitted for AI processing.';

  @override
  String get pkAnalysisReview =>
      'This request cannot be retried automatically. It may need review. Cached products remain available.';

  @override
  String get pkAnalysisCheckAgain => 'Check request again';

  @override
  String get pkAnalysisRetryCleanup => 'Retry photo cleanup';

  @override
  String get pkAnalysisRetryLimit =>
      'The request-check limit has been reached. Keep this request for review; do not repeatedly submit it.';

  @override
  String get pkFindingGreen => 'Favourable finding';

  @override
  String get pkFindingYellow => 'Needs context';

  @override
  String get pkFindingRed => 'Concern';

  @override
  String get pkEvidence => 'Label evidence and rule';

  @override
  String get pkRule => 'Rule';

  @override
  String get pkNoProductPhoto => 'Product photo unavailable; showing a placeholder';

  @override
  String get pkPer100g => 'Per 100 g';

  @override
  String get pkPer100ml => 'Per 100 mL';

  @override
  String get pkPerServing => 'Per serving';

  @override
  String get pkNoFindings => 'No supported colour findings for the available label context.';

  @override
  String get pkRawLabel => 'Printed ingredient text';

  @override
  String get pkDeclaredAllergens => 'Declared allergens';

  @override
  String get pkServingSize => 'Serving size';

  @override
  String get pkMissingInformation => 'Missing information';

  @override
  String get pkNoMissingReported =>
      'No additional missing fields were reported. This is not a guarantee of completeness.';

  @override
  String get pkAnalysisMethod => 'Analysis and provenance';

  @override
  String get pkAnalysisDate => 'Analyzed';

  @override
  String get pkModelVersion => 'Model';

  @override
  String get pkRulesVersion => 'Rules version';

  @override
  String get pkPromptVersion => 'Prompt version';

  @override
  String get pkAnalysisDenied =>
      'An analysis limit is active. Please try later; your photos are retained temporarily.';
}
