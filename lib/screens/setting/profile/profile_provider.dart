import 'package:aura_real/apis/auth_apis.dart';
import 'package:aura_real/aura_real.dart';

class ProfileProvider extends ChangeNotifier {
  TextEditingController fullNameController = TextEditingController(text: "");
  TextEditingController emailController = TextEditingController(text: "");
  TextEditingController mobileController = TextEditingController(text: "");

  bool loader = false;
  Profile? profileData;

  ProfileProvider() {
    init();
  }

  Future<void> init() async {
    await getUserProfileAPI();
  }

  Future<void> getUserProfileAPI() async {
    if (userData == null || userData?.id == null) return;
    loader = true;
    notifyListeners();
    print("Get Profile ---- ${userData?.id}");
    final result = await AuthApis.getUserProfile(userId: userData!.id!);
    if (result != null) {
      profileData = result;
      print("profileData    $profileData");

      notifyListeners();
    }
    loader = false;
    notifyListeners();
  }
}
