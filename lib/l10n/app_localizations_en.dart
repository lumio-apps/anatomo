// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get welcomeTitle => 'Welcome to Anatomo';

  @override
  String get welcomeSubtitle =>
      'Choose your language. You can change it any time in Settings.';

  @override
  String get continueButton => 'Continue';

  @override
  String get offlineNote => 'Works offline · No account · No tracking';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get layerOrgans => 'Organs';

  @override
  String get layerBones => 'Bones';

  @override
  String get layerMuscles => 'Muscles';

  @override
  String get layerNerves => 'Nerves';

  @override
  String get layerVessels => 'Vessels';

  @override
  String get layerSkin => 'Body';

  @override
  String get viewFront => 'Front';

  @override
  String get viewBack => 'Back';

  @override
  String get viewSide => 'Side';

  @override
  String get resetView => 'Reset view';

  @override
  String get spreadApart => 'Spread apart';

  @override
  String get assembled => 'Assembled';

  @override
  String get hint => 'Drag to rotate · pinch to zoom · tap any part';

  @override
  String loading(int percent) {
    return 'Loading the 3D body… $percent%';
  }

  @override
  String get errorWebgl =>
      'This phone can\'t show the 3D body. Please update Android System WebView and try again.';

  @override
  String get errorLoad => 'The 3D body could not be loaded.';

  @override
  String get retry => 'Try again';

  @override
  String get tabAbout => 'What it does';

  @override
  String get tabGood => 'Good for it';

  @override
  String get tabBad => 'Bad for it';

  @override
  String partLabel(String name) {
    return 'Part: $name';
  }

  @override
  String get notMedical => 'For learning only. Not medical advice.';

  @override
  String get close => 'Close';

  @override
  String get showWholeBody => 'Show the whole body';

  @override
  String get searchParts => 'Search parts';

  @override
  String get settings => 'Settings';

  @override
  String get allParts => 'All parts';

  @override
  String partsCount(int count) {
    return '$count parts';
  }

  @override
  String get searchHint => 'Search heart, femur, liver…';

  @override
  String get filterAll => 'All';

  @override
  String get detailedStructures => 'Detailed structures';

  @override
  String noResults(String query) {
    return 'Nothing found for “$query”.';
  }

  @override
  String get femaleNote =>
      'The female body shows the organs, the skin and part of the skeleton. The full skeleton and the muscles are in the male body.';

  @override
  String get general => 'General';

  @override
  String get appearance => 'Appearance';

  @override
  String get themeAuto => 'Auto';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get quality => 'Graphics';

  @override
  String get qualityAuto => 'Auto';

  @override
  String get qualityLow => 'Low';

  @override
  String get qualityMedium => 'Medium';

  @override
  String get qualityHigh => 'High';

  @override
  String get qualityNote =>
      'Lower quality runs faster on older phones. Auto picks the best level for your phone. The 3D view reloads when you change this.';

  @override
  String get language => 'Language';

  @override
  String get body => 'Body';

  @override
  String get updates => 'Updates';

  @override
  String versionLabel(String version) {
    return 'Anatomo $version';
  }

  @override
  String get checkForUpdates => 'Check for updates';

  @override
  String get checking => 'Checking…';

  @override
  String get upToDate => 'You have the latest version.';

  @override
  String updateAvailable(String version) {
    return 'Version $version is available';
  }

  @override
  String get downloadInstall => 'Download and install';

  @override
  String downloading(int percent) {
    return 'Downloading… $percent%';
  }

  @override
  String get later => 'Later';

  @override
  String get updateFailed =>
      'Could not check for updates. Check your internet connection and try again.';

  @override
  String installFailed(String error) {
    return 'Could not install the update: $error';
  }

  @override
  String get updatesNote =>
      'Anatomo uses the internet only when you tap this button. New versions come from the app\'s GitHub releases.';

  @override
  String get about => 'About';

  @override
  String get sourceCode => 'Source code';

  @override
  String get models3d => '3D models';

  @override
  String get modelsCredit =>
      'Male body: BodyParts3D 4.0, © The Database Center for Life Science (CC BY 4.0). Female body: HuBMAP 3D Reference Organ Set for Female v1.5, by Kristen Browne and Heidi Schlehlein (CC BY 4.0). Both are simplified for phones. The lungs and liver of the male body are fitted from the female set.';

  @override
  String get privacy => 'Privacy';

  @override
  String get privacyText =>
      'Anatomo works offline. No account, no ads, no tracking. Nothing about you leaves your phone.';

  @override
  String get disclaimerTitle => 'For learning';

  @override
  String get disclaimer =>
      'Anatomo is made for learning. It is not medical advice. Talk to a doctor about your health.';
}
