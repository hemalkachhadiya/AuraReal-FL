import 'dart:io';
import 'package:aura_real/apis/auth_apis.dart';
import 'package:aura_real/apis/rating_profile_apis.dart';
import 'package:aura_real/aura_real.dart';
import 'package:flutter/material.dart';

class ProfileProvider extends ChangeNotifier {
  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileController = TextEditingController();

  bool loader = false;
  bool createUserLoader = false;
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

  /// Handle image selection
  Future<void> pickImage(BuildContext context) async {
    try {
      final File? imageFile = await openMediaPicker(context);

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

  /// Create User Profile API
  Future<bool> createUserProfileAPI(BuildContext context) async {
    if (userData == null || userData?.id == null) {
      print("Cannot publish profile: User data or ID is null");
      showErrorMsg("User data is missing. Please log in again.");
      return false;
    }

    if (!validate() || selectedImage == null) {
      print("Cannot publish profile: Validation failed or no image selected");
      showErrorMsg(
        "Please fill all required fields and select a profile image.",
      );
      return false;
    }

    createUserLoader = true;
    notifyListeners();

    String? profileImagePath = selectedImage?.path;

    // Basic image validation
    if (profileImagePath != null) {
      final imageFile = File(profileImagePath);
      if (!await imageFile.exists()) {
        print("Profile image file does not exist: $profileImagePath");
        showErrorMsg("Profile image file is invalid. Please select again.");
        createUserLoader = false;
        notifyListeners();
        return false;
      }
    } else {
      print("Profile image path is null");
      showErrorMsg("Please select a profile image.");
      createUserLoader = false;
      notifyListeners();
      return false;
    }

    final result = await RatingProfileAPIS.createUserProfileAPI(
      userId: userData!.id!,
      profileImagePath: profileImagePath,
    );

    createUserLoader = false;

    if (result != null && result.statusCode == 200) {
      // Assuming HTTP response
      print("Profile created successfully");
      if (context.mounted) {
        // Navigator.pop(context, true); // Signal success
      }
      clearSelectedImage(); // Clear image after success
      await getUserProfileAPI(); // Refresh profile data
      return true;
    } else {
      print("Failed to create profile. Keeping selectedImage for retry.");
      showErrorMsg("Failed to create profile. Please try again.");
      notifyListeners();
      return false;
    }
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

  /// Update User Profile API
  Future<bool> userUpdateAPI(BuildContext context) async {
    if (!isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all required fields correctly"),
        ),
      );
      return false;
    }

    if (userData == null || userData?.id == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("User data not found")));
      return false;
    }

    loader = true;
    notifyListeners();

    try {
      print("Updating Profile ---- ${userData?.id}");
      String fcmToken = PrefService.getString(PrefKeys.fcmToken);
      print("fcmToken: $fcmToken");

      bool updateSuccess = false;

      // If a new image is selected, create a new profile
      if (selectedImage != null) {
        final createSuccess = await createUserProfileAPI(context);
        if (!createSuccess) {
          return false; // Exit if profile creation fails
        }
        updateSuccess = true; // Mark as successful if image upload worked
      } else {
        // Update existing profile without image
        final updateResult = await AuthApis.userUpdateProfile(
          fullName: fullNameController.text.trim(),
          email: emailController.text.trim(),
          phoneNumber: mobileController.text.trim(),
          userId: userData!.id!,
          profileImage: null,
          // No new image
          fcmToken: fcmToken,
        );
        updateSuccess = updateResult;
      }

      if (updateSuccess) {
        await getUserProfileAPI(); // Refresh profile data
        if (context.mounted) {
          // Navigator.pop(context); // Close the screen
        }
        return true;
      } else {
        showErrorMsg("Failed to update profile. Please try again.");
        return false;
      }
    } catch (e) {
      print("Error updating profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error updating profile: $e"),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    } finally {
      loader = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    super.dispose();
  }
}
