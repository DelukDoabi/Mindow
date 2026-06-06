import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// The application name shown to users
  ///
  /// In en, this message translates to:
  /// **'Mindow'**
  String get appTitle;

  /// Placeholder home screen title used by the scaffold
  ///
  /// In en, this message translates to:
  /// **'Welcome to Mindow'**
  String get homeWelcomeTitle;

  /// Placeholder home screen body copy used by the scaffold
  ///
  /// In en, this message translates to:
  /// **'Your backpack is ready. Soon you\'ll lighten your mental load here.'**
  String get homeWelcomeBody;

  /// Promise headline on the first onboarding (welcome) screen
  ///
  /// In en, this message translates to:
  /// **'Set your mind down. We\'ll carry the rest.'**
  String get onboardingWelcomeHeadline;

  /// Reassuring body copy under the welcome headline
  ///
  /// In en, this message translates to:
  /// **'Put down everything on your mind. Mindow helps you carry less, one thing at a time.'**
  String get onboardingWelcomeBody;

  /// Primary call-to-action on the welcome screen
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingWelcomeCta;

  /// Secondary action that lets the user skip onboarding
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// Primary action that advances to the next onboarding step
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingContinue;

  /// Title of the onboarding context screen
  ///
  /// In en, this message translates to:
  /// **'Tell us a little about you'**
  String get onboardingContextTitle;

  /// Subtitle reassuring the user that context questions are optional
  ///
  /// In en, this message translates to:
  /// **'Everything is optional — it just helps us personalize things.'**
  String get onboardingContextSubtitle;

  /// Label for the age range question
  ///
  /// In en, this message translates to:
  /// **'Your age range'**
  String get onboardingAgeRangeLabel;

  /// Age range option: under 25
  ///
  /// In en, this message translates to:
  /// **'Under 25'**
  String get onboardingAgeUnder25;

  /// Age range option: 25 to 34
  ///
  /// In en, this message translates to:
  /// **'25–34'**
  String get onboardingAge25to34;

  /// Age range option: 35 to 44
  ///
  /// In en, this message translates to:
  /// **'35–44'**
  String get onboardingAge35to44;

  /// Age range option: 45 to 54
  ///
  /// In en, this message translates to:
  /// **'45–54'**
  String get onboardingAge45to54;

  /// Age range option: 55 and over
  ///
  /// In en, this message translates to:
  /// **'55 and over'**
  String get onboardingAgeOver55;

  /// Label for the family situation question
  ///
  /// In en, this message translates to:
  /// **'Your family situation'**
  String get onboardingFamilyLabel;

  /// Family situation option: single
  ///
  /// In en, this message translates to:
  /// **'Single'**
  String get onboardingFamilySingle;

  /// Family situation option: in a couple
  ///
  /// In en, this message translates to:
  /// **'In a relationship'**
  String get onboardingFamilyCouple;

  /// Family situation option: with children
  ///
  /// In en, this message translates to:
  /// **'With children'**
  String get onboardingFamilyWithChildren;

  /// Family situation option: single parent
  ///
  /// In en, this message translates to:
  /// **'Single parent'**
  String get onboardingFamilySingleParent;

  /// Label for the stress level question
  ///
  /// In en, this message translates to:
  /// **'Your stress level right now'**
  String get onboardingStressLabel;

  /// Stress level option: low
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get onboardingStressLow;

  /// Stress level option: moderate
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get onboardingStressModerate;

  /// Stress level option: high
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get onboardingStressHigh;

  /// Stress level option: very high
  ///
  /// In en, this message translates to:
  /// **'Very high'**
  String get onboardingStressVeryHigh;

  /// Title of the mind-volume onboarding screen
  ///
  /// In en, this message translates to:
  /// **'How many things are on your mind?'**
  String get onboardingMindVolumeTitle;

  /// Subtitle reassuring the user about the mind-volume estimate
  ///
  /// In en, this message translates to:
  /// **'A rough guess is plenty. There\'s no wrong answer.'**
  String get onboardingMindVolumeSubtitle;

  /// Mind-volume bucket: up to 10
  ///
  /// In en, this message translates to:
  /// **'0 to 10'**
  String get onboardingMindVolumeUpTo10;

  /// Mind-volume bucket: 10 to 20
  ///
  /// In en, this message translates to:
  /// **'10 to 20'**
  String get onboardingMindVolume10to20;

  /// Mind-volume bucket: 20 to 50
  ///
  /// In en, this message translates to:
  /// **'20 to 50'**
  String get onboardingMindVolume20to50;

  /// Mind-volume bucket: over 50
  ///
  /// In en, this message translates to:
  /// **'More than 50'**
  String get onboardingMindVolumeOver50;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
