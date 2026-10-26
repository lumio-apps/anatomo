// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get welcomeTitle => 'Willkommen bei Anatomo';

  @override
  String get welcomeSubtitle =>
      'Wähle deine Sprache. Du kannst sie jederzeit in den Einstellungen ändern.';

  @override
  String get continueButton => 'Weiter';

  @override
  String get offlineNote => 'Funktioniert offline · Kein Konto · Kein Tracking';

  @override
  String get male => 'Mann';

  @override
  String get female => 'Frau';

  @override
  String get layerOrgans => 'Organe';

  @override
  String get layerBones => 'Knochen';

  @override
  String get layerMuscles => 'Muskeln';

  @override
  String get layerNerves => 'Nerven';

  @override
  String get layerVessels => 'Gefäße';

  @override
  String get layerSkin => 'Körper';

  @override
  String get viewFront => 'Vorne';

  @override
  String get viewBack => 'Hinten';

  @override
  String get viewSide => 'Seite';

  @override
  String get resetView => 'Ansicht zurücksetzen';

  @override
  String get spreadApart => 'Auseinanderziehen';

  @override
  String get assembled => 'Zusammengesetzt';

  @override
  String get hint =>
      'Ziehen zum Drehen · zwei Finger zum Zoomen · tippe auf einen Teil';

  @override
  String loading(int percent) {
    return 'Der 3D-Körper wird geladen… $percent %';
  }

  @override
  String get errorWebgl =>
      'Dieses Handy kann den 3D-Körper nicht anzeigen. Bitte aktualisiere Android System WebView und versuche es erneut.';

  @override
  String get errorLoad => 'Der 3D-Körper konnte nicht geladen werden.';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get tabAbout => 'Was es tut';

  @override
  String get tabGood => 'Gut dafür';

  @override
  String get tabBad => 'Schlecht dafür';

  @override
  String partLabel(String name) {
    return 'Teil: $name';
  }

  @override
  String get notMedical => 'Nur zum Lernen. Kein ärztlicher Rat.';

  @override
  String get close => 'Schließen';

  @override
  String get showWholeBody => 'Ganzen Körper zeigen';

  @override
  String get searchParts => 'Teile suchen';

  @override
  String get settings => 'Einstellungen';

  @override
  String get allParts => 'Alle Teile';

  @override
  String partsCount(int count) {
    return '$count Teile';
  }

  @override
  String get searchHint => 'Suche Herz, Oberschenkelknochen, Leber…';

  @override
  String get filterAll => 'Alle';

  @override
  String get detailedStructures => 'Detaillierte Strukturen';

  @override
  String noResults(String query) {
    return 'Nichts gefunden für „$query“.';
  }

  @override
  String get femaleNote =>
      'Der weibliche Körper zeigt die Organe, die Haut und einen Teil des Skeletts. Das ganze Skelett und die Muskeln gibt es im männlichen Körper.';

  @override
  String get general => 'Allgemein';

  @override
  String get appearance => 'Darstellung';

  @override
  String get themeAuto => 'Auto';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get quality => 'Grafik';

  @override
  String get qualityAuto => 'Auto';

  @override
  String get qualityLow => 'Niedrig';

  @override
  String get qualityMedium => 'Mittel';

  @override
  String get qualityHigh => 'Hoch';

  @override
  String get qualityNote =>
      'Niedrigere Qualität läuft auf älteren Handys schneller. Auto wählt die beste Stufe für dein Handy. Die 3D-Ansicht wird beim Ändern neu geladen.';

  @override
  String get favorites => 'Favoriten';

  @override
  String get noFavorites =>
      'Noch keine Favoriten. Tippe auf den Stern bei einem Körperteil, um es hier hinzuzufügen.';

  @override
  String get addFavorite => 'Zu Favoriten hinzufügen';

  @override
  String get removeFavorite => 'Aus Favoriten entfernen';

  @override
  String get copyText => 'Text kopieren';

  @override
  String get copied => 'In die Zwischenablage kopiert';

  @override
  String get quiz => 'Quiz';

  @override
  String get quizWhichPart => 'Welches Körperteil ist das?';

  @override
  String quizWhichSystem(String name) {
    return 'Zu welchem Körpersystem gehört: $name?';
  }

  @override
  String quizQuestionOf(int n, int total) {
    return 'Frage $n von $total';
  }

  @override
  String get quizCorrect => 'Richtig!';

  @override
  String quizWrong(String answer) {
    return 'Nicht ganz. Die Antwort ist $answer.';
  }

  @override
  String get quizNext => 'Weiter';

  @override
  String get quizFinish => 'Ergebnis ansehen';

  @override
  String quizScore(int score, int total) {
    return '$score von $total richtig';
  }

  @override
  String quizBest(int best) {
    return 'Bestes Ergebnis: $best';
  }

  @override
  String get quizPlayAgain => 'Nochmal spielen';

  @override
  String get language => 'Sprache';

  @override
  String get body => 'Körper';

  @override
  String get updates => 'Updates';

  @override
  String versionLabel(String version) {
    return 'Anatomo $version';
  }

  @override
  String get checkForUpdates => 'Nach Updates suchen';

  @override
  String get checking => 'Suche läuft…';

  @override
  String get upToDate => 'Du hast die neueste Version.';

  @override
  String updateAvailable(String version) {
    return 'Version $version ist verfügbar';
  }

  @override
  String get downloadInstall => 'Herunterladen und installieren';

  @override
  String downloading(int percent) {
    return 'Wird heruntergeladen… $percent %';
  }

  @override
  String get later => 'Später';

  @override
  String get updateFailed =>
      'Updates konnten nicht gesucht werden. Prüfe deine Internetverbindung und versuche es erneut.';

  @override
  String installFailed(String error) {
    return 'Das Update konnte nicht installiert werden: $error';
  }

  @override
  String get updatesNote =>
      'Anatomo nutzt das Internet nur, wenn du diesen Knopf drückst. Neue Versionen kommen aus den GitHub-Releases der App.';

  @override
  String get about => 'Über';

  @override
  String get sourceCode => 'Quellcode';

  @override
  String get models3d => '3D-Modelle';

  @override
  String get modelsCredit =>
      'Männlicher Körper: BodyParts3D 4.0, © The Database Center for Life Science (CC BY 4.0). Weiblicher Körper: HuBMAP 3D Reference Organ Set for Female v1.5, von Kristen Browne und Heidi Schlehlein (CC BY 4.0). Beide sind für Handys vereinfacht. Lunge und Leber des männlichen Körpers sind aus dem weiblichen Satz angepasst.';

  @override
  String get privacy => 'Datenschutz';

  @override
  String get privacyText =>
      'Anatomo funktioniert offline. Kein Konto, keine Werbung, kein Tracking. Nichts über dich verlässt dein Handy.';

  @override
  String get disclaimerTitle => 'Zum Lernen';

  @override
  String get disclaimer =>
      'Anatomo ist zum Lernen gemacht. Es ist kein ärztlicher Rat. Sprich mit einer Ärztin oder einem Arzt über deine Gesundheit.';
}
