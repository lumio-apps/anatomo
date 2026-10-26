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
      'هيكل جسم الأنثى العظمي وعضلاته مأخوذة من جسم الذكر ومُكيّفة له.';

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
  String get quality => 'الرسومات';

  @override
  String get qualityAuto => 'تلقائي';

  @override
  String get qualityLow => 'منخفضة';

  @override
  String get qualityMedium => 'متوسطة';

  @override
  String get qualityHigh => 'عالية';

  @override
  String get qualityNote =>
      'الجودة الأقل تعمل أسرع على الهواتف القديمة. الوضع التلقائي يختار أفضل مستوى لهاتفك. يُعاد تحميل العرض ثلاثي الأبعاد عند التغيير.';

  @override
  String get favorites => 'المفضلة';

  @override
  String get noFavorites =>
      'لا توجد عناصر مفضلة بعد. اضغط على النجمة في أي جزء لإضافته هنا.';

  @override
  String get addFavorite => 'إضافة إلى المفضلة';

  @override
  String get removeFavorite => 'إزالة من المفضلة';

  @override
  String get copyText => 'نسخ النص';

  @override
  String get copied => 'تم النسخ إلى الحافظة';

  @override
  String get quiz => 'اختبار';

  @override
  String get quizWhichPart => 'أي جزء من الجسم هذا؟';

  @override
  String quizWhichSystem(String name) {
    return 'إلى أي جهاز في الجسم ينتمي: $name؟';
  }

  @override
  String quizQuestionOf(int n, int total) {
    return 'السؤال $n من $total';
  }

  @override
  String get quizCorrect => 'صحيح!';

  @override
  String quizWrong(String answer) {
    return 'ليس تمامًا. الإجابة هي $answer.';
  }

  @override
  String get quizNext => 'التالي';

  @override
  String get quizFinish => 'عرض النتيجة';

  @override
  String quizScore(int score, int total) {
    return 'أجبت بشكل صحيح عن $score من $total';
  }

  @override
  String quizBest(int best) {
    return 'أفضل نتيجة: $best';
  }

  @override
  String get quizPlayAgain => 'العب مرة أخرى';

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
      'جسم الذكر: BodyParts3D 4.0، © The Database Center for Life Science (CC BY 4.0). جسم الأنثى: HuBMAP 3D Reference Organ Set for Female v1.5، من إعداد Kristen Browne وHeidi Schlehlein (CC BY 4.0). كلاهما مبسّط للهواتف. الرئتان والكبد في جسم الذكر مأخوذة من مجموعة الأنثى ومُكيّفة له. هيكل جسم الأنثى العظمي وعضلاته مأخوذة من جسم الذكر ومُكيّفة له.';

  @override
  String get privacy => 'الخصوصية';

  @override
  String get privacyText =>
      'يعمل Anatomo دون إنترنت. بلا حساب، بلا إعلانات، بلا تتبّع. لا يغادر جهازك أي شيء عنك.';

  @override
  String get disclaimerTitle => 'للتعلّم';

  @override
  String get disclaimer =>
      'صُمّم Anatomo للتعلّم. وهو ليس نصيحة طبية. تحدّث مع طبيب بشأن صحتك.';

  @override
  String get hint2d => 'اضغط على أي جزء · باعد بإصبعين للتكبير';

  @override
  String get hintDesktop =>
      'انقر على جزء · استخدم عجلة الفأرة للتكبير · اسحب للتحريك';

  @override
  String get hiddenHere =>
      'هذا الجزء لا يظهر من هذه الجهة. جرّب جهة أخرى، أو أوقف الطبقات التي أمامه.';

  @override
  String get fittedFromMale =>
      'في جسم الأنثى، هذا الجزء مأخوذ من جسم الذكر ومُكيّف له.';

  @override
  String get fittedFromFemale =>
      'في جسم الذكر، هذا الجزء مأخوذ من جسم الأنثى ومُكيّف له.';

  @override
  String get layers => 'الطبقات';

  @override
  String get explore => 'استكشاف';

  @override
  String get selectPartTitle => 'انقر على أي جزء من الجسم';

  @override
  String get selectPartText =>
      'تُفتح بطاقته هنا: ماذا يفعل، وما المفيد له، وما الذي يضرّه.';

  @override
  String get keyboard => 'لوحة المفاتيح';

  @override
  String get zoomIn => 'تكبير';

  @override
  String get zoomOut => 'تصغير';

  @override
  String get cancel => 'إلغاء';

  @override
  String get pack3dTitle => 'حزمة ثلاثية الأبعاد';

  @override
  String pack3dNote(int size) {
    return 'أدِر الجسم وافصل أجزاءه بالأبعاد الثلاثية. تُنزَّل مرة واحدة (نحو $size ميغابايت)، ثم تعمل دون إنترنت.';
  }

  @override
  String get pack3dDownload => 'تنزيل';

  @override
  String get pack3dReady =>
      'الحزمة ثلاثية الأبعاد مثبّتة. استخدم مفتاح 2D / 3D لتغيير العرض.';

  @override
  String get pack3dRemove => 'إزالة';

  @override
  String get pack3dFailed =>
      'تعذّر تنزيل الحزمة ثلاثية الأبعاد. تحقّق من الاتصال بالإنترنت وحاول مرة أخرى.';

  @override
  String get hint3dDesktop =>
      'اسحب للتدوير · استخدم عجلة الفأرة للتكبير · انقر على أي جزء';
}
