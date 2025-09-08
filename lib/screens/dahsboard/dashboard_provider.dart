import 'package:aura_real/apis/auth_apis.dart';
import 'package:aura_real/aura_real.dart';

class DashboardProvider extends ChangeNotifier {
  DashboardProvider() {
    init();
  }

  Future<void> init() async {
    await GetLocationService.getCurrentLocation(
      navigatorKey.currentState!.context,
    );

  }

  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  // Optional: Get current tab name
  String get currentTabName {
    switch (_selectedIndex) {
      case 0:
        return 'Home';
      case 1:
        return 'Rating';
      case 2:
        return 'Chat';
      case 3:
        return 'Settings';
      default:
        return 'Home';
    }
  }


}
