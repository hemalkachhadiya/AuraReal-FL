import 'package:aura_real/aura_real.dart';
import 'package:aura_real/screens/auth/your_location/your_location_screen.dart';

class CreateNewPasswordProvider extends ChangeNotifier {
  final TextEditingController newPasseController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();

  String newPassword = "";
  String confirmPassword = "";
  bool loader = false;
  bool isNewPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  String newPasswordError = "";
  String confirmPasswordError = "";

  /// Setters
  void setNewPassword(BuildContext context, String value) {
    newPassword = value;
    validateNewPassword(context);
    notifyListeners();
  }

  void setConfirmPassword(BuildContext context, String value) {
    confirmPassword = value;
    validateConfirmPassword(context);
    notifyListeners();
  }

  /// Toggle visibility
  void toggleNewPasswordVisibility() {
    isNewPasswordVisible = !isNewPasswordVisible;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible = !isConfirmPasswordVisible;
    notifyListeners();
  }

  /// Validation
  bool validateNewPassword(BuildContext context) {
    if (newPassword.isEmpty) {
      newPasswordError = "New password is required";
    } else if (newPassword.length < 6) {
      newPasswordError = "Password must be at least 6 characters";
    } else if (!newPassword.isValidPassword()) {
      newPasswordError =
          context.l10n?.passwordInvalid ??
          "Password must contain uppercase, lowercase, number & special character";
    } else {
      newPasswordError = "";
    }
    return newPasswordError.isEmpty;
  }

  bool validateConfirmPassword(BuildContext context) {
    if (confirmPassword.isEmpty) {
      confirmPasswordError = "Confirm password is required";
    } else if (confirmPassword != newPassword) {
      confirmPasswordError = "Passwords do not match";
    } else if (!confirmPassword.isValidPassword()) {
      confirmPasswordError =
          context.l10n?.passwordInvalid ??
          "Password must contain uppercase, lowercase, number & special character";
    } else {
      confirmPasswordError = "";
    }
    return confirmPasswordError.isEmpty;
  }

  bool validateAll(BuildContext context) {
    final isNewValid = validateNewPassword(context);
    final isConfirmValid = validateConfirmPassword(context);
    notifyListeners();
    return isNewValid && isConfirmValid;
  }

  /// Save action
  Future<void> onSaveTap(BuildContext context) async {
    if (!validateAll(context)) return;

    loader = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      print("password--------------");

      showSuccessToast('Password changed successfully');
      if (context.mounted) {
        context.navigator.pushNamed(YourLocationScreen.routeName);
      }
    } catch (e) {

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      loader = false;
      notifyListeners();
    }
  }
}
