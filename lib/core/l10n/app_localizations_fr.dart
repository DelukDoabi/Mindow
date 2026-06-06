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
}
