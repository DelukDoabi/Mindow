// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Mindow';

  @override
  String get homeWelcomeTitle => 'Welcome to Mindow';

  @override
  String get homeWelcomeBody =>
      'Your backpack is ready. Soon you\'ll lighten your mental load here.';

  @override
  String get onboardingWelcomeHeadline =>
      'Set your mind down. We\'ll carry the rest.';

  @override
  String get onboardingWelcomeBody =>
      'Put down everything on your mind. Mindow helps you carry less, one thing at a time.';

  @override
  String get onboardingWelcomeCta => 'Get started';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingContinue => 'Continue';

  @override
  String get onboardingContextTitle => 'Tell us a little about you';

  @override
  String get onboardingContextSubtitle =>
      'Everything is optional — it just helps us personalize things.';

  @override
  String get onboardingAgeRangeLabel => 'Your age range';

  @override
  String get onboardingAgeUnder25 => 'Under 25';

  @override
  String get onboardingAge25to34 => '25–34';

  @override
  String get onboardingAge35to44 => '35–44';

  @override
  String get onboardingAge45to54 => '45–54';

  @override
  String get onboardingAgeOver55 => '55 and over';

  @override
  String get onboardingFamilyLabel => 'Your family situation';

  @override
  String get onboardingFamilySingle => 'Single';

  @override
  String get onboardingFamilyCouple => 'In a relationship';

  @override
  String get onboardingFamilyWithChildren => 'With children';

  @override
  String get onboardingFamilySingleParent => 'Single parent';

  @override
  String get onboardingStressLabel => 'Your stress level right now';

  @override
  String get onboardingStressLow => 'Light';

  @override
  String get onboardingStressModerate => 'Moderate';

  @override
  String get onboardingStressHigh => 'High';

  @override
  String get onboardingStressVeryHigh => 'Very high';

  @override
  String get onboardingMindVolumeTitle => 'How many things are on your mind?';

  @override
  String get onboardingMindVolumeSubtitle =>
      'A rough guess is plenty. There\'s no wrong answer.';

  @override
  String get onboardingMindVolumeUpTo10 => '0 to 10';

  @override
  String get onboardingMindVolume10to20 => '10 to 20';

  @override
  String get onboardingMindVolume20to50 => '20 to 50';

  @override
  String get onboardingMindVolumeOver50 => 'More than 50';

  @override
  String get accountTitle => 'Save your progress';

  @override
  String get accountSubtitle =>
      'Create your account so your backpack is always with you, on every device.';

  @override
  String get accountContinueWithApple => 'Continue with Apple';

  @override
  String get accountContinueWithGoogle => 'Continue with Google';

  @override
  String get accountContinueWithEmail => 'Continue with email';

  @override
  String get accountEmailLabel => 'Email';

  @override
  String get accountEmailHint => 'you@example.com';

  @override
  String get accountPasswordLabel => 'Password';

  @override
  String get accountAuthError => 'Small hiccup connecting. Shall we try again?';

  @override
  String get consentTitle => 'Your words stay yours';

  @override
  String get consentBody =>
      'To help you carry less, what you write is sent to our AI partner to be analyzed, then comes back to you. Nothing is shared anywhere else, and you can export or delete everything whenever you want.';

  @override
  String get consentAccept => 'Got it, I agree';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsPrivacySection => 'Privacy & data';

  @override
  String get settingsExportData => 'Export my data';

  @override
  String get settingsExportRequested =>
      'Your export is on its way. We\'ll get it ready for you.';

  @override
  String get settingsDeleteAccount => 'Delete my account';

  @override
  String get settingsDeleteConfirmTitle => 'Delete your account?';

  @override
  String get settingsDeleteConfirmBody =>
      'This permanently erases your account and everything in your backpack. It can\'t be undone.';

  @override
  String get settingsDeleteConfirmCta => 'Delete';

  @override
  String get settingsCancel => 'Cancel';

  @override
  String get settingsActionError => 'Small hiccup. Shall we try again?';

  @override
  String get settingsAiSection => 'AI Analysis';

  @override
  String get settingsAiConsentToggle => 'Analyse my worries with AI';

  @override
  String get settingsAiConsentSubtitle =>
      'Your words are sent to an AI partner for analysis then returned to you. Nothing is shared elsewhere.';

  @override
  String get captureInputPlaceholder => 'What\'s on your mind?';

  @override
  String get captureSubmitButton => 'Set it down';

  @override
  String get captureSuccess => 'Noted. Your mind feels a little lighter.';

  @override
  String get capturePendingLabel => 'Pending';

  @override
  String get homeEmptyBackpack =>
      'Your backpack is light. Set down whatever is weighing on you.';

  @override
  String get weightKgLabel => 'kg';

  @override
  String get categoryAdministrative => 'Administrative';

  @override
  String get categoryFamily => 'Family';

  @override
  String get categoryHealth => 'Health';

  @override
  String get categoryWork => 'Work';

  @override
  String get categoryFinance => 'Finance';

  @override
  String get categoryHome => 'Home';

  @override
  String get categoryPersonal => 'Personal';

  @override
  String get categoryTravel => 'Travel';

  @override
  String get categoryOther => 'Other';

  @override
  String get crisisTitle => 'We\'re here for you';

  @override
  String get crisisBody =>
      'What you\'re going through matters. Kind people are ready to listen, right now.';

  @override
  String get crisisDismiss => 'Close';

  @override
  String get crisisResourceFrSuicide => 'Suicide prevention — 24/7, free';

  @override
  String get crisisResourceFrSamu => 'SAMU — medical emergency';

  @override
  String get crisisResourceEnLifeline => 'Suicide & Crisis Lifeline (US)';

  @override
  String get crisisResourceEnSamaritans => 'Samaritans (UK & Ireland)';

  @override
  String get analysisFallbackNote =>
      'We tucked this away for you while things settle.';

  @override
  String get analysisNoConsentNote =>
      'Analysis is paused until you turn on AI.';

  @override
  String get editSheetTitle => 'Edit preoccupation';

  @override
  String get editSheetSaveButton => 'Save';

  @override
  String get editSheetDeleteButton => 'Delete';

  @override
  String get editSuccess => 'Preoccupation updated.';

  @override
  String get deleteConfirmTitle => 'Delete this preoccupation?';

  @override
  String get deleteConfirmBody =>
      'It will be permanently removed from your backpack.';

  @override
  String get deleteConfirmCta => 'Delete';

  @override
  String get deleteSuccess => 'Preoccupation deleted.';

  @override
  String get mentalLoadCaption => 'on your shoulders';

  @override
  String mentalLoadSemanticLabel(int totalKg) {
    return '$totalKg kg on your shoulders';
  }

  @override
  String backpackSemanticLabel(String band) {
    return 'Backpack $band';
  }

  @override
  String get loadBandLeger => 'light';

  @override
  String get loadBandModere => 'moderate';

  @override
  String get loadBandLourd => 'heavy';

  @override
  String get loadBandTresLourd => 'very heavy';

  @override
  String get statPillOpenCountLabel => 'in progress';

  @override
  String statPillKgFreedValue(int kg) {
    return '$kg kg';
  }

  @override
  String get statPillKgFreedLabel => 'freed this week';

  @override
  String get dailyMissionTitle => 'Daily mission';

  @override
  String get dailyMissionEmptyState => 'Nothing urgent today. Enjoy.';

  @override
  String dailyMissionEstimatedDuration(int minutes) {
    return 'Estimated duration: $minutes min';
  }

  @override
  String dailyMissionEstimatedKgGain(int kg) {
    return 'Estimated relief: $kg kg';
  }
}
