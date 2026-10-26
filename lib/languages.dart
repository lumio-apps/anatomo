/// The languages Anatomo is translated into.
class AppLanguage {
  const AppLanguage(this.code, this.nativeName, this.englishName);

  final String code;
  final String nativeName;
  final String englishName;
}

const List<AppLanguage> kLanguages = [
  AppLanguage('en', 'English', 'English'),
  AppLanguage('hi', 'हिन्दी', 'Hindi'),
  AppLanguage('hy', 'Հայերեն', 'Armenian'),
  AppLanguage('ru', 'Русский', 'Russian'),
  AppLanguage('es', 'Español', 'Spanish'),
  AppLanguage('fr', 'Français', 'French'),
  AppLanguage('de', 'Deutsch', 'German'),
  AppLanguage('ar', 'العربية', 'Arabic'),
  AppLanguage('zh', '中文', 'Chinese'),
  AppLanguage('pt', 'Português', 'Portuguese'),
  AppLanguage('ja', '日本語', 'Japanese'),
  AppLanguage('ko', '한국어', 'Korean'),
  AppLanguage('it', 'Italiano', 'Italian'),
];

AppLanguage languageFor(String code) => kLanguages.firstWhere(
      (l) => l.code == code,
      orElse: () => kLanguages.first,
    );
