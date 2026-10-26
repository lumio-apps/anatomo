// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get welcomeTitle => 'مرحبًا بك في Anatomo';

  @override
  String get welcomeSubtitle =>
      'اختر لغتك. يمكنك تغييرها في أي وقت من الإعدادات.';

  @override
  String get continueButton => 'متابعة';

  @override
  String get offlineNote => 'يعمل دون إنترنت · بلا حساب · بلا تتبّع';

  @override
  String get male => 'ذكر';

  @override
  String get female => 'أنثى';

  @override
  String get layerOrgans => 'الأعضاء';

  @override
  String get layerBones => 'العظام';

  @override
  String get layerMuscles => 'العضلات';

  @override
  String get layerNerves => 'الأعصاب';

  @override
  String get layerVessels => 'الأوعية';

  @override
  String get layerSkin => 'الجسم';

  @override
  String get viewFront => 'أمام';

  @override
  String get viewBack => 'خلف';

  @override
  String get viewSide => 'جانب';

  @override
  String get resetView => 'إعادة ضبط العرض';

  @override
  String get spreadApart => 'تفكيك';

  @override
  String get assembled => 'مُجمّع';

  @override
  String get hint => 'اسحب للتدوير · اقرص للتكبير · المس أي جزء';

  @override
  String loading(int percent) {
    return 'جارٍ تحميل الجسم ثلاثي الأبعاد… $percent٪';
  }

  @override
  String get errorWebgl =>
      'لا يستطيع هذا الهاتف عرض الجسم ثلاثي الأبعاد. حدّث Android System WebView ثم حاول مجددًا.';

  @override
  String get errorLoad => 'تعذّر تحميل الجسم ثلاثي الأبعاد.';

  @override
  String get retry => 'حاول مجددًا';

  @override
  String get tabAbout => 'ماذا يفعل';

  @override
  String get tabGood => 'ما يفيده';

  @override
  String get tabBad => 'ما يضرّه';

  @override
  String partLabel(String name) {
    return 'الجزء: $name';
  }

  @override
  String get notMedical => 'للتعلّم فقط. ليس نصيحة طبية.';

  @override
  String get close => 'إغلاق';

  @override
  String get showWholeBody => 'عرض الجسم كاملًا';

  @override
  String get searchParts => 'ابحث عن الأجزاء';

  @override
  String get settings => 'الإعدادات';

  @override
  String get allParts => 'كل الأجزاء';

  @override
  String partsCount(int count) {
    return '$count جزءًا';
  }

  @override
  String get searchHint => 'ابحث: القلب، عظم الفخذ، الكبد…';

  @override
  String get filterAll => 'الكل';

  @override
  String get detailedStructures => 'تراكيب مفصّلة';

  @override
  String noResults(String query) {
    return 'لا نتائج لـ «$query».';
  }

  @override
  String get femaleNote =>
      'يُظهر جسم الأنثى الأعضاء والجلد وجزءًا من الهيكل العظمي. الهيكل الكامل والعضلات موجودة في جسم الذكر.';

  @override
  String get general => 'عام';

  @override
  String get appearance => 'المظهر';

  @override
  String get themeAuto => 'تلقائي';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get language => 'اللغة';

  @override
  String get body => 'الجسم';

  @override
  String get updates => 'التحديثات';

  @override
  String versionLabel(String version) {
    return 'Anatomo $version';
  }

  @override
  String get checkForUpdates => 'التحقق من التحديثات';

  @override
  String get checking => 'جارٍ التحقق…';

  @override
  String get upToDate => 'لديك أحدث إصدار.';

  @override
  String updateAvailable(String version) {
    return 'الإصدار $version متاح';
  }

  @override
  String get downloadInstall => 'تنزيل وتثبيت';

  @override
  String downloading(int percent) {
    return 'جارٍ التنزيل… $percent٪';
  }

  @override
  String get later => 'لاحقًا';

  @override
  String get updateFailed =>
      'تعذّر التحقق من التحديثات. تحقّق من اتصال الإنترنت ثم حاول مجددًا.';

  @override
  String installFailed(String error) {
    return 'تعذّر تثبيت التحديث: $error';
  }

  @override
  String get updatesNote =>
      'يستخدم Anatomo الإنترنت فقط عندما تضغط هذا الزر. تأتي الإصدارات الجديدة من إصدارات التطبيق على GitHub.';

  @override
  String get about => 'حول التطبيق';

  @override
  String get sourceCode => 'الشيفرة المصدرية';

  @override
  String get models3d => 'النماذج ثلاثية الأبعاد';

  @override
  String get modelsCredit =>
      'جسم الذكر: BodyParts3D 4.0، © The Database Center for Life Science (CC BY 4.0). جسم الأنثى: HuBMAP 3D Reference Organ Set for Female v1.5، من إعداد Kristen Browne وHeidi Schlehlein (CC BY 4.0). كلاهما مبسّط للهواتف. الرئتان والكبد في جسم الذكر مأخوذة من مجموعة الأنثى ومُكيّفة له.';

  @override
  String get privacy => 'الخصوصية';

  @override
  String get privacyText =>
      'يعمل Anatomo دون إنترنت. بلا حساب، بلا إعلانات، بلا تتبّع. لا يغادر هاتفك أي شيء عنك.';

  @override
  String get disclaimerTitle => 'للتعلّم';

  @override
  String get disclaimer =>
      'صُمّم Anatomo للتعلّم. وهو ليس نصيحة طبية. تحدّث مع طبيب بشأن صحتك.';
}
