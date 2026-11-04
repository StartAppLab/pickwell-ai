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
  String get pkCaptureStepBarcode => 'Barcode ✓';

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
  String get pkCaptureExpired =>
      'Your capture draft expired. Please capture the front and both labels again.';

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
      'Check the front packaging, nutrition and ingredients photos. You can retake one without losing the others.';

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
      'All three photos will be sent securely for analysis. Sign in only when you submit.';

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

  @override
  String get pkQuotaAnalysis => 'New-product analysis allowance';

  @override
  String get pkQuotaBarcode => 'Barcode lookup allowance';

  @override
  String pkQuotaRemaining(int remaining, int limit) {
    return '$remaining of $limit remaining';
  }

  @override
  String pkQuotaReserved(int count) {
    return '$count currently reserved for processing';
  }

  @override
  String pkQuotaReset(String time) {
    return 'Resets at $time (your local time)';
  }

  @override
  String get pkQuotaReported => 'Last server report; other activity may change this allowance.';

  @override
  String get pkQuotaExhausted =>
      'Daily allowance reached. New requests can resume after the server reset.';

  @override
  String get pkQuotaRateLimited =>
      'Requests are temporarily limited. Please try later; this may be a network or service limit.';

  @override
  String get pkQuotaGuestFairUse =>
      'Public lookups use fair-use and network rate limits. Guests do not have a guaranteed personal daily counter.';

  @override
  String get pkQuotaGuestLimited =>
      'Public requests from this network are temporarily limited. This is not a personal daily allowance.';

  @override
  String get pkQuotaSignInAnalysis =>
      'New analyses require verified email. No personal allowance is shown for a guest.';

  @override
  String get pkQuotaRefresh =>
      'The previous report has passed its reset. Allowance will be checked on the next server request.';

  @override
  String get pkQuotaUnavailable =>
      'Usage is unavailable. It will be checked on the next server request; no allowance is assumed.';

  @override
  String get pkQuotaLoadedAvailable =>
      'Already loaded product information remains available without a new request.';

  @override
  String get pkQuotaHeld =>
      'All slots are used or reserved. Processing may release a slot before the next reset.';

  @override
  String get pkPendingTitle => 'Needs analysis';

  @override
  String get pkPendingSaved =>
      'Photos are saved privately on this device. This draft expires after 24 hours; device cleanup may remove it sooner. Other products can be saved separately.';

  @override
  String get pkPendingResume => 'Continue analysis';

  @override
  String get pkPendingDelete => 'Delete saved draft';

  @override
  String get pkPendingSaveError =>
      'Your photos are still open, but could not be saved for restart. Check device storage and try again before closing the app.';

  @override
  String get pkAnalysisServiceDaily =>
      'The service’s daily analysis test capacity has been reached. Your photos are kept; this does not spend a successful-analysis credit.';

  @override
  String pkAnalysisRetryAt(String time) {
    return 'Try again after $time.';
  }

  @override
  String pkAnalysisTryAfter(int seconds) {
    return 'Wait at least $seconds seconds, then check again. Your photos are kept.';
  }

  @override
  String get pkPendingSaving => 'Saving photos on this device…';

  @override
  String pkPendingLimit(int limit) {
    return 'You have $limit saved drafts. Finish or delete one before capturing another product.';
  }

  @override
  String get pkPendingLoadError =>
      'Saved drafts could not be loaded. Try again; existing files have been kept.';

  @override
  String get pkRetakeSourceModel => 'Meta photo review';

  @override
  String get pkRetakeSourceValidation => 'Validation check';

  @override
  String get pkRetakeSourceLegacy => 'Earlier result';

  @override
  String get pkRetakeModelNoValues =>
      'Meta could not read any numeric nutrition values from this panel.';

  @override
  String get pkRetakeCauseAllergenSource =>
      'The extracted allergen statement does not match the transcribed text.';

  @override
  String get pkRetakeCauseBlurOrGlare =>
      'Meta reported blur or glare here. Hold the camera steady and change the lighting angle.';

  @override
  String get pkRetakeCauseContradictoryEnergy =>
      'The extracted kcal and kJ values disagree. Include both energy values and their headings.';

  @override
  String get pkRetakeCauseContradictoryMass =>
      'The extracted nutrient amounts exceed the stated serving amount. Check that the serving size and one complete column are visible.';

  @override
  String get pkRetakeCauseContradictoryTotals =>
      'The extracted values conflict: a component exceeds its total. Include the full row and column headings.';

  @override
  String get pkRetakeCauseCroppedLabel =>
      'Meta reported that this area is cropped. Include the complete panel and its headings.';

  @override
  String get pkRetakeCauseDuplicateNutrient =>
      'Conflicting entries were extracted for the same nutrient. Include the column headings.';

  @override
  String get pkRetakeCauseIncompleteIngredients =>
      'The ingredient transcription contains a missing or unreadable section.';

  @override
  String get pkRetakeCauseIngredientOrderOrSource =>
      'Extracted ingredients could not be matched to the transcribed text in printed order. This may be an extraction error.';

  @override
  String get pkRetakeCauseMissingIngredients =>
      'The extraction contains no ingredient list. Show the full ingredient panel.';

  @override
  String get pkRetakeCauseMissingNutrition =>
      'No nutrition panel text or nutrient entries were extracted.';

  @override
  String get pkRetakeCauseModelRequested =>
      'Meta requested a retake but did not provide a specific diagnosis. Retaking may not resolve it.';

  @override
  String get pkRetakeCauseNoReadableValues =>
      'None of the extracted numbers passed the source checks. This can be a transcription or validation issue, not necessarily a blurry photo.';

  @override
  String get pkRetakeCauseNumericRange =>
      'An extracted value is outside plausible ranges. This may be a reading error.';

  @override
  String get pkRetakeCauseNumericSource =>
      'The extracted number or unit could not be matched to the transcribed label text, so it was kept unknown.';

  @override
  String get pkRetakeCauseOther =>
      'Meta requested another photo of this area without a more specific diagnosis.';

  @override
  String get pkRetakeCauseProductMismatch =>
      'The two photos were identified as different products. Check that both belong to the same package.';

  @override
  String get pkRetakeCauseReasonUnavailable =>
      'No specific reason was stored for this earlier result. Retaking may not resolve it.';

  @override
  String get pkRetakeCauseUnitMismatch =>
      'The extracted unit does not fit this nutrient. Include both the value and its unit.';

  @override
  String get pkRetakeCauseUnreadableText =>
      'Meta could not read this area. Check that the text is sharp and fully visible.';

  @override
  String get pkRetakeCauseUnspecifiedRetake =>
      'A retake was requested without a specific diagnosis. Retaking may not resolve it; this result needs review.';

  @override
  String get pkRetakeCauseWrongPhoto =>
      'Meta did not recognize the expected label in this photo. Check that it shows the correct panel.';

  @override
  String get pkRetakeFieldNutritionPanel => 'Nutrition panel';

  @override
  String get pkRetakeFieldIngredientsList => 'Ingredient list';

  @override
  String get pkRetakeFieldProductIdentity => 'Product identity';

  @override
  String get pkRetakeFieldServingBasis => 'Serving basis';

  @override
  String get pkRetakeFieldServingSize => 'Serving size';

  @override
  String get pkRetakeFieldAllergens => 'Declared allergens';

  @override
  String get pkRetakeFieldEnergy => 'Energy';

  @override
  String get pkRetakeFieldFat => 'Fat';

  @override
  String get pkRetakeFieldSaturates => 'Saturated fat';

  @override
  String get pkRetakeFieldCarbohydrate => 'Carbohydrate';

  @override
  String get pkRetakeFieldSugars => 'Sugars';

  @override
  String get pkRetakeFieldAddedSugars => 'Added sugars';

  @override
  String get pkRetakeFieldProtein => 'Protein';

  @override
  String get pkRetakeFieldSalt => 'Salt';

  @override
  String get pkRetakeFieldSodium => 'Sodium';

  @override
  String get pkRetakeFieldFibre => 'Fibre';

  @override
  String get pkRetakeFieldOther => 'Label area';

  @override
  String get pkRetakeRecheckSaved => 'Reanalyze saved photos';

  @override
  String get pkRetakeRecheckCost =>
      'This starts a new Meta analysis using your saved photos and counts as another provider attempt. It may still request a retake.';

  @override
  String get pkIngredientContext => 'Common food function and context';

  @override
  String get pkReferences => 'Reviewed references';

  @override
  String get pkInterpretationVersion => 'Interpretation version';

  @override
  String get pkReferenceVersion => 'Reference review';

  @override
  String get pkLegacyInterpretation =>
      'This cached result contains label facts and earlier explanations. It has not received the current reference review.';

  @override
  String get pkTranscriptionCaveat =>
      'AI-read label amounts can contain errors. Check the package, especially allergen information.';

  @override
  String get pkSortProducts => '商品の並べ替え';

  @override
  String get pkOldest => '古い順';

  @override
  String get pkNameAscending => '名前の昇順';

  @override
  String get pkNameDescending => '名前の降順';

  @override
  String get pkCardDetails => '栄養と原材料';

  @override
  String get pkCardUnavailable => '接続して商品詳細を読み込む';

  @override
  String get pkNoPhoto => '写真なし';

  @override
  String get pkClearSearch => '検索をクリア';

  @override
  String get pkFrontPackaging => 'パッケージ前面';

  @override
  String get pkFrontPackagingHint => '商品名、ブランド、種類、内容量が見えるようにパッケージの前面を撮影してください。';

  @override
  String get pkCaptureStepFront => '手順1 · 前面';

  @override
  String get pkIdentityUnverified => 'バーコードとの対応は独立に確認されていません。商品情報は送信されたパッケージから読み取られています。';

  @override
  String get pkVariant => '種類';

  @override
  String get pkNetQuantity => '内容量';

  @override
  String get pkAnalysisReviewPending => '共有する前に担当者による確認が必要です。写真は保存されており、成功した分析の利用枠は消費されていません。';

  @override
  String get pkAnalysisReviewRejected => '商品の対応関係は承認されませんでした。写真と分析の利用枠は保持されています。';

  @override
  String get pkCancelAnalysisReview => '確認をキャンセル';

  @override
  String pkReviewExpiresAt(String time) {
    return '確認期限: $time';
  }

  @override
  String get pkBarcodeOperatorReviewed => 'バーコードとの対応は担当者が確認しましたが、独立した検証ではありません。';

  @override
  String get pkAnalysisReviewExpired => '確認期限が切れました。写真は保存されています。新しい分析を送信できます。';
}
