import 'package:aura_real/aura_real.dart';

class AppProvider extends ChangeNotifier {
  Locale? locale;
  bool loader = false;

  // Language list - English and Arabic only
  List<Locale> languageList = [
    const Locale("en", "US"),
    const Locale("ar", "SA"),
  ];

  AppProvider() {
    init();
  }

  // Initialize app settings
  Future<void> init() async {
    try {
      final savedLanguage =
          PrefService.getString(PrefKeys.localLanguage);
      locale = getLanStrToLocale(savedLanguage);
      print('App initialized with language: ${locale?.languageCode}');
      getFCMToken();

    } catch (e) {
      print('Error initializing app: $e');
      locale = const Locale("en", "US");
    }
    notifyListeners();
  }

  // Change language
  Future<void> changeLanguage(Locale newLocale) async {
    try {
      loader = true;
      notifyListeners();

      print("Starting language change to: ${newLocale.languageCode}");

      // Add small delay to show loading
      await Future.delayed(const Duration(milliseconds: 800));

      // Update locale
      locale = newLocale;

      // Save to preferences
      await PrefService.set(
        PrefKeys.localLanguage,
        getLanLocaleToStr(newLocale),
      );
      print("get print language=======");

      print("Language changed successfully to: ${newLocale.languageCode}");

      // Notify listeners first with new locale
      notifyListeners();

      // Small delay before stopping loader
      await Future.delayed(const Duration(milliseconds: 200));
    } catch (e) {
      print('Error changing language: $e');
      // Revert locale on error
      final savedLanguage =
          PrefService.getString(PrefKeys.localLanguage) ?? 'en_US';
      locale = getLanStrToLocale(savedLanguage);
    } finally {
      loader = false;
      notifyListeners();
    }
  }

  // Convert string to Locale
  Locale getLanStrToLocale(String lan) {
    if (lan.isEmpty) {
      return const Locale("en", "US");
    }
    final parts = lan.split('_');
    if (parts.length >= 2) {
      return Locale(parts[0], parts[1]);
    }
    return const Locale("en", "US"); // Fallback
  }

  // Convert Locale to string
  String getLanLocaleToStr(Locale locale) {
    return "${locale.languageCode}_${locale.countryCode}";
  }

  // Get language display name
  String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'ar':
        return 'العربية';
      default:
        return 'English';
    }
  }

  // Get language flag/icon asset path
  String getLanguageIcon(String languageCode) {
    switch (languageCode) {
      case 'en':
        return AssetRes.enIcon; // Your English flag asset
      case 'ar':
        return AssetRes.arIcon; // Your Arabic flag asset
      default:
        return AssetRes.enIcon;
    }
  }

  // Check if current language is Arabic (RTL)
  bool get isArabic => locale?.languageCode == 'ar';

  // Check if current language is English
  bool get isEnglish => locale?.languageCode == 'en';

  // Get text direction based on language
  TextDirection get textDirection =>
      isArabic ? TextDirection.rtl : TextDirection.ltr;

  // Reset to default language
  Future<void> resetToDefaultLanguage() async {
    await changeLanguage(const Locale("en", "US"));
  }

  // Force refresh
  void refresh() {
    notifyListeners();
  }
}
