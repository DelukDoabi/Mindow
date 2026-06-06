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
}
