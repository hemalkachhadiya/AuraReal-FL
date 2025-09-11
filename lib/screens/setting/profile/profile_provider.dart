import 'package:aura_real/apis/auth_apis.dart';
import 'package:aura_real/aura_real.dart';

class ProfileProvider extends ChangeNotifier {
  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileController = TextEditingController();

  bool loader = false;
  Profile? profileData;

  /// Error messages
  String fullNameError = "";
  String emailError = "";
  String mobileError = "";

  bool get isFormValid {
    return fullNameError.isEmpty &&
        emailError.isEmpty &&
        mobileError.isEmpty &&
        fullNameController.text.trim().isNotEmpty &&
        emailController.text.trim().isNotEmpty &&
        mobileController.text.trim().isNotEmpty;
  }

  void onFullNameChanged(String value) {
    validate();
  }

  void onEmailChanged(String value) {
    validate();
  }

  void onMobileChanged(String value) {
    validate();
  }

  void onPasswordChanged(String value) {
    validate();
  }

  /// Validate inputs
  bool validate() {
    final fullName = fullNameController.text.trim();
    final email = emailController.text.trim();
    final mobile = mobileController.text.trim();

    // Full name validation
    if (fullName.isEmpty) {
      fullNameError =
          navigatorKey.currentState?.context.l10n?.fullNameIsRequired ??
          "Full name is required";
    } else {
      fullNameError = "";
    }

    // Email validation
    if (email.isEmpty) {
      emailError =
          navigatorKey.currentState?.context.l10n?.emailIsRequired ??
          "Email is required";
    } else if (!email.isEmailValid()) {
      emailError =
          navigatorKey.currentState?.context.l10n?.invalidEmail ??
          "Enter a valid email address";
    } else if (email.hasSpaces()) {
      emailError =
          navigatorKey.currentState?.context.l10n?.emailShouldNotContainSpace ??
          "Email should not contain spaces";
    } else {
      emailError = "";
    }

    // Mobile validation
    if (mobile.isEmpty) {
      mobileError =
          navigatorKey.currentState?.context.l10n?.mobileIsRequired ??
          "Mobile number is required";
    } else if (!mobile.isPhoneValid()) {
      mobileError =
          navigatorKey.currentState?.context.l10n?.invalidMobile ??
          "Enter a valid mobile number";
    } else {
      mobileError = "";
    }

    notifyListeners();
    return fullNameError.isEmpty && emailError.isEmpty && mobileError.isEmpty;
  }

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
      fullNameController.text = userData?.fullName ?? '';
      emailController.text = userData?.email ?? '';
      mobileController.text = userData?.phoneNumber ?? '';
      print("profileData    $profileData");

      notifyListeners();
    }
    loader = false;
    notifyListeners();
  }

  Future<void> userUpdateAPI() async {
    if (!isFormValid) return;
    if (isFormValid) {
      if (userData == null || userData?.id == null) return;
      loader = true;
      notifyListeners();
      print("Get Profile ---- ${userData?.id}");
      final result = await AuthApis.userUpdateProfile(
        fullName: fullNameController.text.trim(),
        email: emailController.text.trim(),
        phoneNumber: mobileController.text.trim(),
        userId: userData?.id ?? "",
      );
      if (result != null) {
        profileData = result;
        print("profileData    $profileData");

        notifyListeners();
      }
      loader = false;
      notifyListeners();
    }
  }
}
