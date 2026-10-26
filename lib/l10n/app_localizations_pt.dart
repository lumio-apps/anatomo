// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get welcomeTitle => 'Boas-vindas ao Anatomo';

  @override
  String get welcomeSubtitle =>
      'Escolha o seu idioma. Você pode mudá-lo a qualquer momento nas configurações.';

  @override
  String get continueButton => 'Continuar';

  @override
  String get offlineNote => 'Funciona offline · Sem conta · Sem rastreamento';

  @override
  String get male => 'Masculino';

  @override
  String get female => 'Feminino';

  @override
  String get layerOrgans => 'Órgãos';

  @override
  String get layerBones => 'Ossos';

  @override
  String get layerMuscles => 'Músculos';

  @override
  String get layerNerves => 'Nervos';

  @override
  String get layerVessels => 'Vasos';

  @override
  String get layerSkin => 'Corpo';

  @override
  String get viewFront => 'Frente';

  @override
  String get viewBack => 'Costas';

  @override
  String get viewSide => 'Lado';

  @override
  String get resetView => 'Redefinir vista';

  @override
  String get spreadApart => 'Separar';

  @override
  String get assembled => 'Montado';

  @override
  String get hint =>
      'Arraste para girar · pinça para ampliar · toque em qualquer parte';

  @override
  String loading(int percent) {
    return 'Carregando o corpo 3D… $percent%';
  }

  @override
  String get errorWebgl =>
      'Este telefone não consegue mostrar o corpo 3D. Atualize o Android System WebView e tente de novo.';

  @override
  String get errorLoad => 'Não foi possível carregar o corpo 3D.';

  @override
  String get retry => 'Tentar de novo';

  @override
  String get tabAbout => 'O que faz';

  @override
  String get tabGood => 'Faz bem';

  @override
  String get tabBad => 'Faz mal';

  @override
  String partLabel(String name) {
    return 'Parte: $name';
  }

  @override
  String get notMedical => 'Apenas para aprender. Não é conselho médico.';

  @override
  String get close => 'Fechar';

  @override
  String get showWholeBody => 'Mostrar o corpo inteiro';

  @override
  String get searchParts => 'Buscar partes';

  @override
  String get settings => 'Configurações';

  @override
  String get allParts => 'Todas as partes';

  @override
  String partsCount(int count) {
    return '$count partes';
  }

  @override
  String get searchHint => 'Busque coração, fêmur, fígado…';

  @override
  String get filterAll => 'Tudo';

  @override
  String get detailedStructures => 'Estruturas detalhadas';

  @override
  String noResults(String query) {
    return 'Nada encontrado para “$query”.';
  }

  @override
  String get femaleNote =>
      'O corpo feminino mostra os órgãos, a pele e parte do esqueleto. O esqueleto completo e os músculos estão no corpo masculino.';

  @override
  String get general => 'Geral';

  @override
  String get language => 'Idioma';

  @override
  String get body => 'Corpo';

  @override
  String get updates => 'Atualizações';

  @override
  String versionLabel(String version) {
    return 'Anatomo $version';
  }

  @override
  String get checkForUpdates => 'Procurar atualizações';

  @override
  String get checking => 'Procurando…';

  @override
  String get upToDate => 'Você tem a versão mais recente.';

  @override
  String updateAvailable(String version) {
    return 'A versão $version está disponível';
  }

  @override
  String get downloadInstall => 'Baixar e instalar';

  @override
  String downloading(int percent) {
    return 'Baixando… $percent%';
  }

  @override
  String get later => 'Depois';

  @override
  String get updateFailed =>
      'Não foi possível procurar atualizações. Verifique sua conexão com a internet e tente de novo.';

  @override
  String installFailed(String error) {
    return 'Não foi possível instalar a atualização: $error';
  }

  @override
  String get updatesNote =>
      'O Anatomo usa a internet só quando você toca neste botão. As novas versões vêm dos lançamentos do app no GitHub.';

  @override
  String get about => 'Sobre';

  @override
  String get sourceCode => 'Código-fonte';

  @override
  String get models3d => 'Modelos 3D';

  @override
  String get modelsCredit =>
      'Corpo masculino: BodyParts3D 4.0, © The Database Center for Life Science (CC BY 4.0). Corpo feminino: HuBMAP 3D Reference Organ Set for Female v1.5, de Kristen Browne e Heidi Schlehlein (CC BY 4.0). Ambos foram simplificados para celulares. Os pulmões e o fígado do corpo masculino foram adaptados do conjunto feminino.';

  @override
  String get privacy => 'Privacidade';

  @override
  String get privacyText =>
      'O Anatomo funciona offline. Sem conta, sem anúncios, sem rastreamento. Nada sobre você sai do seu telefone.';

  @override
  String get disclaimerTitle => 'Para aprender';

  @override
  String get disclaimer =>
      'O Anatomo foi feito para aprender. Não é conselho médico. Converse com um médico sobre sua saúde.';
}
