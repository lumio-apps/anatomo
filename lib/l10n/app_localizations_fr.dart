// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get welcomeTitle => 'Bienvenue dans Anatomo';

  @override
  String get welcomeSubtitle =>
      'Choisissez votre langue. Vous pouvez la changer à tout moment dans les réglages.';

  @override
  String get continueButton => 'Continuer';

  @override
  String get offlineNote =>
      'Fonctionne hors ligne · Sans compte · Sans pistage';

  @override
  String get male => 'Homme';

  @override
  String get female => 'Femme';

  @override
  String get layerOrgans => 'Organes';

  @override
  String get layerBones => 'Os';

  @override
  String get layerMuscles => 'Muscles';

  @override
  String get layerNerves => 'Nerfs';

  @override
  String get layerVessels => 'Vaisseaux';

  @override
  String get layerSkin => 'Corps';

  @override
  String get viewFront => 'Face';

  @override
  String get viewBack => 'Dos';

  @override
  String get viewSide => 'Profil';

  @override
  String get resetView => 'Réinitialiser la vue';

  @override
  String get spreadApart => 'Écarter';

  @override
  String get assembled => 'Assemblé';

  @override
  String get hint =>
      'Glissez pour tourner · pincez pour zoomer · touchez une partie';

  @override
  String loading(int percent) {
    return 'Chargement du corps 3D… $percent %';
  }

  @override
  String get errorWebgl =>
      'Ce téléphone ne peut pas afficher le corps 3D. Mettez à jour Android System WebView et réessayez.';

  @override
  String get errorLoad => 'Le corps 3D n\'a pas pu être chargé.';

  @override
  String get retry => 'Réessayer';

  @override
  String get tabAbout => 'Son rôle';

  @override
  String get tabGood => 'Ce qui l\'aide';

  @override
  String get tabBad => 'Ce qui lui nuit';

  @override
  String partLabel(String name) {
    return 'Partie : $name';
  }

  @override
  String get notMedical =>
      'Pour apprendre uniquement. Ce n\'est pas un avis médical.';

  @override
  String get close => 'Fermer';

  @override
  String get showWholeBody => 'Voir tout le corps';

  @override
  String get searchParts => 'Rechercher';

  @override
  String get settings => 'Réglages';

  @override
  String get allParts => 'Toutes les parties';

  @override
  String partsCount(int count) {
    return '$count parties';
  }

  @override
  String get searchHint => 'Cherchez cœur, fémur, foie…';

  @override
  String get filterAll => 'Tout';

  @override
  String get detailedStructures => 'Structures détaillées';

  @override
  String noResults(String query) {
    return 'Aucun résultat pour « $query ».';
  }

  @override
  String get femaleNote =>
      'Le squelette et les muscles du corps féminin sont adaptés du corps masculin.';

  @override
  String get general => 'Général';

  @override
  String get appearance => 'Apparence';

  @override
  String get themeAuto => 'Auto';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get quality => 'Graphismes';

  @override
  String get qualityAuto => 'Auto';

  @override
  String get qualityLow => 'Bas';

  @override
  String get qualityMedium => 'Moyen';

  @override
  String get qualityHigh => 'Élevé';

  @override
  String get qualityNote =>
      'Une qualité plus basse est plus fluide sur les anciens téléphones. Auto choisit le meilleur niveau pour votre téléphone. La vue 3D se recharge quand vous changez ce réglage.';

  @override
  String get favorites => 'Favoris';

  @override
  String get noFavorites =>
      'Aucun favori pour l\'instant. Touchez l\'étoile sur une partie pour l\'ajouter ici.';

  @override
  String get addFavorite => 'Ajouter aux favoris';

  @override
  String get removeFavorite => 'Retirer des favoris';

  @override
  String get copyText => 'Copier le texte';

  @override
  String get copied => 'Copié dans le presse-papiers';

  @override
  String get quiz => 'Quiz';

  @override
  String get quizWhichPart => 'De quelle partie du corps s\'agit-il ?';

  @override
  String quizWhichSystem(String name) {
    return 'À quel système du corps appartient : $name ?';
  }

  @override
  String quizQuestionOf(int n, int total) {
    return 'Question $n sur $total';
  }

  @override
  String get quizCorrect => 'Exact !';

  @override
  String quizWrong(String answer) {
    return 'Pas tout à fait. La réponse est $answer.';
  }

  @override
  String get quizNext => 'Suivant';

  @override
  String get quizFinish => 'Voir le résultat';

  @override
  String quizScore(int score, int total) {
    return 'Vous avez $score bonnes réponses sur $total';
  }

  @override
  String quizBest(int best) {
    return 'Meilleur score : $best';
  }

  @override
  String get quizPlayAgain => 'Rejouer';

  @override
  String get language => 'Langue';

  @override
  String get body => 'Corps';

  @override
  String get updates => 'Mises à jour';

  @override
  String versionLabel(String version) {
    return 'Anatomo $version';
  }

  @override
  String get checkForUpdates => 'Rechercher des mises à jour';

  @override
  String get checking => 'Recherche…';

  @override
  String get upToDate => 'Vous avez la dernière version.';

  @override
  String updateAvailable(String version) {
    return 'La version $version est disponible';
  }

  @override
  String get downloadInstall => 'Télécharger et installer';

  @override
  String downloading(int percent) {
    return 'Téléchargement… $percent %';
  }

  @override
  String get later => 'Plus tard';

  @override
  String get updateFailed =>
      'Impossible de rechercher des mises à jour. Vérifiez votre connexion internet et réessayez.';

  @override
  String installFailed(String error) {
    return 'Impossible d\'installer la mise à jour : $error';
  }

  @override
  String get updatesNote =>
      'Anatomo n\'utilise internet que lorsque vous touchez ce bouton. Les nouvelles versions viennent des publications de l\'app sur GitHub.';

  @override
  String get about => 'À propos';

  @override
  String get sourceCode => 'Code source';

  @override
  String get models3d => 'Modèles 3D';

  @override
  String get modelsCredit =>
      'Corps masculin : BodyParts3D 4.0, © The Database Center for Life Science (CC BY 4.0). Corps féminin : HuBMAP 3D Reference Organ Set for Female v1.5, par Kristen Browne et Heidi Schlehlein (CC BY 4.0). Les deux sont simplifiés pour les téléphones. Les poumons et le foie du corps masculin sont adaptés à partir de l\'ensemble féminin. Le squelette et les muscles du corps féminin sont adaptés du corps masculin.';

  @override
  String get privacy => 'Confidentialité';

  @override
  String get privacyText =>
      'Anatomo fonctionne hors ligne. Pas de compte, pas de publicité, pas de pistage. Rien sur vous ne quitte votre appareil.';

  @override
  String get disclaimerTitle => 'Pour apprendre';

  @override
  String get disclaimer =>
      'Anatomo est fait pour apprendre. Ce n\'est pas un avis médical. Parlez de votre santé à un médecin.';

  @override
  String get hint2d => 'Touchez une partie · pincez pour zoomer';

  @override
  String get hintDesktop =>
      'Cliquez sur une partie · molette pour zoomer · faites glisser pour déplacer';

  @override
  String get hiddenHere =>
      'Cette partie n\'est pas visible de ce côté. Essayez un autre côté ou masquez les couches placées devant.';

  @override
  String get fittedFromMale =>
      'Dans le corps féminin, cette partie est adaptée du corps masculin.';

  @override
  String get fittedFromFemale =>
      'Dans le corps masculin, cette partie est adaptée du corps féminin.';

  @override
  String get layers => 'Couches';

  @override
  String get explore => 'Explorer';

  @override
  String get selectPartTitle => 'Cliquez sur une partie du corps';

  @override
  String get selectPartText =>
      'Sa fiche s\'ouvre ici : ce qu\'elle fait, ce qui lui fait du bien et ce qui lui nuit.';

  @override
  String get keyboard => 'Clavier';

  @override
  String get zoomIn => 'Zoom avant';

  @override
  String get zoomOut => 'Zoom arrière';

  @override
  String get cancel => 'Annuler';

  @override
  String get pack3dTitle => 'Pack 3D';

  @override
  String pack3dNote(int size) {
    return 'Faites tourner le corps et écartez ses parties en 3D. Se télécharge une fois (environ $size Mo), puis fonctionne hors ligne.';
  }

  @override
  String get pack3dDownload => 'Télécharger';

  @override
  String get pack3dReady =>
      'Le pack 3D est installé. Utilisez le bouton 2D / 3D pour changer de vue.';

  @override
  String get pack3dRemove => 'Supprimer';

  @override
  String get pack3dFailed =>
      'Le pack 3D n\'a pas pu être téléchargé. Vérifiez la connexion internet et réessayez.';

  @override
  String get hint3dDesktop =>
      'Faites glisser pour tourner · molette pour zoomer · cliquez sur une partie';
}
