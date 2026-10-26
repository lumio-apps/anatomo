// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get welcomeTitle => 'Benvenuto in Anatomo';

  @override
  String get welcomeSubtitle =>
      'Scegli la lingua. Puoi cambiarla quando vuoi nelle impostazioni.';

  @override
  String get continueButton => 'Continua';

  @override
  String get offlineNote =>
      'Funziona offline · Senza account · Senza tracciamento';

  @override
  String get male => 'Uomo';

  @override
  String get female => 'Donna';

  @override
  String get layerOrgans => 'Organi';

  @override
  String get layerBones => 'Ossa';

  @override
  String get layerMuscles => 'Muscoli';

  @override
  String get layerNerves => 'Nervi';

  @override
  String get layerVessels => 'Vasi';

  @override
  String get layerSkin => 'Corpo';

  @override
  String get viewFront => 'Fronte';

  @override
  String get viewBack => 'Retro';

  @override
  String get viewSide => 'Lato';

  @override
  String get resetView => 'Ripristina vista';

  @override
  String get spreadApart => 'Separa';

  @override
  String get assembled => 'Assemblato';

  @override
  String get hint =>
      'Trascina per ruotare · pizzica per ingrandire · tocca una parte';

  @override
  String loading(int percent) {
    return 'Caricamento del corpo 3D… $percent%';
  }

  @override
  String get errorWebgl =>
      'Questo telefono non riesce a mostrare il corpo 3D. Aggiorna Android System WebView e riprova.';

  @override
  String get errorLoad => 'Impossibile caricare il corpo 3D.';

  @override
  String get retry => 'Riprova';

  @override
  String get tabAbout => 'Cosa fa';

  @override
  String get tabGood => 'Fa bene';

  @override
  String get tabBad => 'Fa male';

  @override
  String partLabel(String name) {
    return 'Parte: $name';
  }

  @override
  String get notMedical => 'Solo per imparare. Non è un consiglio medico.';

  @override
  String get close => 'Chiudi';

  @override
  String get showWholeBody => 'Mostra tutto il corpo';

  @override
  String get searchParts => 'Cerca parti';

  @override
  String get settings => 'Impostazioni';

  @override
  String get allParts => 'Tutte le parti';

  @override
  String partsCount(int count) {
    return '$count parti';
  }

  @override
  String get searchHint => 'Cerca cuore, femore, fegato…';

  @override
  String get filterAll => 'Tutto';

  @override
  String get detailedStructures => 'Strutture dettagliate';

  @override
  String noResults(String query) {
    return 'Nessun risultato per «$query».';
  }

  @override
  String get femaleNote =>
      'Lo scheletro e i muscoli del corpo femminile sono adattati dal corpo maschile.';

  @override
  String get general => 'Generali';

  @override
  String get appearance => 'Aspetto';

  @override
  String get themeAuto => 'Auto';

  @override
  String get themeLight => 'Chiaro';

  @override
  String get themeDark => 'Scuro';

  @override
  String get quality => 'Grafica';

  @override
  String get qualityAuto => 'Auto';

  @override
  String get qualityLow => 'Bassa';

  @override
  String get qualityMedium => 'Media';

  @override
  String get qualityHigh => 'Alta';

  @override
  String get qualityNote =>
      'Una qualità più bassa è più veloce sui telefoni meno recenti. Auto sceglie il livello migliore per il tuo telefono. La vista 3D si ricarica quando cambi questa impostazione.';

  @override
  String get favorites => 'Preferiti';

  @override
  String get noFavorites =>
      'Ancora nessun preferito. Tocca la stella su una parte per aggiungerla qui.';

  @override
  String get addFavorite => 'Aggiungi ai preferiti';

  @override
  String get removeFavorite => 'Rimuovi dai preferiti';

  @override
  String get copyText => 'Copia testo';

  @override
  String get copied => 'Copiato negli appunti';

  @override
  String get quiz => 'Quiz';

  @override
  String get quizWhichPart => 'Che parte del corpo è questa?';

  @override
  String quizWhichSystem(String name) {
    return 'A quale sistema del corpo appartiene: $name?';
  }

  @override
  String quizQuestionOf(int n, int total) {
    return 'Domanda $n di $total';
  }

  @override
  String get quizCorrect => 'Esatto!';

  @override
  String quizWrong(String answer) {
    return 'Non proprio. La risposta è $answer.';
  }

  @override
  String get quizNext => 'Avanti';

  @override
  String get quizFinish => 'Vedi il risultato';

  @override
  String quizScore(int score, int total) {
    return 'Hai risposto bene a $score su $total';
  }

  @override
  String quizBest(int best) {
    return 'Punteggio migliore: $best';
  }

  @override
  String get quizPlayAgain => 'Gioca ancora';

  @override
  String get language => 'Lingua';

  @override
  String get body => 'Corpo';

  @override
  String get updates => 'Aggiornamenti';

  @override
  String versionLabel(String version) {
    return 'Anatomo $version';
  }

  @override
  String get checkForUpdates => 'Cerca aggiornamenti';

  @override
  String get checking => 'Ricerca in corso…';

  @override
  String get upToDate => 'Hai l\'ultima versione.';

  @override
  String updateAvailable(String version) {
    return 'È disponibile la versione $version';
  }

  @override
  String get downloadInstall => 'Scarica e installa';

  @override
  String downloading(int percent) {
    return 'Download in corso… $percent%';
  }

  @override
  String get later => 'Più tardi';

  @override
  String get updateFailed =>
      'Impossibile cercare aggiornamenti. Controlla la connessione a internet e riprova.';

  @override
  String installFailed(String error) {
    return 'Impossibile installare l\'aggiornamento: $error';
  }

  @override
  String get updatesNote =>
      'Anatomo usa internet solo quando tocchi questo pulsante. Le nuove versioni arrivano dalle release dell\'app su GitHub.';

  @override
  String get about => 'Informazioni';

  @override
  String get sourceCode => 'Codice sorgente';

  @override
  String get models3d => 'Modelli 3D';

  @override
  String get modelsCredit =>
      'Corpo maschile: BodyParts3D 4.0, © The Database Center for Life Science (CC BY 4.0). Corpo femminile: HuBMAP 3D Reference Organ Set for Female v1.5, di Kristen Browne e Heidi Schlehlein (CC BY 4.0). Entrambi sono semplificati per i telefoni. Polmoni e fegato del corpo maschile sono adattati dal set femminile. Lo scheletro e i muscoli del corpo femminile sono adattati dal corpo maschile.';

  @override
  String get privacy => 'Privacy';

  @override
  String get privacyText =>
      'Anatomo funziona offline. Nessun account, nessuna pubblicità, nessun tracciamento. Niente su di te lascia il dispositivo.';

  @override
  String get disclaimerTitle => 'Per imparare';

  @override
  String get disclaimer =>
      'Anatomo è fatto per imparare. Non è un consiglio medico. Parla della tua salute con un medico.';

  @override
  String get hint2d => 'Tocca una parte · pizzica per ingrandire';

  @override
  String get hintDesktop =>
      'Fai clic su una parte · rotellina per ingrandire · trascina per spostare';

  @override
  String get hiddenHere =>
      'Questa parte non si vede da questo lato. Prova un altro lato o spegni gli strati davanti.';

  @override
  String get fittedFromMale =>
      'Nel corpo femminile, questa parte è adattata dal corpo maschile.';

  @override
  String get fittedFromFemale =>
      'Nel corpo maschile, questa parte è adattata dal corpo femminile.';

  @override
  String get layers => 'Strati';

  @override
  String get explore => 'Esplora';

  @override
  String get selectPartTitle => 'Fai clic su una parte del corpo';

  @override
  String get selectPartText =>
      'Qui si apre la sua scheda: cosa fa, cosa le fa bene e cosa le fa male.';

  @override
  String get keyboard => 'Tastiera';

  @override
  String get zoomIn => 'Ingrandisci';

  @override
  String get zoomOut => 'Riduci';

  @override
  String get cancel => 'Annulla';

  @override
  String get pack3dTitle => 'Pacchetto 3D';

  @override
  String pack3dNote(int size) {
    return 'Ruota il corpo e separane le parti in 3D. Si scarica una volta (circa $size MB), poi funziona offline.';
  }

  @override
  String get pack3dDownload => 'Scarica';

  @override
  String get pack3dReady =>
      'Il pacchetto 3D è installato. Passa da 2D a 3D sotto il corpo.';

  @override
  String get pack3dRemove => 'Rimuovi';

  @override
  String get pack3dFailed =>
      'Impossibile scaricare il pacchetto 3D. Controlla la connessione a internet e riprova.';
}
