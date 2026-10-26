// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get welcomeTitle => 'Anatomo へようこそ';

  @override
  String get welcomeSubtitle => '言語を選んでください。設定でいつでも変更できます。';

  @override
  String get continueButton => '続ける';

  @override
  String get offlineNote => 'オフラインで使える · アカウント不要 · トラッキングなし';

  @override
  String get male => '男性';

  @override
  String get female => '女性';

  @override
  String get layerOrgans => '臓器';

  @override
  String get layerBones => '骨';

  @override
  String get layerMuscles => '筋肉';

  @override
  String get layerNerves => '神経';

  @override
  String get layerVessels => '血管';

  @override
  String get layerSkin => '体';

  @override
  String get viewFront => '前';

  @override
  String get viewBack => '後ろ';

  @override
  String get viewSide => '横';

  @override
  String get resetView => '表示をリセット';

  @override
  String get spreadApart => '分解する';

  @override
  String get assembled => '組み立て済み';

  @override
  String get hint => 'ドラッグで回転 · ピンチで拡大 · どこでもタップ';

  @override
  String loading(int percent) {
    return '3D の体を読み込み中… $percent%';
  }

  @override
  String get errorWebgl =>
      'この端末では 3D の体を表示できません。Android System WebView を更新して、もう一度お試しください。';

  @override
  String get errorLoad => '3D の体を読み込めませんでした。';

  @override
  String get retry => '再試行';

  @override
  String get tabAbout => 'はたらき';

  @override
  String get tabGood => '良いこと';

  @override
  String get tabBad => '悪いこと';

  @override
  String partLabel(String name) {
    return '部位：$name';
  }

  @override
  String get notMedical => '学習用です。医療上の助言ではありません。';

  @override
  String get close => '閉じる';

  @override
  String get showWholeBody => '体全体を表示';

  @override
  String get searchParts => '部位を検索';

  @override
  String get settings => '設定';

  @override
  String get allParts => 'すべての部位';

  @override
  String partsCount(int count) {
    return '$count 部位';
  }

  @override
  String get searchHint => '心臓、大腿骨、肝臓などを検索…';

  @override
  String get filterAll => 'すべて';

  @override
  String get detailedStructures => '詳しい構造';

  @override
  String noResults(String query) {
    return '「$query」は見つかりませんでした。';
  }

  @override
  String get femaleNote => '女性の体では臓器、皮膚、骨格の一部を表示します。骨格全体と筋肉は男性の体にあります。';

  @override
  String get general => '一般';

  @override
  String get appearance => '外観';

  @override
  String get themeAuto => '自動';

  @override
  String get themeLight => 'ライト';

  @override
  String get themeDark => 'ダーク';

  @override
  String get quality => 'グラフィックス';

  @override
  String get qualityAuto => '自動';

  @override
  String get qualityLow => '低';

  @override
  String get qualityMedium => '中';

  @override
  String get qualityHigh => '高';

  @override
  String get qualityNote =>
      '画質を下げると古いスマホでも速く動きます。自動はお使いのスマホに合うレベルを選びます。変更すると 3D 表示が再読み込みされます。';

  @override
  String get favorites => 'お気に入り';

  @override
  String get noFavorites => 'お気に入りはまだありません。部位の星をタップするとここに追加されます。';

  @override
  String get addFavorite => 'お気に入りに追加';

  @override
  String get removeFavorite => 'お気に入りから削除';

  @override
  String get copyText => 'テキストをコピー';

  @override
  String get copied => 'クリップボードにコピーしました';

  @override
  String get quiz => 'クイズ';

  @override
  String get quizWhichPart => 'これは体のどの部分でしょう？';

  @override
  String quizWhichSystem(String name) {
    return '$name はどの器官系に属しますか？';
  }

  @override
  String quizQuestionOf(int n, int total) {
    return '$total 問中 $n 問目';
  }

  @override
  String get quizCorrect => '正解！';

  @override
  String quizWrong(String answer) {
    return '惜しい！正解は $answer です。';
  }

  @override
  String get quizNext => '次へ';

  @override
  String get quizFinish => '結果を見る';

  @override
  String quizScore(int score, int total) {
    return '$total 問中 $score 問正解';
  }

  @override
  String quizBest(int best) {
    return 'ベストスコア：$best';
  }

  @override
  String get quizPlayAgain => 'もう一度';

  @override
  String get language => '言語';

  @override
  String get body => '体';

  @override
  String get updates => 'アップデート';

  @override
  String versionLabel(String version) {
    return 'Anatomo $version';
  }

  @override
  String get checkForUpdates => 'アップデートを確認';

  @override
  String get checking => '確認中…';

  @override
  String get upToDate => '最新バージョンです。';

  @override
  String updateAvailable(String version) {
    return 'バージョン $version があります';
  }

  @override
  String get downloadInstall => 'ダウンロードしてインストール';

  @override
  String downloading(int percent) {
    return 'ダウンロード中… $percent%';
  }

  @override
  String get later => 'あとで';

  @override
  String get updateFailed => 'アップデートを確認できませんでした。インターネット接続を確認して、もう一度お試しください。';

  @override
  String installFailed(String error) {
    return 'アップデートをインストールできませんでした：$error';
  }

  @override
  String get updatesNote =>
      'Anatomo がインターネットを使うのは、このボタンを押したときだけです。新しいバージョンはアプリの GitHub リリースから届きます。';

  @override
  String get about => 'このアプリについて';

  @override
  String get sourceCode => 'ソースコード';

  @override
  String get models3d => '3D モデル';

  @override
  String get modelsCredit =>
      '男性の体：BodyParts3D 4.0、© The Database Center for Life Science（CC BY 4.0）。女性の体：HuBMAP 3D Reference Organ Set for Female v1.5、Kristen Browne・Heidi Schlehlein 作（CC BY 4.0）。どちらもスマートフォン向けに軽量化しています。男性の体の肺と肝臓は女性のセットから合わせています。';

  @override
  String get privacy => 'プライバシー';

  @override
  String get privacyText =>
      'Anatomo はオフラインで使えます。アカウントも広告もトラッキングもありません。あなたの情報が端末の外に出ることはありません。';

  @override
  String get disclaimerTitle => '学習用';

  @override
  String get disclaimer =>
      'Anatomo は学習のためのアプリです。医療上の助言ではありません。健康については医師に相談してください。';
}
