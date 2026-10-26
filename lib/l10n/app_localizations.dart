import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_hy.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

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
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('hy'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('pt'),
    Locale('ru'),
    Locale('zh')
  ];

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Anatomo'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your language. You can change it any time in Settings.'**
  String get welcomeSubtitle;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @offlineNote.
  ///
  /// In en, this message translates to:
  /// **'Works offline · No account · No tracking'**
  String get offlineNote;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @layerOrgans.
  ///
  /// In en, this message translates to:
  /// **'Organs'**
  String get layerOrgans;

  /// No description provided for @layerBones.
  ///
  /// In en, this message translates to:
  /// **'Bones'**
  String get layerBones;

  /// No description provided for @layerMuscles.
  ///
  /// In en, this message translates to:
  /// **'Muscles'**
  String get layerMuscles;

  /// No description provided for @layerNerves.
  ///
  /// In en, this message translates to:
  /// **'Nerves'**
  String get layerNerves;

  /// No description provided for @layerVessels.
  ///
  /// In en, this message translates to:
  /// **'Vessels'**
  String get layerVessels;

  /// No description provided for @layerSkin.
  ///
  /// In en, this message translates to:
  /// **'Body'**
  String get layerSkin;

  /// No description provided for @viewFront.
  ///
  /// In en, this message translates to:
  /// **'Front'**
  String get viewFront;

  /// No description provided for @viewBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get viewBack;

  /// No description provided for @viewSide.
  ///
  /// In en, this message translates to:
  /// **'Side'**
  String get viewSide;

  /// No description provided for @resetView.
  ///
  /// In en, this message translates to:
  /// **'Reset view'**
  String get resetView;

  /// No description provided for @spreadApart.
  ///
  /// In en, this message translates to:
  /// **'Spread apart'**
  String get spreadApart;

  /// No description provided for @assembled.
  ///
  /// In en, this message translates to:
  /// **'Assembled'**
  String get assembled;

  /// No description provided for @hint.
  ///
  /// In en, this message translates to:
  /// **'Drag to rotate · pinch to zoom · tap any part'**
  String get hint;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading the 3D body… {percent}%'**
  String loading(int percent);

  /// No description provided for @errorWebgl.
  ///
  /// In en, this message translates to:
  /// **'This phone can\'t show the 3D body. Please update Android System WebView and try again.'**
  String get errorWebgl;

  /// No description provided for @errorLoad.
  ///
  /// In en, this message translates to:
  /// **'The 3D body could not be loaded.'**
  String get errorLoad;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @tabAbout.
  ///
  /// In en, this message translates to:
  /// **'What it does'**
  String get tabAbout;

  /// No description provided for @tabGood.
  ///
  /// In en, this message translates to:
  /// **'Good for it'**
  String get tabGood;

  /// No description provided for @tabBad.
  ///
  /// In en, this message translates to:
  /// **'Bad for it'**
  String get tabBad;

  /// No description provided for @partLabel.
  ///
  /// In en, this message translates to:
  /// **'Part: {name}'**
  String partLabel(String name);

  /// No description provided for @notMedical.
  ///
  /// In en, this message translates to:
  /// **'For learning only. Not medical advice.'**
  String get notMedical;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @showWholeBody.
  ///
  /// In en, this message translates to:
  /// **'Show the whole body'**
  String get showWholeBody;

  /// No description provided for @searchParts.
  ///
  /// In en, this message translates to:
  /// **'Search parts'**
  String get searchParts;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @allParts.
  ///
  /// In en, this message translates to:
  /// **'All parts'**
  String get allParts;

  /// No description provided for @partsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} parts'**
  String partsCount(int count);

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search heart, femur, liver…'**
  String get searchHint;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @detailedStructures.
  ///
  /// In en, this message translates to:
  /// **'Detailed structures'**
  String get detailedStructures;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'Nothing found for “{query}”.'**
  String noResults(String query);

  /// No description provided for @femaleNote.
  ///
  /// In en, this message translates to:
  /// **'The skeleton and muscles of the female body are adapted from the male body.'**
  String get femaleNote;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @themeAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get themeAuto;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @quality.
  ///
  /// In en, this message translates to:
  /// **'Graphics'**
  String get quality;

  /// No description provided for @qualityAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get qualityAuto;

  /// No description provided for @qualityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get qualityLow;

  /// No description provided for @qualityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get qualityMedium;

  /// No description provided for @qualityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get qualityHigh;

  /// No description provided for @qualityNote.
  ///
  /// In en, this message translates to:
  /// **'Lower quality runs faster on older phones. Auto picks the best level for your phone. The 3D view reloads when you change this.'**
  String get qualityNote;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @noFavorites.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet. Tap the star on a part to add it here.'**
  String get noFavorites;

  /// No description provided for @addFavorite.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get addFavorite;

  /// No description provided for @removeFavorite.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get removeFavorite;

  /// No description provided for @copyText.
  ///
  /// In en, this message translates to:
  /// **'Copy text'**
  String get copyText;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied to the clipboard'**
  String get copied;

  /// No description provided for @quiz.
  ///
  /// In en, this message translates to:
  /// **'Quiz'**
  String get quiz;

  /// No description provided for @quizWhichPart.
  ///
  /// In en, this message translates to:
  /// **'Which body part is this?'**
  String get quizWhichPart;

  /// No description provided for @quizWhichSystem.
  ///
  /// In en, this message translates to:
  /// **'Which body system does {name} belong to?'**
  String quizWhichSystem(String name);

  /// No description provided for @quizQuestionOf.
  ///
  /// In en, this message translates to:
  /// **'Question {n} of {total}'**
  String quizQuestionOf(int n, int total);

  /// No description provided for @quizCorrect.
  ///
  /// In en, this message translates to:
  /// **'Correct!'**
  String get quizCorrect;

  /// No description provided for @quizWrong.
  ///
  /// In en, this message translates to:
  /// **'Not quite. The answer is {answer}.'**
  String quizWrong(String answer);

  /// No description provided for @quizNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get quizNext;

  /// No description provided for @quizFinish.
  ///
  /// In en, this message translates to:
  /// **'See result'**
  String get quizFinish;

  /// No description provided for @quizScore.
  ///
  /// In en, this message translates to:
  /// **'You got {score} of {total} right'**
  String quizScore(int score, int total);

  /// No description provided for @quizBest.
  ///
  /// In en, this message translates to:
  /// **'Best score: {best}'**
  String quizBest(int best);

  /// No description provided for @quizPlayAgain.
  ///
  /// In en, this message translates to:
  /// **'Play again'**
  String get quizPlayAgain;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @body.
  ///
  /// In en, this message translates to:
  /// **'Body'**
  String get body;

  /// No description provided for @updates.
  ///
  /// In en, this message translates to:
  /// **'Updates'**
  String get updates;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Anatomo {version}'**
  String versionLabel(String version);

  /// No description provided for @checkForUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check for updates'**
  String get checkForUpdates;

  /// No description provided for @checking.
  ///
  /// In en, this message translates to:
  /// **'Checking…'**
  String get checking;

  /// No description provided for @upToDate.
  ///
  /// In en, this message translates to:
  /// **'You have the latest version.'**
  String get upToDate;

  /// No description provided for @updateAvailable.
  ///
  /// In en, this message translates to:
  /// **'Version {version} is available'**
  String updateAvailable(String version);

  /// No description provided for @downloadInstall.
  ///
  /// In en, this message translates to:
  /// **'Download and install'**
  String get downloadInstall;

  /// No description provided for @downloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading… {percent}%'**
  String downloading(int percent);

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @updateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not check for updates. Check your internet connection and try again.'**
  String get updateFailed;

  /// No description provided for @installFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not install the update: {error}'**
  String installFailed(String error);

  /// No description provided for @updatesNote.
  ///
  /// In en, this message translates to:
  /// **'Anatomo uses the internet only when you tap this button. New versions come from the app\'s GitHub releases.'**
  String get updatesNote;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @sourceCode.
  ///
  /// In en, this message translates to:
  /// **'Source code'**
  String get sourceCode;

  /// No description provided for @models3d.
  ///
  /// In en, this message translates to:
  /// **'3D models'**
  String get models3d;

  /// No description provided for @modelsCredit.
  ///
  /// In en, this message translates to:
  /// **'Male body: BodyParts3D 4.0, © The Database Center for Life Science (CC BY 4.0). Female body: HuBMAP 3D Reference Organ Set for Female v1.5, by Kristen Browne and Heidi Schlehlein (CC BY 4.0). Both are simplified for phones. The lungs and liver of the male body are fitted from the female set. The skeleton and muscles of the female body are adapted from the male body.'**
  String get modelsCredit;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @privacyText.
  ///
  /// In en, this message translates to:
  /// **'Anatomo works offline. No account, no ads, no tracking. Nothing about you leaves your device.'**
  String get privacyText;

  /// No description provided for @disclaimerTitle.
  ///
  /// In en, this message translates to:
  /// **'For learning'**
  String get disclaimerTitle;

  /// No description provided for @disclaimer.
  ///
  /// In en, this message translates to:
  /// **'Anatomo is made for learning. It is not medical advice. Talk to a doctor about your health.'**
  String get disclaimer;

  /// No description provided for @hint2d.
  ///
  /// In en, this message translates to:
  /// **'Tap any part · pinch to zoom'**
  String get hint2d;

  /// No description provided for @hintDesktop.
  ///
  /// In en, this message translates to:
  /// **'Click a part · scroll to zoom · drag to move'**
  String get hintDesktop;

  /// No description provided for @hiddenHere.
  ///
  /// In en, this message translates to:
  /// **'This part can\'t be seen from this side. Try another side, or switch off the layers in front of it.'**
  String get hiddenHere;

  /// No description provided for @fittedFromMale.
  ///
  /// In en, this message translates to:
  /// **'In the female body, this part is adapted from the male body.'**
  String get fittedFromMale;

  /// No description provided for @fittedFromFemale.
  ///
  /// In en, this message translates to:
  /// **'In the male body, this part is adapted from the female body.'**
  String get fittedFromFemale;

  /// No description provided for @layers.
  ///
  /// In en, this message translates to:
  /// **'Layers'**
  String get layers;

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// No description provided for @selectPartTitle.
  ///
  /// In en, this message translates to:
  /// **'Click any part of the body'**
  String get selectPartTitle;

  /// No description provided for @selectPartText.
  ///
  /// In en, this message translates to:
  /// **'Its card opens here: what it does, what is good for it and what harms it.'**
  String get selectPartText;

  /// No description provided for @keyboard.
  ///
  /// In en, this message translates to:
  /// **'Keyboard'**
  String get keyboard;

  /// No description provided for @zoomIn.
  ///
  /// In en, this message translates to:
  /// **'Zoom in'**
  String get zoomIn;

  /// No description provided for @zoomOut.
  ///
  /// In en, this message translates to:
  /// **'Zoom out'**
  String get zoomOut;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @pack3dTitle.
  ///
  /// In en, this message translates to:
  /// **'3D pack'**
  String get pack3dTitle;

  /// No description provided for @pack3dNote.
  ///
  /// In en, this message translates to:
  /// **'Turn the body and spread it apart in 3D. Downloads once (about {size} MB), then works offline.'**
  String pack3dNote(int size);

  /// No description provided for @pack3dDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get pack3dDownload;

  /// No description provided for @pack3dReady.
  ///
  /// In en, this message translates to:
  /// **'The 3D pack is installed. Switch between 2D and 3D under the body.'**
  String get pack3dReady;

  /// No description provided for @pack3dRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get pack3dRemove;

  /// No description provided for @pack3dFailed.
  ///
  /// In en, this message translates to:
  /// **'The 3D pack could not be downloaded. Check the internet connection and try again.'**
  String get pack3dFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'ar',
        'de',
        'en',
        'es',
        'fr',
        'hi',
        'hy',
        'it',
        'ja',
        'ko',
        'pt',
        'ru',
        'zh'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'hy':
      return AppLocalizationsHy();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
