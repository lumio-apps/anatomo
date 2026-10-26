// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get welcomeTitle => 'Anatomo에 오신 것을 환영합니다';

  @override
  String get welcomeSubtitle => '언어를 선택하세요. 설정에서 언제든지 바꿀 수 있습니다.';

  @override
  String get continueButton => '계속';

  @override
  String get offlineNote => '오프라인 사용 · 계정 없음 · 추적 없음';

  @override
  String get male => '남성';

  @override
  String get female => '여성';

  @override
  String get layerOrgans => '장기';

  @override
  String get layerBones => '뼈';

  @override
  String get layerMuscles => '근육';

  @override
  String get layerNerves => '신경';

  @override
  String get layerVessels => '혈관';

  @override
  String get layerSkin => '몸';

  @override
  String get viewFront => '앞';

  @override
  String get viewBack => '뒤';

  @override
  String get viewSide => '옆';

  @override
  String get resetView => '보기 초기화';

  @override
  String get spreadApart => '펼쳐 보기';

  @override
  String get assembled => '조립됨';

  @override
  String get hint => '드래그해서 회전 · 두 손가락으로 확대 · 아무 부위나 탭';

  @override
  String loading(int percent) {
    return '3D 인체를 불러오는 중… $percent%';
  }

  @override
  String get errorWebgl =>
      '이 휴대폰에서는 3D 인체를 표시할 수 없습니다. Android System WebView를 업데이트한 뒤 다시 시도하세요.';

  @override
  String get errorLoad => '3D 인체를 불러오지 못했습니다.';

  @override
  String get retry => '다시 시도';

  @override
  String get tabAbout => '하는 일';

  @override
  String get tabGood => '좋은 것';

  @override
  String get tabBad => '나쁜 것';

  @override
  String partLabel(String name) {
    return '부위: $name';
  }

  @override
  String get notMedical => '학습용입니다. 의학적 조언이 아닙니다.';

  @override
  String get close => '닫기';

  @override
  String get showWholeBody => '몸 전체 보기';

  @override
  String get searchParts => '부위 검색';

  @override
  String get settings => '설정';

  @override
  String get allParts => '모든 부위';

  @override
  String partsCount(int count) {
    return '부위 $count개';
  }

  @override
  String get searchHint => '심장, 넙다리뼈, 간 검색…';

  @override
  String get filterAll => '전체';

  @override
  String get detailedStructures => '세부 구조';

  @override
  String noResults(String query) {
    return '“$query”에 대한 결과가 없습니다.';
  }

  @override
  String get femaleNote =>
      '여성 인체는 장기, 피부, 골격 일부를 보여 줍니다. 전체 골격과 근육은 남성 인체에 있습니다.';

  @override
  String get general => '일반';

  @override
  String get appearance => '화면 모드';

  @override
  String get themeAuto => '자동';

  @override
  String get themeLight => '라이트';

  @override
  String get themeDark => '다크';

  @override
  String get quality => '그래픽';

  @override
  String get qualityAuto => '자동';

  @override
  String get qualityLow => '낮음';

  @override
  String get qualityMedium => '보통';

  @override
  String get qualityHigh => '높음';

  @override
  String get qualityNote =>
      '화질을 낮추면 오래된 휴대폰에서 더 빠르게 작동합니다. 자동은 휴대폰에 맞는 단계를 고릅니다. 바꾸면 3D 화면이 다시 로드됩니다.';

  @override
  String get favorites => '즐겨찾기';

  @override
  String get noFavorites => '아직 즐겨찾기가 없습니다. 부위의 별을 누르면 여기에 추가됩니다.';

  @override
  String get addFavorite => '즐겨찾기에 추가';

  @override
  String get removeFavorite => '즐겨찾기에서 삭제';

  @override
  String get copyText => '텍스트 복사';

  @override
  String get copied => '클립보드에 복사했습니다';

  @override
  String get quiz => '퀴즈';

  @override
  String get quizWhichPart => '이것은 몸의 어느 부위일까요?';

  @override
  String quizWhichSystem(String name) {
    return '$name은(는) 어느 신체 계통에 속할까요?';
  }

  @override
  String quizQuestionOf(int n, int total) {
    return '$total문제 중 $n번';
  }

  @override
  String get quizCorrect => '정답!';

  @override
  String quizWrong(String answer) {
    return '아쉽네요. 정답은 $answer입니다.';
  }

  @override
  String get quizNext => '다음';

  @override
  String get quizFinish => '결과 보기';

  @override
  String quizScore(int score, int total) {
    return '$total문제 중 $score문제를 맞혔어요';
  }

  @override
  String quizBest(int best) {
    return '최고 점수: $best';
  }

  @override
  String get quizPlayAgain => '다시 하기';

  @override
  String get language => '언어';

  @override
  String get body => '인체';

  @override
  String get updates => '업데이트';

  @override
  String versionLabel(String version) {
    return 'Anatomo $version';
  }

  @override
  String get checkForUpdates => '업데이트 확인';

  @override
  String get checking => '확인 중…';

  @override
  String get upToDate => '최신 버전입니다.';

  @override
  String updateAvailable(String version) {
    return '버전 $version을(를) 사용할 수 있습니다';
  }

  @override
  String get downloadInstall => '다운로드 및 설치';

  @override
  String downloading(int percent) {
    return '다운로드 중… $percent%';
  }

  @override
  String get later => '나중에';

  @override
  String get updateFailed => '업데이트를 확인하지 못했습니다. 인터넷 연결을 확인한 뒤 다시 시도하세요.';

  @override
  String installFailed(String error) {
    return '업데이트를 설치하지 못했습니다: $error';
  }

  @override
  String get updatesNote =>
      'Anatomo는 이 버튼을 누를 때만 인터넷을 사용합니다. 새 버전은 앱의 GitHub 릴리스에서 받습니다.';

  @override
  String get about => '정보';

  @override
  String get sourceCode => '소스 코드';

  @override
  String get models3d => '3D 모델';

  @override
  String get modelsCredit =>
      '남성 인체: BodyParts3D 4.0, © The Database Center for Life Science (CC BY 4.0). 여성 인체: HuBMAP 3D Reference Organ Set for Female v1.5, Kristen Browne·Heidi Schlehlein 제작 (CC BY 4.0). 둘 다 휴대폰에 맞게 단순화했습니다. 남성 인체의 폐와 간은 여성 세트에서 가져와 맞췄습니다.';

  @override
  String get privacy => '개인정보';

  @override
  String get privacyText =>
      'Anatomo는 오프라인으로 작동합니다. 계정, 광고, 추적이 없습니다. 사용자에 대한 어떤 정보도 휴대폰 밖으로 나가지 않습니다.';

  @override
  String get disclaimerTitle => '학습용';

  @override
  String get disclaimer =>
      'Anatomo는 학습을 위해 만들어졌습니다. 의학적 조언이 아닙니다. 건강에 대해서는 의사와 상담하세요.';
}
