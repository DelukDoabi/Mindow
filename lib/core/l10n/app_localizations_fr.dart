// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Mindow';

  @override
  String get homeWelcomeTitle => 'Bienvenue sur Mindow';

  @override
  String get homeWelcomeBody =>
      'Ton sac à dos est prêt. Bientôt, tu allégeras ta charge mentale ici.';

  @override
  String get onboardingWelcomeHeadline =>
      'Décharge ton esprit. On s\'occupe du reste.';

  @override
  String get onboardingWelcomeBody =>
      'Dépose tout ce qui occupe ton esprit. Mindow t\'aide à porter moins, un objet à la fois.';

  @override
  String get onboardingWelcomeCta => 'Commencer';

  @override
  String get onboardingSkip => 'Passer';
}
