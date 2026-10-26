// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get welcomeTitle => 'Te damos la bienvenida a Anatomo';

  @override
  String get welcomeSubtitle =>
      'Elige tu idioma. Puedes cambiarlo cuando quieras en Ajustes.';

  @override
  String get continueButton => 'Continuar';

  @override
  String get offlineNote => 'Funciona sin conexión · Sin cuenta · Sin rastreo';

  @override
  String get male => 'Hombre';

  @override
  String get female => 'Mujer';

  @override
  String get layerOrgans => 'Órganos';

  @override
  String get layerBones => 'Huesos';

  @override
  String get layerMuscles => 'Músculos';

  @override
  String get layerNerves => 'Nervios';

  @override
  String get layerVessels => 'Vasos';

  @override
  String get layerSkin => 'Cuerpo';

  @override
  String get viewFront => 'Frente';

  @override
  String get viewBack => 'Espalda';

  @override
  String get viewSide => 'Lado';

  @override
  String get resetView => 'Restablecer vista';

  @override
  String get spreadApart => 'Separar';

  @override
  String get assembled => 'Montado';

  @override
  String get hint =>
      'Arrastra para girar · pellizca para acercar · toca cualquier parte';

  @override
  String loading(int percent) {
    return 'Cargando el cuerpo 3D… $percent%';
  }

  @override
  String get errorWebgl =>
      'Este teléfono no puede mostrar el cuerpo 3D. Actualiza Android System WebView e inténtalo de nuevo.';

  @override
  String get errorLoad => 'No se pudo cargar el cuerpo 3D.';

  @override
  String get retry => 'Reintentar';

  @override
  String get tabAbout => 'Qué hace';

  @override
  String get tabGood => 'Le hace bien';

  @override
  String get tabBad => 'Le hace mal';

  @override
  String partLabel(String name) {
    return 'Parte: $name';
  }

  @override
  String get notMedical => 'Solo para aprender. No es consejo médico.';

  @override
  String get close => 'Cerrar';

  @override
  String get showWholeBody => 'Ver el cuerpo entero';

  @override
  String get searchParts => 'Buscar partes';

  @override
  String get settings => 'Ajustes';

  @override
  String get allParts => 'Todas las partes';

  @override
  String partsCount(int count) {
    return '$count partes';
  }

  @override
  String get searchHint => 'Busca corazón, fémur, hígado…';

  @override
  String get filterAll => 'Todo';

  @override
  String get detailedStructures => 'Estructuras detalladas';

  @override
  String noResults(String query) {
    return 'No se encontró nada para «$query».';
  }

  @override
  String get femaleNote =>
      'El cuerpo femenino muestra los órganos, la piel y parte del esqueleto. El esqueleto completo y los músculos están en el cuerpo masculino.';

  @override
  String get general => 'General';

  @override
  String get language => 'Idioma';

  @override
  String get body => 'Cuerpo';

  @override
  String get updates => 'Actualizaciones';

  @override
  String versionLabel(String version) {
    return 'Anatomo $version';
  }

  @override
  String get checkForUpdates => 'Buscar actualizaciones';

  @override
  String get checking => 'Buscando…';

  @override
  String get upToDate => 'Tienes la última versión.';

  @override
  String updateAvailable(String version) {
    return 'La versión $version está disponible';
  }

  @override
  String get downloadInstall => 'Descargar e instalar';

  @override
  String downloading(int percent) {
    return 'Descargando… $percent%';
  }

  @override
  String get later => 'Más tarde';

  @override
  String get updateFailed =>
      'No se pudieron buscar actualizaciones. Revisa tu conexión a internet e inténtalo de nuevo.';

  @override
  String installFailed(String error) {
    return 'No se pudo instalar la actualización: $error';
  }

  @override
  String get updatesNote =>
      'Anatomo solo usa internet cuando tocas este botón. Las versiones nuevas vienen de las publicaciones de la app en GitHub.';

  @override
  String get about => 'Acerca de';

  @override
  String get sourceCode => 'Código fuente';

  @override
  String get models3d => 'Modelos 3D';

  @override
  String get modelsCredit =>
      'Cuerpo masculino: BodyParts3D 4.0, © The Database Center for Life Science (CC BY 4.0). Cuerpo femenino: HuBMAP 3D Reference Organ Set for Female v1.5, de Kristen Browne y Heidi Schlehlein (CC BY 4.0). Ambos están simplificados para teléfonos. Los pulmones y el hígado del cuerpo masculino se adaptaron del conjunto femenino.';

  @override
  String get privacy => 'Privacidad';

  @override
  String get privacyText =>
      'Anatomo funciona sin conexión. Sin cuenta, sin anuncios, sin rastreo. Nada sobre ti sale de tu teléfono.';

  @override
  String get disclaimerTitle => 'Para aprender';

  @override
  String get disclaimer =>
      'Anatomo está hecha para aprender. No es consejo médico. Habla con un médico sobre tu salud.';
}
