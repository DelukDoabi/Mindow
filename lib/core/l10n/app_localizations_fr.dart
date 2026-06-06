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

  @override
  String get onboardingContinue => 'Continuer';

  @override
  String get onboardingContextTitle => 'Parle-nous un peu de toi';

  @override
  String get onboardingContextSubtitle =>
      'Tout est optionnel — ça nous aide juste à personnaliser.';

  @override
  String get onboardingAgeRangeLabel => 'Ta tranche d\'âge';

  @override
  String get onboardingAgeUnder25 => 'Moins de 25 ans';

  @override
  String get onboardingAge25to34 => '25–34 ans';

  @override
  String get onboardingAge35to44 => '35–44 ans';

  @override
  String get onboardingAge45to54 => '45–54 ans';

  @override
  String get onboardingAgeOver55 => '55 ans et plus';

  @override
  String get onboardingFamilyLabel => 'Ta situation familiale';

  @override
  String get onboardingFamilySingle => 'Célibataire';

  @override
  String get onboardingFamilyCouple => 'En couple';

  @override
  String get onboardingFamilyWithChildren => 'Avec enfants';

  @override
  String get onboardingFamilySingleParent => 'Parent solo';

  @override
  String get onboardingStressLabel => 'Ton niveau de stress en ce moment';

  @override
  String get onboardingStressLow => 'Léger';

  @override
  String get onboardingStressModerate => 'Modéré';

  @override
  String get onboardingStressHigh => 'Élevé';

  @override
  String get onboardingStressVeryHigh => 'Très élevé';

  @override
  String get onboardingMindVolumeTitle =>
      'Combien de sujets occupent ton esprit ?';

  @override
  String get onboardingMindVolumeSubtitle =>
      'Une estimation suffit. Aucune mauvaise réponse.';

  @override
  String get onboardingMindVolumeUpTo10 => '0 à 10';

  @override
  String get onboardingMindVolume10to20 => '10 à 20';

  @override
  String get onboardingMindVolume20to50 => '20 à 50';

  @override
  String get onboardingMindVolumeOver50 => 'Plus de 50';

  @override
  String get accountTitle => 'Garde tes progrès';

  @override
  String get accountSubtitle =>
      'Crée ton compte pour garder ton sac à dos avec toi, sur tous tes appareils.';

  @override
  String get accountContinueWithApple => 'Continuer avec Apple';

  @override
  String get accountContinueWithGoogle => 'Continuer avec Google';

  @override
  String get accountContinueWithEmail => 'Continuer avec un e-mail';

  @override
  String get accountEmailLabel => 'E-mail';

  @override
  String get accountEmailHint => 'toi@exemple.com';

  @override
  String get accountPasswordLabel => 'Mot de passe';

  @override
  String get accountAuthError => 'Petit souci de connexion. On réessaie ?';

  @override
  String get consentTitle => 'Tes mots restent à toi';

  @override
  String get consentBody =>
      'Pour t\'aider à porter moins, ce que tu écris est envoyé à notre partenaire d\'IA pour être analysé, puis te revient. Rien n\'est partagé ailleurs, et tu peux tout exporter ou supprimer quand tu veux.';

  @override
  String get consentAccept => 'J\'ai compris, j\'accepte';
}
