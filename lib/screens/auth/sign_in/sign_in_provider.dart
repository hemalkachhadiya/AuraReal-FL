import 'package:aura_real/aura_real.dart';
import 'package:aura_real/screens/dahsboard/dashboard_screen.dart';

class SignInProvider extends ChangeNotifier {
  SignInProvider();

  bool loader = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  String emailError = "";
  String pwdError = "";
  bool isPwdVisible = false;

  void onPwdVisibilityChanged() {
    isPwdVisible = !isPwdVisible;
    notifyListeners();
  }

  bool get isFormValid {
    return emailError.isEmpty &&
        pwdError.isEmpty &&
        emailController.text.trim().isNotEmpty &&
        passwordController.text.trim().isNotEmpty;
  }

  void onEmailChanged(String value, BuildContext context) {
    validate(context);
  }

  void onPasswordChanged(String value, BuildContext context) {
    validate(context);
  }

  /// Validate inputs
  bool validate(BuildContext context) {
    final emailText = emailController.text.trim();
    final pwdText = passwordController.text.trim();

    // ✅ Email validation
    if (emailText.isEmpty) {
      emailError = context.l10n?.emailAddress ?? "Email is required";
    } else if (!emailText.isEmailValid()) {
      emailError = context.l10n?.invalidEmail ?? "Enter a valid email address";
    } else {
      emailError = "";
    }

    // ✅ Password validation
    if (pwdText.isEmpty) {
      pwdError = context.l10n?.passwordIsRequired ?? "Password is required";
    } else if (!pwdText.hasMinLength(8)) {
      pwdError =
          context.l10n?.passwordMinLength ??
          "Password must be at least 8 characters";
    } else if (!pwdText.isValidPassword()) {
      pwdError =
          context.l10n?.passwordInvalid ??
          "Password must contain uppercase, lowercase, number & special character";
    } else {
      pwdError = "";
    }

    notifyListeners();
    return emailError.isEmpty && pwdError.isEmpty;
  }

  /// Login Function
  Future<void> onLoginTap(BuildContext context) async {
    if (!validate(context)) return;

    try {
      loader = true;
      notifyListeners();

      // Fake API delay
      await Future.delayed(const Duration(seconds: 2));

      if (context.mounted) {
        context.navigator.pushReplacementNamed(DashboardScreen.routeName);
      }
      // // TODO: replace with real API call
      // if (emailController.text == "test0001" &&
      //     passwordController.text == "123456789") {
      //   // Success → navigate to home
      //   context.navigator.pushReplacementNamed("/home");
      // } else {
      //   // Invalid credentials
      //   ScaffoldMessenger.of(
      //     context,
      //   ).showSnackBar(const SnackBar(content: Text("Invalid credentials")));
      // }
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
