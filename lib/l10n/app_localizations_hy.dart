// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Armenian (`hy`).
class AppLocalizationsHy extends AppLocalizations {
  AppLocalizationsHy([String locale = 'hy']) : super(locale);

  @override
  String get welcomeTitle => 'Բարի գալուստ Anatomo';

  @override
  String get welcomeSubtitle =>
      'Ընտրեք լեզուն։ Այն կարող եք ցանկացած պահի փոխել Կարգավորումներում։';

  @override
  String get continueButton => 'Շարունակել';

  @override
  String get offlineNote =>
      'Աշխատում է առանց ինտերնետի · Առանց հաշվի · Առանց հետևման';

  @override
  String get male => 'Տղամարդ';

  @override
  String get female => 'Կին';

  @override
  String get layerOrgans => 'Օրգաններ';

  @override
  String get layerBones => 'Ոսկորներ';

  @override
  String get layerMuscles => 'Մկաններ';

  @override
  String get layerNerves => 'Նյարդեր';

  @override
  String get layerVessels => 'Անոթներ';

  @override
  String get layerSkin => 'Մարմին';

  @override
  String get viewFront => 'Առջևից';

  @override
  String get viewBack => 'Հետևից';

  @override
  String get viewSide => 'Կողքից';

  @override
  String get resetView => 'Վերականգնել տեսքը';

  @override
  String get spreadApart => 'Բաժանել մասերի';

  @override
  String get assembled => 'Հավաքված';

  @override
  String get hint =>
      'Քաշեք՝ պտտելու համար · երկու մատով՝ մեծացնելու · հպեք ցանկացած մասի';

  @override
  String loading(int percent) {
    return '3D մարմինը բեռնվում է… $percent%';
  }

  @override
  String get errorWebgl =>
      'Այս հեռախոսը չի կարող ցույց տալ 3D մարմինը։ Թարմացրեք Android System WebView-ը և նորից փորձեք։';

  @override
  String get errorLoad => '3D մարմինը չհաջողվեց բեռնել։';

  @override
  String get retry => 'Կրկին փորձել';

  @override
  String get tabAbout => 'Ինչ է անում';

  @override
  String get tabGood => 'Օգտակար է';

  @override
  String get tabBad => 'Վնասակար է';

  @override
  String partLabel(String name) {
    return 'Մաս՝ $name';
  }

  @override
  String get notMedical => 'Միայն ուսուցման համար։ Բժշկական խորհուրդ չէ։';

  @override
  String get close => 'Փակել';

  @override
  String get showWholeBody => 'Ցույց տալ ամբողջ մարմինը';

  @override
  String get searchParts => 'Որոնել մասեր';

  @override
  String get settings => 'Կարգավորումներ';

  @override
  String get allParts => 'Բոլոր մասերը';

  @override
  String partsCount(int count) {
    return '$count մաս';
  }

  @override
  String get searchHint => 'Որոնել՝ սիրտ, ազդրոսկր, լյարդ…';

  @override
  String get filterAll => 'Բոլորը';

  @override
  String get detailedStructures => 'Մանրամասն կառույցներ';

  @override
  String noResults(String query) {
    return '«$query»-ի համար ոչինչ չգտնվեց։';
  }

  @override
  String get femaleNote =>
      'Կնոջ մարմնում երևում են օրգանները, մաշկը և կմախքի մի մասը։ Ամբողջական կմախքը և մկանները տղամարդու մարմնում են։';

  @override
  String get general => 'Ընդհանուր';

  @override
  String get language => 'Լեզու';

  @override
  String get body => 'Մարմին';

  @override
  String get updates => 'Թարմացումներ';

  @override
  String versionLabel(String version) {
    return 'Anatomo $version';
  }

  @override
  String get checkForUpdates => 'Ստուգել թարմացումները';

  @override
  String get checking => 'Ստուգվում է…';

  @override
  String get upToDate => 'Դուք ունեք վերջին տարբերակը։';

  @override
  String updateAvailable(String version) {
    return 'Հասանելի է $version տարբերակը';
  }

  @override
  String get downloadInstall => 'Ներբեռնել և տեղադրել';

  @override
  String downloading(int percent) {
    return 'Ներբեռնվում է… $percent%';
  }

  @override
  String get later => 'Հետո';

  @override
  String get updateFailed =>
      'Չհաջողվեց ստուգել թարմացումները։ Ստուգեք ինտերնետը և նորից փորձեք։';

  @override
  String installFailed(String error) {
    return 'Չհաջողվեց տեղադրել թարմացումը՝ $error';
  }

  @override
  String get updatesNote =>
      'Anatomo-ն ինտերնետ օգտագործում է միայն այս կոճակը սեղմելիս։ Նոր տարբերակները գալիս են հավելվածի GitHub թողարկումներից։';

  @override
  String get about => 'Հավելվածի մասին';

  @override
  String get sourceCode => 'Ելակետային կոդ';

  @override
  String get models3d => '3D մոդելներ';

  @override
  String get modelsCredit =>
      'Տղամարդու մարմին՝ BodyParts3D 4.0, © The Database Center for Life Science (CC BY 4.0)։ Կնոջ մարմին՝ HuBMAP 3D Reference Organ Set for Female v1.5, Kristen Browne և Heidi Schlehlein (CC BY 4.0)։ Երկուսն էլ պարզեցված են հեռախոսների համար։ Տղամարդու մարմնի թոքերը և լյարդը տեղադրված են կանացի հավաքածուից։';

  @override
  String get privacy => 'Գաղտնիություն';

  @override
  String get privacyText =>
      'Anatomo-ն աշխատում է առանց ինտերնետի։ Առանց հաշվի, առանց գովազդի, առանց հետևման։ Ձեր մասին ոչինչ դուրս չի գալիս հեռախոսից։';

  @override
  String get disclaimerTitle => 'Ուսուցման համար';

  @override
  String get disclaimer =>
      'Anatomo-ն ստեղծված է ուսուցման համար։ Այն բժշկական խորհուրդ չէ։ Ձեր առողջության մասին խոսեք բժշկի հետ։';
}
