import 'package:aura_real/aura_real.dart';
class PrefService {
  static late SharedPreferences prefs;

  static Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  static Future<bool> set(String key, dynamic value) async {
    if (value is int) {
      return prefs.setInt(key, value);
    } else if (value is double) {
      return prefs.setDouble(key, value);
    } else if (value is String) {
      return prefs.setString(key, value);
    } else if (value is bool) {
      return prefs.setBool(key, value);
    } else if (value is List<String>) {
      return prefs.setStringList(key, value);
    }
    return false;
  }

  static int getInt(String key) {
    return prefs.getInt(key) ?? 0;
  }

  static double getDouble(String key) {
    return prefs.getDouble(key) ?? 0;
  }

  static String getString(String key) {
    return prefs.getString(key) ?? '';
  }

  static bool getBool(String key) {
    return prefs.getBool(key) ?? false;
  }

  static List<String> getStringList(String key) {
    return prefs.getStringList(key) ?? [];
  }

  static Future<bool> removeKey(String key) async {
    return await prefs.remove(key);
  }

  static Future<bool> clear() async {
    return await prefs.clear();
  }
}
