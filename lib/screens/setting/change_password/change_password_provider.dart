import 'package:aura_real/aura_real.dart';

class ChangePasswordProvider extends ChangeNotifier {
  bool loader = false;

  /// Controllers
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  /// Error messages
  String currentPasswordError = "";
  String newPasswordError = "";
  String confirmPasswordError = "";

  /// Password visibility
  bool isCurrentPwdVisible = false;
  bool isNewPwdVisible = false;
  bool isConfirmPwdVisible = false;

  void onCurrentPwdVisibilityChanged() {
    isCurrentPwdVisible = !isCurrentPwdVisible;
    notifyListeners();
  }

  void onNewPwdVisibilityChanged() {
    isNewPwdVisible = !isNewPwdVisible;
    notifyListeners();
  }

  void onConfirmPwdVisibilityChanged() {
    isConfirmPwdVisible = !isConfirmPwdVisible;
    notifyListeners();
  }

  bool get isFormValid {
    return currentPasswordError.isEmpty &&
        newPasswordError.isEmpty &&
        confirmPasswordError.isEmpty &&
        currentPasswordController.text.trim().isNotEmpty &&
        newPasswordController.text.trim().isNotEmpty &&
        confirmPasswordController.text.trim().isNotEmpty;
  }

  void onCurrentPasswordChanged(String value, BuildContext context) {
    validate(context);
  }

  void onNewPasswordChanged(String value, BuildContext context) {
    validate(context);
  }

  void onConfirmPasswordChanged(String value, BuildContext context) {
    validate(context);
  }

  /// Validate inputs
  bool validate(BuildContext context) {
    final currentPassword = currentPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    // Current password validation
    if (currentPassword.isEmpty) {
      currentPasswordError =
          context.l10n?.currentPasswordRequired ??
          "Current password is required";
    } else {
      currentPasswordError = "";
    }

    // New password validation
    if (newPassword.isEmpty) {
      newPasswordError =
          context.l10n?.passwordIsRequired ?? "New password is required";
    } else if (newPassword.length < 8) {
      newPasswordError =
          context.l10n?.passwordMinLength ??
          "Password must be at least 8 characters";
    } else if (!newPassword.isValidPassword()) {
      newPasswordError =
          context.l10n?.passwordInvalid ??
          "Password must contain uppercase, lowercase, number & special character";
    } else {
      newPasswordError = "";
    }

    // Confirm password validation
    if (confirmPassword.isEmpty) {
      confirmPasswordError =
          context.l10n?.confirmPasswordRequired ??
          "Confirm password is required";
    } else if (confirmPassword != newPassword) {
      confirmPasswordError =
          context.l10n?.passwordsDoNotMatch ?? "Passwords do not match";
    } else {
      confirmPasswordError = "";
    }

    notifyListeners();
    return currentPasswordError.isEmpty &&
        newPasswordError.isEmpty &&
        confirmPasswordError.isEmpty;
  }

  /// Submit password change
  Future<void> onChangePasswordTap(BuildContext context) async {
    if (userData == null || userData?.id == null) return;
    if (!validate(context)) return;

    loader = true;
    notifyListeners();

    try {
      final result = await AuthApis.changePasswordAPI(
        userId: userData!.id!,
        oldPassword: '${currentPasswordController.text.trim()}',
        newPassword: '${confirmPasswordController.text.trim()}',
      );
      if (result) {
        Navigator.pop(context);
      }
      loader = false;
      notifyListeners();
    } catch (e) {
      loader = false;
      notifyListeners();
      // context.showErrorDialog(
      //   title: context.l10n?.error ?? "Error",
      //   description: context.l10n?.somethingWentWrong ?? "Something went wrong. Please try again.",
      // );
    }
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
