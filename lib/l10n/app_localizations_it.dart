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
      'Il corpo femminile mostra gli organi, la pelle e parte dello scheletro. Lo scheletro completo e i muscoli sono nel corpo maschile.';

  @override
  String get general => 'Generali';

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
      'Corpo maschile: BodyParts3D 4.0, © The Database Center for Life Science (CC BY 4.0). Corpo femminile: HuBMAP 3D Reference Organ Set for Female v1.5, di Kristen Browne e Heidi Schlehlein (CC BY 4.0). Entrambi sono semplificati per i telefoni. Polmoni e fegato del corpo maschile sono adattati dal set femminile.';

  @override
  String get privacy => 'Privacy';

  @override
  String get privacyText =>
      'Anatomo funziona offline. Nessun account, nessuna pubblicità, nessun tracciamento. Niente su di te lascia il telefono.';

  @override
  String get disclaimerTitle => 'Per imparare';

  @override
  String get disclaimer =>
      'Anatomo è fatto per imparare. Non è un consiglio medico. Parla della tua salute con un medico.';
}
