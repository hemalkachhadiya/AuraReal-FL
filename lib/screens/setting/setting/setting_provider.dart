import 'package:aura_real/aura_real.dart';

class SettingProvider extends ChangeNotifier {
  bool isNotificationEnabled = true;

  void toggleNotification(bool value) {
    isNotificationEnabled = value;
    notifyListeners();
  }
}
