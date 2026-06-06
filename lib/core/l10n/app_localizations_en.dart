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
}
