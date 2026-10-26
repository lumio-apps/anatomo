// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get welcomeTitle => 'Добро пожаловать в Anatomo';

  @override
  String get welcomeSubtitle =>
      'Выберите язык. Его можно изменить в любое время в настройках.';

  @override
  String get continueButton => 'Продолжить';

  @override
  String get offlineNote =>
      'Работает без интернета · Без аккаунта · Без слежки';

  @override
  String get male => 'Мужское';

  @override
  String get female => 'Женское';

  @override
  String get layerOrgans => 'Органы';

  @override
  String get layerBones => 'Кости';

  @override
  String get layerMuscles => 'Мышцы';

  @override
  String get layerNerves => 'Нервы';

  @override
  String get layerVessels => 'Сосуды';

  @override
  String get layerSkin => 'Тело';

  @override
  String get viewFront => 'Спереди';

  @override
  String get viewBack => 'Сзади';

  @override
  String get viewSide => 'Сбоку';

  @override
  String get resetView => 'Сбросить вид';

  @override
  String get spreadApart => 'Разобрать';

  @override
  String get assembled => 'Собрано';

  @override
  String get hint =>
      'Тяните, чтобы вращать · сведите пальцы для масштаба · нажмите на любую часть';

  @override
  String loading(int percent) {
    return 'Загрузка 3D-тела… $percent%';
  }

  @override
  String get errorWebgl =>
      'Этот телефон не может показать 3D-тело. Обновите Android System WebView и попробуйте снова.';

  @override
  String get errorLoad => 'Не удалось загрузить 3D-тело.';

  @override
  String get retry => 'Повторить';

  @override
  String get tabAbout => 'Что делает';

  @override
  String get tabGood => 'Что полезно';

  @override
  String get tabBad => 'Что вредно';

  @override
  String partLabel(String name) {
    return 'Часть: $name';
  }

  @override
  String get notMedical => 'Только для обучения. Не медицинский совет.';

  @override
  String get close => 'Закрыть';

  @override
  String get showWholeBody => 'Показать всё тело';

  @override
  String get searchParts => 'Поиск частей';

  @override
  String get settings => 'Настройки';

  @override
  String get allParts => 'Все части';

  @override
  String partsCount(int count) {
    return 'Частей: $count';
  }

  @override
  String get searchHint => 'Ищите: сердце, бедренная кость, печень…';

  @override
  String get filterAll => 'Все';

  @override
  String get detailedStructures => 'Подробные структуры';

  @override
  String noResults(String query) {
    return 'По запросу «$query» ничего не найдено.';
  }

  @override
  String get femaleNote =>
      'Скелет и мышцы женского тела адаптированы из мужского тела.';

  @override
  String get general => 'Общие';

  @override
  String get appearance => 'Оформление';

  @override
  String get themeAuto => 'Авто';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get quality => 'Графика';

  @override
  String get qualityAuto => 'Авто';

  @override
  String get qualityLow => 'Низкое';

  @override
  String get qualityMedium => 'Среднее';

  @override
  String get qualityHigh => 'Высокое';

  @override
  String get qualityNote =>
      'Низкое качество работает быстрее на старых телефонах. Авто выбирает лучший уровень для вашего телефона. При смене настройки 3D-вид загружается заново.';

  @override
  String get favorites => 'Избранное';

  @override
  String get noFavorites =>
      'Пока ничего нет. Нажмите на звёздочку у части тела, чтобы добавить её сюда.';

  @override
  String get addFavorite => 'В избранное';

  @override
  String get removeFavorite => 'Убрать из избранного';

  @override
  String get copyText => 'Копировать текст';

  @override
  String get copied => 'Скопировано в буфер обмена';

  @override
  String get quiz => 'Викторина';

  @override
  String get quizWhichPart => 'Что это за часть тела?';

  @override
  String quizWhichSystem(String name) {
    return 'К какой системе органов относится: $name?';
  }

  @override
  String quizQuestionOf(int n, int total) {
    return 'Вопрос $n из $total';
  }

  @override
  String get quizCorrect => 'Верно!';

  @override
  String quizWrong(String answer) {
    return 'Не совсем. Правильный ответ: $answer.';
  }

  @override
  String get quizNext => 'Далее';

  @override
  String get quizFinish => 'Показать результат';

  @override
  String quizScore(int score, int total) {
    return 'Верных ответов: $score из $total';
  }

  @override
  String quizBest(int best) {
    return 'Лучший результат: $best';
  }

  @override
  String get quizPlayAgain => 'Играть снова';

  @override
  String get language => 'Язык';

  @override
  String get body => 'Тело';

  @override
  String get updates => 'Обновления';

  @override
  String versionLabel(String version) {
    return 'Anatomo $version';
  }

  @override
  String get checkForUpdates => 'Проверить обновления';

  @override
  String get checking => 'Проверка…';

  @override
  String get upToDate => 'У вас последняя версия.';

  @override
  String updateAvailable(String version) {
    return 'Доступна версия $version';
  }

  @override
  String get downloadInstall => 'Скачать и установить';

  @override
  String downloading(int percent) {
    return 'Загрузка… $percent%';
  }

  @override
  String get later => 'Позже';

  @override
  String get updateFailed =>
      'Не удалось проверить обновления. Проверьте подключение к интернету и попробуйте снова.';

  @override
  String installFailed(String error) {
    return 'Не удалось установить обновление: $error';
  }

  @override
  String get updatesNote =>
      'Anatomo использует интернет только когда вы нажимаете эту кнопку. Новые версии берутся из релизов приложения на GitHub.';

  @override
  String get about => 'О приложении';

  @override
  String get sourceCode => 'Исходный код';

  @override
  String get models3d => '3D-модели';

  @override
  String get modelsCredit =>
      'Мужское тело: BodyParts3D 4.0, © The Database Center for Life Science (CC BY 4.0). Женское тело: HuBMAP 3D Reference Organ Set for Female v1.5, Kristen Browne и Heidi Schlehlein (CC BY 4.0). Обе модели упрощены для телефонов. Лёгкие и печень мужского тела подогнаны из женского набора. Скелет и мышцы женского тела адаптированы из мужского тела.';

  @override
  String get privacy => 'Конфиденциальность';

  @override
  String get privacyText =>
      'Anatomo работает без интернета. Без аккаунта, без рекламы, без слежки. Ничего о вас не покидает устройство.';

  @override
  String get disclaimerTitle => 'Для обучения';

  @override
  String get disclaimer =>
      'Anatomo создан для обучения. Это не медицинский совет. О своём здоровье говорите с врачом.';

  @override
  String get hint2d =>
      'Нажмите на любую часть · разведите пальцы для увеличения';

  @override
  String get hintDesktop =>
      'Нажмите на часть · колесо мыши для масштаба · перетаскивайте для сдвига';

  @override
  String get hiddenHere =>
      'Эту часть не видно с этой стороны. Посмотрите с другой стороны или отключите слои перед ней.';

  @override
  String get fittedFromMale =>
      'В женском теле эта часть адаптирована из мужского тела.';

  @override
  String get fittedFromFemale =>
      'В мужском теле эта часть адаптирована из женского тела.';

  @override
  String get layers => 'Слои';

  @override
  String get explore => 'Обзор';

  @override
  String get selectPartTitle => 'Нажмите на любую часть тела';

  @override
  String get selectPartText =>
      'Здесь откроется её карточка: что она делает, что для неё полезно и что вредит.';

  @override
  String get keyboard => 'Клавиатура';

  @override
  String get zoomIn => 'Увеличить';

  @override
  String get zoomOut => 'Уменьшить';

  @override
  String get cancel => 'Отмена';

  @override
  String get pack3dTitle => '3D-пакет';

  @override
  String pack3dNote(int size) {
    return 'Вращайте тело и разводите его части в 3D. Скачивается один раз (около $size МБ), потом работает без интернета.';
  }

  @override
  String get pack3dDownload => 'Скачать';

  @override
  String get pack3dReady =>
      '3D-пакет установлен. Переключайтесь между 2D и 3D под телом.';

  @override
  String get pack3dRemove => 'Удалить';

  @override
  String get pack3dFailed =>
      'Не удалось скачать 3D-пакет. Проверьте подключение к интернету и попробуйте снова.';
}
