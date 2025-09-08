import 'package:aura_real/apis/auth_apis.dart';
import 'package:aura_real/aura_real.dart';

class SettingProvider extends ChangeNotifier {
  bool isNotificationEnabled = true;

  void toggleNotification(bool value) {
    isNotificationEnabled = value;
    notifyListeners();
  }

  bool loader = false;

  Future<void> logoutTap(BuildContext context) async {
    if (userData == null || userData?.id == null) return;
    loader = true;
    notifyListeners();
    final result = await AuthApis.logoutAPI(userId: userData!.id!);
    if (result) {
      if (context.mounted) {
        logoutUser();
        context.navigator.pop(context);
        context.navigator.pushNamedAndRemoveUntil(
          SignInScreen.routeName,
          (_) => false,
        );
      }
    }
    loader = false;
    notifyListeners();
  }



// Usage in buildTabWidget:
//   buildTabWidget(
//   provider: provider,
//   onTap: () {
//   _showLogoutDialog(context, provider);
//   },
//   title: context.l10n?.logout ?? "",
//   img: AssetRes.logoutIcon,
//   ),
}
