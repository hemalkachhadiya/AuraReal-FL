import 'package:aura_real/aura_real.dart';

class AppProvider extends ChangeNotifier {
  Locale? locale;

  List<Locale> get languageList => [const Locale("en", "US"), const Locale("ar", "AR")];

  AppProvider() {
    init();
  }

  void init() {
    final locale = getLanStrToLocale(
      PrefService.getString(PrefKeys.localLanguage) ?? 'en_US', // Default to English if null
    );
    this.locale = locale;
    notifyListeners();
  }

  Future<void> changeLanguage(Locale locale) async {
    this.locale = locale;
    notifyListeners();
    await PrefService.set(PrefKeys.localLanguage, getLanLocaleToStr(locale));
  }

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

  String getLanLocaleToStr(Locale locale) {
    return "${locale.languageCode}_${locale.countryCode}";
  }
}