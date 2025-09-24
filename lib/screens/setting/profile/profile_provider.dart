import 'dart:io';
import 'dart:math';

import 'package:aura_real/apis/auth_apis.dart';
import 'package:aura_real/aura_real.dart';

class ProfileProvider extends ChangeNotifier {
  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileController = TextEditingController();

  bool loader = false;
  Profile? profileData;
  File? selectedImage; // Added for image selection

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

  /// Handle image selection
  Future<void> pickImage(BuildContext context) async {
    try {
      final File? imageFile = await openMediaPicker(
        context,
      );

      if (imageFile != null) {
        selectedImage = imageFile;
        notifyListeners();
        print("✅ Image selected: ${selectedImage!.path}");
      }
    } catch (e) {
      print("❌ Error selecting image: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error selecting image: $e")));
    }
  }

  /// Clear selected image
  void clearSelectedImage() {
    selectedImage = null;
    notifyListeners();
  }

  /// Get current profile image URL or selected image
  String? get currentImageUrl {
    if (selectedImage != null) {
      return selectedImage!.path; // Local file path
    }
    return profileData?.profileImage != null &&
            profileData!.profileImage!.isNotEmpty
        ? "${EndPoints.domain}${profileData!.profileImage}"
        : null;
  }

  /// Check if user has selected a new image
  bool get hasNewImage => selectedImage != null;

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

  // Helper method to get userData safely
  LoginRes? get userData {
    try {
      final str = PrefService.getString(PrefKeys.userData);
      if (str.isNotEmpty) {
        return LoginRes.fromJson(jsonDecode(str));
      }
    } catch (e) {
      print("Error getting userData: $e");
    }
    return null;
  }

  Future<void> init() async {
    await getUserProfileAPI();
  }

  Future<void> getUserProfileAPI() async {
    if (userData == null || userData?.id == null) return;
    loader = true;
    notifyListeners();
    print("Get Profile ---- ${userData?.id}");

    try {
      final result = await AuthApis.getUserProfile(userId: userData!.id!);
      if (result != null) {
        profileData = result;
        fullNameController.text = result.fullName ?? userData?.fullName ?? '';
        emailController.text = result.email ?? userData?.email ?? '';
        mobileController.text =
            result.phoneNumber ?? userData?.phoneNumber ?? '';
        print("profileData: $profileData");
      }
    } catch (e) {
      print("❌ Error fetching profile: $e");
    }

    loader = false;
    notifyListeners();
  }

  Future<void> userUpdateAPI(BuildContext context) async {
    if (!isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all required fields correctly"),
        ),
      );
      return;
    }

    if (userData == null || userData?.id == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("User data not found")));
      return;
    }

    loader = true;
    notifyListeners();

    try {
      print("Updating Profile ---- ${userData?.id}");

      String fcmToken = PrefService.getString(PrefKeys.fcmToken);
      print("fcmToken: $fcmToken");

      final result = await AuthApis.userUpdateProfile(
        fullName: fullNameController.text.trim(),
        email: emailController.text.trim(),
        phoneNumber: mobileController.text.trim(),
        userId: userData?.id ?? "",
        profileImage: selectedImage?.path,
        // Pass the file path as String
        fcmToken: fcmToken,
      );

      if (result) {


        // Clear selected image after successful update
        selectedImage = null;

        Navigator.pop(context);
      } else {
        showErrorMsg("Failed to update profile. Please try again.");

      }
    } catch (e) {
      print("Error updating profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error updating profile: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }

    loader = false;
    notifyListeners();
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    super.dispose();
  }
}
