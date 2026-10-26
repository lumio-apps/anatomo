// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get welcomeTitle => '欢迎使用 Anatomo';

  @override
  String get welcomeSubtitle => '请选择语言。之后可随时在设置中更改。';

  @override
  String get continueButton => '继续';

  @override
  String get offlineNote => '离线可用 · 无需账号 · 无追踪';

  @override
  String get male => '男性';

  @override
  String get female => '女性';

  @override
  String get layerOrgans => '器官';

  @override
  String get layerBones => '骨骼';

  @override
  String get layerMuscles => '肌肉';

  @override
  String get layerNerves => '神经';

  @override
  String get layerVessels => '血管';

  @override
  String get layerSkin => '身体';

  @override
  String get viewFront => '正面';

  @override
  String get viewBack => '背面';

  @override
  String get viewSide => '侧面';

  @override
  String get resetView => '重置视图';

  @override
  String get spreadApart => '展开拆分';

  @override
  String get assembled => '已组合';

  @override
  String get hint => '拖动旋转 · 双指缩放 · 点击任意部位';

  @override
  String loading(int percent) {
    return '正在加载 3D 人体… $percent%';
  }

  @override
  String get errorWebgl => '此手机无法显示 3D 人体。请更新 Android System WebView 后重试。';

  @override
  String get errorLoad => '无法加载 3D 人体。';

  @override
  String get retry => '重试';

  @override
  String get tabAbout => '功能';

  @override
  String get tabGood => '有益的';

  @override
  String get tabBad => '有害的';

  @override
  String partLabel(String name) {
    return '部位：$name';
  }

  @override
  String get notMedical => '仅供学习，不构成医疗建议。';

  @override
  String get close => '关闭';

  @override
  String get showWholeBody => '显示整个身体';

  @override
  String get searchParts => '搜索部位';

  @override
  String get settings => '设置';

  @override
  String get allParts => '全部部位';

  @override
  String partsCount(int count) {
    return '$count 个部位';
  }

  @override
  String get searchHint => '搜索心脏、股骨、肝脏…';

  @override
  String get filterAll => '全部';

  @override
  String get detailedStructures => '详细结构';

  @override
  String noResults(String query) {
    return '未找到“$query”。';
  }

  @override
  String get femaleNote => '女性身体的骨骼和肌肉取自男性身体并做了适配。';

  @override
  String get general => '通用';

  @override
  String get appearance => '外观';

  @override
  String get themeAuto => '自动';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get quality => '画质';

  @override
  String get qualityAuto => '自动';

  @override
  String get qualityLow => '低';

  @override
  String get qualityMedium => '中';

  @override
  String get qualityHigh => '高';

  @override
  String get qualityNote => '较低的画质在旧手机上更流畅。自动会为你的手机选择最合适的等级。更改后 3D 视图会重新加载。';

  @override
  String get favorites => '收藏';

  @override
  String get noFavorites => '还没有收藏。点按某个部位上的星标即可添加到这里。';

  @override
  String get addFavorite => '加入收藏';

  @override
  String get removeFavorite => '取消收藏';

  @override
  String get copyText => '复制文字';

  @override
  String get copied => '已复制到剪贴板';

  @override
  String get quiz => '小测验';

  @override
  String get quizWhichPart => '这是身体的哪个部位？';

  @override
  String quizWhichSystem(String name) {
    return '$name 属于哪个身体系统？';
  }

  @override
  String quizQuestionOf(int n, int total) {
    return '第 $n 题，共 $total 题';
  }

  @override
  String get quizCorrect => '正确！';

  @override
  String quizWrong(String answer) {
    return '不太对。答案是 $answer。';
  }

  @override
  String get quizNext => '下一题';

  @override
  String get quizFinish => '查看结果';

  @override
  String quizScore(int score, int total) {
    return '你答对了 $score 题，共 $total 题';
  }

  @override
  String quizBest(int best) {
    return '最高分：$best';
  }

  @override
  String get quizPlayAgain => '再玩一次';

  @override
  String get language => '语言';

  @override
  String get body => '身体';

  @override
  String get updates => '更新';

  @override
  String versionLabel(String version) {
    return 'Anatomo $version';
  }

  @override
  String get checkForUpdates => '检查更新';

  @override
  String get checking => '正在检查…';

  @override
  String get upToDate => '已是最新版本。';

  @override
  String updateAvailable(String version) {
    return '有新版本 $version';
  }

  @override
  String get downloadInstall => '下载并安装';

  @override
  String downloading(int percent) {
    return '正在下载… $percent%';
  }

  @override
  String get later => '以后再说';

  @override
  String get updateFailed => '无法检查更新。请检查网络连接后重试。';

  @override
  String installFailed(String error) {
    return '无法安装更新：$error';
  }

  @override
  String get updatesNote => '只有在你点击此按钮时，Anatomo 才会使用网络。新版本来自本应用在 GitHub 上的发布。';

  @override
  String get about => '关于';

  @override
  String get sourceCode => '源代码';

  @override
  String get models3d => '3D 模型';

  @override
  String get modelsCredit =>
      '男性身体：BodyParts3D 4.0，© The Database Center for Life Science（CC BY 4.0）。女性身体：HuBMAP 3D Reference Organ Set for Female v1.5，作者 Kristen Browne 和 Heidi Schlehlein（CC BY 4.0）。两者都为手机做了简化。男性身体的肺和肝脏取自女性模型并做了适配。女性身体的骨骼和肌肉取自男性身体并做了适配。';

  @override
  String get privacy => '隐私';

  @override
  String get privacyText => 'Anatomo 可离线使用。无需账号，没有广告，没有追踪。你的任何信息都不会离开设备。';

  @override
  String get disclaimerTitle => '用于学习';

  @override
  String get disclaimer => 'Anatomo 用于学习，不构成医疗建议。有关健康问题请咨询医生。';

  @override
  String get hint2d => '点按任意部位 · 双指缩放';

  @override
  String get hintDesktop => '点击部位 · 滚轮缩放 · 拖动移动';

  @override
  String get hiddenHere => '从这一侧看不到这个部位。请换一个方向，或关闭它前面的图层。';

  @override
  String get fittedFromMale => '在女性身体中，这个部位取自男性身体并做了适配。';

  @override
  String get fittedFromFemale => '在男性身体中，这个部位取自女性身体并做了适配。';

  @override
  String get layers => '图层';

  @override
  String get explore => '浏览';

  @override
  String get selectPartTitle => '点击身体的任意部位';

  @override
  String get selectPartText => '它的卡片会在这里打开：它的作用、对它有益的事和对它有害的事。';

  @override
  String get keyboard => '键盘';

  @override
  String get zoomIn => '放大';

  @override
  String get zoomOut => '缩小';

  @override
  String get cancel => '取消';

  @override
  String get pack3dTitle => '3D 资源包';

  @override
  String pack3dNote(int size) {
    return '在 3D 中旋转身体并把各部分分开查看。只需下载一次（约 $size MB），之后可离线使用。';
  }

  @override
  String get pack3dDownload => '下载';

  @override
  String get pack3dReady => '3D 资源包已安装。使用 2D / 3D 开关切换视图。';

  @override
  String get pack3dRemove => '删除';

  @override
  String get pack3dFailed => '无法下载 3D 资源包。请检查网络连接后重试。';

  @override
  String get hint3dDesktop => '拖动旋转 · 滚轮缩放 · 点击任意部位';
}
