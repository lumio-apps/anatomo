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
  String get femaleNote => '女性身体显示器官、皮肤和部分骨骼。完整骨骼和肌肉在男性身体中。';

  @override
  String get general => '通用';

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
      '男性身体：BodyParts3D 4.0，© The Database Center for Life Science（CC BY 4.0）。女性身体：HuBMAP 3D Reference Organ Set for Female v1.5，作者 Kristen Browne 和 Heidi Schlehlein（CC BY 4.0）。两者都为手机做了简化。男性身体的肺和肝脏取自女性模型并做了适配。';

  @override
  String get privacy => '隐私';

  @override
  String get privacyText => 'Anatomo 可离线使用。无需账号，没有广告，没有追踪。你的任何信息都不会离开手机。';

  @override
  String get disclaimerTitle => '用于学习';

  @override
  String get disclaimer => 'Anatomo 用于学习，不构成医疗建议。有关健康问题请咨询医生。';
}
