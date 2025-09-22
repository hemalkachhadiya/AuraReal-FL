import 'package:aura_real/aura_real.dart';

class DashboardProvider extends ChangeNotifier {
  DashboardProvider() {
    init();
  }

  bool loader = false;

  Future<void> init() async {
    try {
      loader = true;
      notifyListeners();
      requestCameraPermission(navigatorKey.currentState!.context,);
      // Get location first
      await GetLocationService.getCurrentLocation(
        navigatorKey.currentState!.context,
      );

      // Call your update API here
      await _callUpdateApi();
    } catch (e) {
      // Handle error if needed
      print('Error in dashboard init: $e');
    } finally {
      loader = false;
      notifyListeners();
    }
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


  // Add your API call method
  Future<void> _callUpdateApi() async {
    try {
      // Get user data from preferences

      if (userData == null) {
        print('No user data found in preferences');
        return;
      }

      // Get FCM token
      final fcmToken = PrefService.getString(PrefKeys.fcmToken);

      print('Calling update profile API for user: $fcmToken');

      print("userData?.id--------- ${userData?.id}");
      final result = await AuthApis.userUpdateProfile(
        userId: userData?.id,
        fcmToken: fcmToken,
      );

      if (result) {
        print('Profile updated successfully on dashboard load');
      } else {
        print('Failed to update profile on dashboard load');
      }
    } catch (e) {
      print('Error calling update API: $e');


    }
  }
}
