// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get welcomeTitle => 'Anatomo में आपका स्वागत है';

  @override
  String get welcomeSubtitle =>
      'अपनी भाषा चुनें। आप इसे कभी भी सेटिंग्स में बदल सकते हैं।';

  @override
  String get continueButton => 'आगे बढ़ें';

  @override
  String get offlineNote =>
      'बिना इंटरनेट चलता है · कोई अकाउंट नहीं · कोई ट्रैकिंग नहीं';

  @override
  String get male => 'पुरुष';

  @override
  String get female => 'महिला';

  @override
  String get layerOrgans => 'अंग';

  @override
  String get layerBones => 'हड्डियाँ';

  @override
  String get layerMuscles => 'मांसपेशियाँ';

  @override
  String get layerNerves => 'नसें';

  @override
  String get layerVessels => 'रक्त वाहिकाएँ';

  @override
  String get layerSkin => 'शरीर';

  @override
  String get viewFront => 'सामने';

  @override
  String get viewBack => 'पीछे';

  @override
  String get viewSide => 'बगल';

  @override
  String get resetView => 'व्यू रीसेट करें';

  @override
  String get spreadApart => 'अलग-अलग फैलाएँ';

  @override
  String get assembled => 'जुड़ा हुआ';

  @override
  String get hint =>
      'घुमाने के लिए खींचें · ज़ूम के लिए दो उँगलियाँ · किसी भी हिस्से पर टैप करें';

  @override
  String loading(int percent) {
    return '3D शरीर लोड हो रहा है… $percent%';
  }

  @override
  String get errorWebgl =>
      'यह फ़ोन 3D शरीर नहीं दिखा पा रहा। कृपया Android System WebView अपडेट करें और फिर कोशिश करें।';

  @override
  String get errorLoad => '3D शरीर लोड नहीं हो सका।';

  @override
  String get retry => 'फिर कोशिश करें';

  @override
  String get tabAbout => 'क्या काम करता है';

  @override
  String get tabGood => 'इसके लिए अच्छा';

  @override
  String get tabBad => 'इसके लिए बुरा';

  @override
  String partLabel(String name) {
    return 'हिस्सा: $name';
  }

  @override
  String get notMedical => 'सिर्फ़ सीखने के लिए। यह डॉक्टरी सलाह नहीं है।';

  @override
  String get close => 'बंद करें';

  @override
  String get showWholeBody => 'पूरा शरीर दिखाएँ';

  @override
  String get searchParts => 'हिस्से खोजें';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get allParts => 'सभी हिस्से';

  @override
  String partsCount(int count) {
    return '$count हिस्से';
  }

  @override
  String get searchHint => 'दिल, जांघ की हड्डी, लिवर खोजें…';

  @override
  String get filterAll => 'सभी';

  @override
  String get detailedStructures => 'बारीक हिस्से';

  @override
  String noResults(String query) {
    return '“$query” के लिए कुछ नहीं मिला।';
  }

  @override
  String get femaleNote =>
      'महिला शरीर का कंकाल और मांसपेशियाँ पुरुष शरीर से लेकर ढाली गई हैं।';

  @override
  String get general => 'सामान्य';

  @override
  String get appearance => 'दिखावट';

  @override
  String get themeAuto => 'ऑटो';

  @override
  String get themeLight => 'लाइट';

  @override
  String get themeDark => 'डार्क';

  @override
  String get quality => 'ग्राफ़िक्स';

  @override
  String get qualityAuto => 'ऑटो';

  @override
  String get qualityLow => 'कम';

  @override
  String get qualityMedium => 'मध्यम';

  @override
  String get qualityHigh => 'उच्च';

  @override
  String get qualityNote =>
      'कम क्वालिटी पुराने फ़ोन पर तेज़ चलती है। ऑटो आपके फ़ोन के लिए सबसे अच्छा स्तर चुनता है। इसे बदलने पर 3D व्यू दोबारा लोड होता है।';

  @override
  String get favorites => 'पसंदीदा';

  @override
  String get noFavorites =>
      'अभी कोई पसंदीदा नहीं है। किसी अंग पर तारा दबाकर उसे यहाँ जोड़ें।';

  @override
  String get addFavorite => 'पसंदीदा में जोड़ें';

  @override
  String get removeFavorite => 'पसंदीदा से हटाएँ';

  @override
  String get copyText => 'टेक्स्ट कॉपी करें';

  @override
  String get copied => 'क्लिपबोर्ड में कॉपी हो गया';

  @override
  String get quiz => 'क्विज़';

  @override
  String get quizWhichPart => 'यह शरीर का कौन-सा अंग है?';

  @override
  String quizWhichSystem(String name) {
    return '$name किस शरीर तंत्र का हिस्सा है?';
  }

  @override
  String quizQuestionOf(int n, int total) {
    return 'सवाल $n / $total';
  }

  @override
  String get quizCorrect => 'सही!';

  @override
  String quizWrong(String answer) {
    return 'सही नहीं। जवाब है $answer।';
  }

  @override
  String get quizNext => 'आगे';

  @override
  String get quizFinish => 'नतीजा देखें';

  @override
  String quizScore(int score, int total) {
    return 'आपके $total में से $score सही हुए';
  }

  @override
  String quizBest(int best) {
    return 'सबसे अच्छा स्कोर: $best';
  }

  @override
  String get quizPlayAgain => 'फिर खेलें';

  @override
  String get language => 'भाषा';

  @override
  String get body => 'शरीर';

  @override
  String get updates => 'अपडेट';

  @override
  String versionLabel(String version) {
    return 'Anatomo $version';
  }

  @override
  String get checkForUpdates => 'अपडेट जाँचें';

  @override
  String get checking => 'जाँच हो रही है…';

  @override
  String get upToDate => 'आपके पास नया वर्ज़न है।';

  @override
  String updateAvailable(String version) {
    return 'वर्ज़न $version उपलब्ध है';
  }

  @override
  String get downloadInstall => 'डाउनलोड करें और इंस्टॉल करें';

  @override
  String downloading(int percent) {
    return 'डाउनलोड हो रहा है… $percent%';
  }

  @override
  String get later => 'बाद में';

  @override
  String get updateFailed =>
      'अपडेट नहीं जाँच सके। अपना इंटरनेट देखें और फिर कोशिश करें।';

  @override
  String installFailed(String error) {
    return 'अपडेट इंस्टॉल नहीं हो सका: $error';
  }

  @override
  String get updatesNote =>
      'Anatomo इंटरनेट का इस्तेमाल सिर्फ़ तब करता है जब आप यह बटन दबाते हैं। नए वर्ज़न ऐप के GitHub रिलीज़ से आते हैं।';

  @override
  String get about => 'जानकारी';

  @override
  String get sourceCode => 'सोर्स कोड';

  @override
  String get models3d => '3D मॉडल';

  @override
  String get modelsCredit =>
      'पुरुष शरीर: BodyParts3D 4.0, © The Database Center for Life Science (CC BY 4.0)। महिला शरीर: HuBMAP 3D Reference Organ Set for Female v1.5, Kristen Browne और Heidi Schlehlein (CC BY 4.0)। दोनों फ़ोन के लिए हल्के किए गए हैं। पुरुष शरीर के फेफड़े और लिवर महिला सेट से फिट किए गए हैं। महिला शरीर का कंकाल और मांसपेशियाँ पुरुष शरीर से लेकर ढाली गई हैं।';

  @override
  String get privacy => 'प्राइवेसी';

  @override
  String get privacyText =>
      'Anatomo बिना इंटरनेट चलता है। कोई अकाउंट नहीं, कोई विज्ञापन नहीं, कोई ट्रैकिंग नहीं। आपकी कोई जानकारी डिवाइस से बाहर नहीं जाती।';

  @override
  String get disclaimerTitle => 'सीखने के लिए';

  @override
  String get disclaimer =>
      'Anatomo सीखने के लिए बना है। यह डॉक्टरी सलाह नहीं है। अपनी सेहत के बारे में डॉक्टर से बात करें।';

  @override
  String get hint2d => 'किसी भी हिस्से पर टैप करें · ज़ूम के लिए पिंच करें';

  @override
  String get hintDesktop =>
      'किसी हिस्से पर क्लिक करें · ज़ूम के लिए स्क्रॉल करें · खिसकाने के लिए खींचें';

  @override
  String get hiddenHere =>
      'यह हिस्सा इस तरफ़ से नहीं दिखता। दूसरी तरफ़ से देखें, या इसके आगे की परतें बंद करें।';

  @override
  String get fittedFromMale =>
      'महिला शरीर में यह हिस्सा पुरुष शरीर से लेकर ढाला गया है।';

  @override
  String get fittedFromFemale =>
      'पुरुष शरीर में यह हिस्सा महिला शरीर से लेकर ढाला गया है।';

  @override
  String get layers => 'परतें';

  @override
  String get explore => 'देखें';

  @override
  String get selectPartTitle => 'शरीर के किसी भी हिस्से पर क्लिक करें';

  @override
  String get selectPartText =>
      'उसका कार्ड यहाँ खुलेगा: वह क्या करता है, उसके लिए क्या अच्छा है और क्या नुकसान करता है।';

  @override
  String get keyboard => 'कीबोर्ड';

  @override
  String get zoomIn => 'ज़ूम इन';

  @override
  String get zoomOut => 'ज़ूम आउट';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get pack3dTitle => '3D पैक';

  @override
  String pack3dNote(int size) {
    return 'शरीर को 3D में घुमाएँ और अलग-अलग करके देखें। एक बार डाउनलोड होता है (लगभग $size MB), फिर बिना इंटरनेट चलता है।';
  }

  @override
  String get pack3dDownload => 'डाउनलोड करें';

  @override
  String get pack3dReady =>
      '3D पैक इंस्टॉल है। शरीर के नीचे 2D और 3D के बीच बदलें।';

  @override
  String get pack3dRemove => 'हटाएँ';

  @override
  String get pack3dFailed =>
      '3D पैक डाउनलोड नहीं हो सका। इंटरनेट कनेक्शन जाँचें और फिर कोशिश करें।';
}
