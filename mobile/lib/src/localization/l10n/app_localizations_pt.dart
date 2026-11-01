// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

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
    return 'Entre no $appName para continuar.';
  }

  @override
  String get saveProgressTitle => 'Salve seu progresso';

  @override
  String get saveProgressDescription => 'Crie uma conta ou entre para concluir a configuração.';

  @override
  String signInWithProvider(String provider) {
    return 'Entrar com $provider';
  }

  @override
  String get signInLaterPrompt => 'Gostaria de entrar mais tarde?';

  @override
  String get authContinueError => 'Não foi possível continuar. Tente novamente.';

  @override
  String get continueWithEmail => 'Continuar com e-mail';

  @override
  String get reviewPromptTitle => 'Você deixaria uma avaliação rápida?';

  @override
  String reviewPromptBody1(String appName) {
    return 'Sua avaliação ajuda mais pessoas a descobrir $appName.';
  }

  @override
  String get reviewPromptMaybeLater => 'Talvez depois';

  @override
  String get reviewPromptAction => 'Deixar uma avaliação';

  @override
  String get reviewPromptError => 'Não foi possível abrir as avaliações. Tente novamente.';

  @override
  String get welcomeGuideSubtitle => 'Um pouco de inspiração para suas notas do dia a dia.';

  @override
  String get welcomeGroceriesTitle => 'Listas de compras';

  @override
  String get welcomeGroceriesDescription => 'Compras essenciais, tarefas e ideias de refeições.';

  @override
  String get welcomeJournalTitle => 'Diário pessoal';

  @override
  String get welcomeJournalDescription =>
      'Reflexões diárias, momentos especiais e crescimento pessoal.';

  @override
  String get welcomeStudyTitle => 'Estudos';

  @override
  String get welcomeStudyDescription =>
      'Anotações de aula, conceitos importantes e ideias de revisão.';

  @override
  String get welcomeIdeasTitle => 'Guardar ideias';

  @override
  String get welcomeIdeasDescription => 'Inspirações e pensamentos para retomar depois.';

  @override
  String get welcomeWorkTitle => 'Notas de trabalho';

  @override
  String get welcomeWorkDescription =>
      'Conclusões de reuniões, ideias de projetos e próximos passos.';

  @override
  String get welcomePlanningTitle => 'Planejamento pessoal';

  @override
  String get welcomePlanningDescription => 'Prioridades, metas e planos para os próximos dias.';

  @override
  String get subscriptionSuccessTitle => 'Parabéns!';

  @override
  String subscriptionSuccessBody(String appName) {
    return 'Tudo pronto. Obrigado por apoiar $appName.';
  }

  @override
  String get restoreSuccessTitle => 'Acesso restaurado';

  @override
  String get restoreSuccessBody => 'Seu acesso premium foi restaurado.';

  @override
  String get retryButton => 'Tentar novamente';
}
