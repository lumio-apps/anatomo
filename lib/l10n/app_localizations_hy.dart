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
      'Կնոջ մարմնի կմախքը և մկանները հարմարեցված են տղամարդու մարմնից։';

  @override
  String get general => 'Ընդհանուր';

  @override
  String get appearance => 'Տեսք';

  @override
  String get themeAuto => 'Ավտո';

  @override
  String get themeLight => 'Բաց';

  @override
  String get themeDark => 'Մուգ';

  @override
  String get quality => 'Գրաֆիկա';

  @override
  String get qualityAuto => 'Ավտո';

  @override
  String get qualityLow => 'Ցածր';

  @override
  String get qualityMedium => 'Միջին';

  @override
  String get qualityHigh => 'Բարձր';

  @override
  String get qualityNote =>
      'Ցածր որակը ավելի արագ է աշխատում հին հեռախոսների վրա։ Ավտո ռեժիմը ընտրում է ձեր հեռախոսի համար լավագույն մակարդակը։ Փոխելիս 3D տեսքը նորից բեռնվում է։';

  @override
  String get favorites => 'Ընտրյալներ';

  @override
  String get noFavorites =>
      'Դեռ ընտրյալներ չկան։ Սեղմեք աստղանիշը մարմնի մասի վրա՝ այն այստեղ ավելացնելու համար։';

  @override
  String get addFavorite => 'Ավելացնել ընտրյալներում';

  @override
  String get removeFavorite => 'Հեռացնել ընտրյալներից';

  @override
  String get copyText => 'Պատճենել տեքստը';

  @override
  String get copied => 'Պատճենվեց';

  @override
  String get quiz => 'Վիկտորինա';

  @override
  String get quizWhichPart => 'Սա մարմնի ո՞ր մասն է։';

  @override
  String quizWhichSystem(String name) {
    return 'Ո՞ր համակարգին է պատկանում՝ $name։';
  }

  @override
  String quizQuestionOf(int n, int total) {
    return 'Հարց $n / $total';
  }

  @override
  String get quizCorrect => 'Ճիշտ է։';

  @override
  String quizWrong(String answer) {
    return 'Ոչ այնքան։ Պատասխանն է՝ $answer։';
  }

  @override
  String get quizNext => 'Հաջորդը';

  @override
  String get quizFinish => 'Տեսնել արդյունքը';

  @override
  String quizScore(int score, int total) {
    return 'Դուք ճիշտ պատասխանեցիք $score/$total';
  }

  @override
  String quizBest(int best) {
    return 'Լավագույն արդյունքը՝ $best';
  }

  @override
  String get quizPlayAgain => 'Խաղալ նորից';

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
      'Տղամարդու մարմին՝ BodyParts3D 4.0, © The Database Center for Life Science (CC BY 4.0)։ Կնոջ մարմին՝ HuBMAP 3D Reference Organ Set for Female v1.5, Kristen Browne և Heidi Schlehlein (CC BY 4.0)։ Երկուսն էլ պարզեցված են հեռախոսների համար։ Տղամարդու մարմնի թոքերը և լյարդը տեղադրված են կանացի հավաքածուից։ Կնոջ մարմնի կմախքը և մկանները հարմարեցված են տղամարդու մարմնից։';

  @override
  String get privacy => 'Գաղտնիություն';

  @override
  String get privacyText =>
      'Anatomo-ն աշխատում է առանց ինտերնետի։ Առանց հաշվի, առանց գովազդի, առանց հետևման։ Ձեր մասին ոչինչ դուրս չի գալիս սարքից։';

  @override
  String get disclaimerTitle => 'Ուսուցման համար';

  @override
  String get disclaimer =>
      'Anatomo-ն ստեղծված է ուսուցման համար։ Այն բժշկական խորհուրդ չէ։ Ձեր առողջության մասին խոսեք բժշկի հետ։';

  @override
  String get hint2d => 'Հպեք ցանկացած մասի · մատներով մեծացրեք';

  @override
  String get hintDesktop =>
      'Սեղմեք մասի վրա · պտտեք անիվը՝ մեծացնելու համար · քաշեք՝ տեղաշարժելու համար';

  @override
  String get hiddenHere =>
      'Այս մասը այս կողմից չի երևում։ Փորձեք մեկ այլ կողմ կամ անջատեք դրա առջևի շերտերը։';

  @override
  String get fittedFromMale =>
      'Կնոջ մարմնում այս մասը հարմարեցված է տղամարդու մարմնից։';

  @override
  String get fittedFromFemale =>
      'Տղամարդու մարմնում այս մասը հարմարեցված է կնոջ մարմնից։';

  @override
  String get layers => 'Շերտեր';

  @override
  String get explore => 'Դիտել';

  @override
  String get selectPartTitle => 'Սեղմեք մարմնի ցանկացած մասի վրա';

  @override
  String get selectPartText =>
      'Դրա քարտը կբացվի այստեղ՝ ինչ է անում, ինչն է օգտակար դրա համար և ինչն է վնասում։';

  @override
  String get keyboard => 'Ստեղնաշար';

  @override
  String get zoomIn => 'Մեծացնել';

  @override
  String get zoomOut => 'Փոքրացնել';

  @override
  String get cancel => 'Չեղարկել';

  @override
  String get pack3dTitle => '3D փաթեթ';

  @override
  String pack3dNote(int size) {
    return 'Պտտեք մարմինը և բաժանեք մասերի 3D-ում։ Ներբեռնվում է մեկ անգամ (մոտ $size ՄԲ), հետո աշխատում է առանց ինտերնետի։';
  }

  @override
  String get pack3dDownload => 'Ներբեռնել';

  @override
  String get pack3dReady =>
      '3D փաթեթը տեղադրված է։ Մարմնի տակ փոխեք 2D-ի և 3D-ի միջև։';

  @override
  String get pack3dRemove => 'Հեռացնել';

  @override
  String get pack3dFailed =>
      '3D փաթեթը չհաջողվեց ներբեռնել։ Ստուգեք ինտերնետ կապը և նորից փորձեք։';
}
