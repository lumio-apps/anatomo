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
      'The skeleton and muscles of the female body are adapted from the male body.';

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
  String get favorites => 'Favorites';

  @override
  String get noFavorites =>
      'No favorites yet. Tap the star on a part to add it here.';

  @override
  String get addFavorite => 'Add to favorites';

  @override
  String get removeFavorite => 'Remove from favorites';

  @override
  String get copyText => 'Copy text';

  @override
  String get copied => 'Copied to the clipboard';

  @override
  String get quiz => 'Quiz';

  @override
  String get quizWhichPart => 'Which body part is this?';

  @override
  String quizWhichSystem(String name) {
    return 'Which body system does $name belong to?';
  }

  @override
  String quizQuestionOf(int n, int total) {
    return 'Question $n of $total';
  }

  @override
  String get quizCorrect => 'Correct!';

  @override
  String quizWrong(String answer) {
    return 'Not quite. The answer is $answer.';
  }

  @override
  String get quizNext => 'Next';

  @override
  String get quizFinish => 'See result';

  @override
  String quizScore(int score, int total) {
    return 'You got $score of $total right';
  }

  @override
  String quizBest(int best) {
    return 'Best score: $best';
  }

  @override
  String get quizPlayAgain => 'Play again';

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
      'Male body: BodyParts3D 4.0, © The Database Center for Life Science (CC BY 4.0). Female body: HuBMAP 3D Reference Organ Set for Female v1.5, by Kristen Browne and Heidi Schlehlein (CC BY 4.0). Both are simplified for phones. The lungs and liver of the male body are fitted from the female set. The skeleton and muscles of the female body are adapted from the male body.';

  @override
  String get privacy => 'Privacy';

  @override
  String get privacyText =>
      'Anatomo works offline. No account, no ads, no tracking. Nothing about you leaves your device.';

  @override
  String get disclaimerTitle => 'For learning';

  @override
  String get disclaimer =>
      'Anatomo is made for learning. It is not medical advice. Talk to a doctor about your health.';

  @override
  String get hint2d => 'Tap any part · pinch to zoom';

  @override
  String get hintDesktop => 'Click a part · scroll to zoom · drag to move';

  @override
  String get hiddenHere =>
      'This part can\'t be seen from this side. Try another side, or switch off the layers in front of it.';

  @override
  String get fittedFromMale =>
      'In the female body, this part is adapted from the male body.';

  @override
  String get fittedFromFemale =>
      'In the male body, this part is adapted from the female body.';

  @override
  String get layers => 'Layers';

  @override
  String get explore => 'Explore';

  @override
  String get selectPartTitle => 'Click any part of the body';

  @override
  String get selectPartText =>
      'Its card opens here: what it does, what is good for it and what harms it.';

  @override
  String get keyboard => 'Keyboard';

  @override
  String get zoomIn => 'Zoom in';

  @override
  String get zoomOut => 'Zoom out';

  @override
  String get cancel => 'Cancel';

  @override
  String get pack3dTitle => '3D pack';

  @override
  String pack3dNote(int size) {
    return 'Turn the body and spread it apart in 3D. Downloads once (about $size MB), then works offline.';
  }

  @override
  String get pack3dDownload => 'Download';

  @override
  String get pack3dReady =>
      'The 3D pack is installed. Use the 2D / 3D switch to change the view.';

  @override
  String get pack3dRemove => 'Remove';

  @override
  String get pack3dFailed =>
      'The 3D pack could not be downloaded. Check the internet connection and try again.';

  @override
  String get hint3dDesktop =>
      'Drag to rotate · scroll to zoom · click any part';
}
