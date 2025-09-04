import 'package:aura_real/aura_real.dart';

class SignUpProvider extends ChangeNotifier {
  SignUpProvider();

  bool loader = false;

  /// Controllers
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  /// Error messages
  String fullNameError = "";
  String emailError = "";
  String mobileError = "";
  String pwdError = "";

  /// Password visibility
  bool isPwdVisible = false;

  /// Checkbox state
  bool isChecked = false;

  void onPwdVisibilityChanged() {
    isPwdVisible = !isPwdVisible;
    notifyListeners();
  }

  void toggleCheck() {
    isChecked = !isChecked;
    notifyListeners();
  }

  bool get isFormValid {
    return fullNameError.isEmpty &&
        emailError.isEmpty &&
        mobileError.isEmpty &&
        pwdError.isEmpty &&
        fullNameController.text.trim().isNotEmpty &&
        emailController.text.trim().isNotEmpty &&
        mobileController.text.trim().isNotEmpty &&
        passwordController.text.trim().isNotEmpty &&
        isChecked; // ✅ Must check terms
  }

  void onFullNameChanged(String value, BuildContext context) {
    validate(context);
  }

  void onEmailChanged(String value, BuildContext context) {
    validate(context);
  }

  void onMobileChanged(String value, BuildContext context) {
    validate(context);
  }

  void onPasswordChanged(String value, BuildContext context) {
    validate(context);
  }

  /// Validate inputs
  bool validate(BuildContext context) {
    final fullName = fullNameController.text.trim();
    final email = emailController.text.trim();
    final mobile = mobileController.text.trim();
    final password = passwordController.text.trim();

    // Full name validation
    if (fullName.isEmpty) {
      fullNameError = context.l10n?.fullNameIsRequired ?? "Full name is required";
    } else {
      fullNameError = "";
    }

    // Email validation
    if (email.isEmpty) {
      emailError = context.l10n?.emailIsRequired ?? "Email is required";
    } else if (!email.isEmailValid()) {
      emailError = context.l10n?.invalidEmail ?? "Enter a valid email address";
    } else {
      emailError = "";
    }

    // Mobile validation
    if (mobile.isEmpty) {
      mobileError = context.l10n?.mobileIsRequired ?? "Mobile number is required";
    } else if (!mobile.isPhoneValid()) {
      mobileError = context.l10n?.invalidMobile ?? "Enter a valid mobile number";
    } else {
      mobileError = "";
    }

    // Password validation
    if (password.isEmpty) {
      pwdError = context.l10n?.passwordIsRequired ?? "Password is required";
    } else if (password.length < 8) {
      pwdError = context.l10n?.passwordMinLength ?? "Password must be at least 8 characters";
    } else if (!password.isValidPassword()) {
      pwdError = context.l10n?.passwordInvalid ??
          "Password must contain uppercase, lowercase, number & special character";
    } else {
      pwdError = "";
    }

    notifyListeners();
    return fullNameError.isEmpty &&
        emailError.isEmpty &&
        mobileError.isEmpty &&
        pwdError.isEmpty &&
        isChecked; // ✅ must agree to terms
  }

  /// Submit signup
  Future<void> onSignUpTap(BuildContext context) async {
    if (!validate(context)) return;

    loader = true;
    notifyListeners();

    try {
      // TODO: Call API here
      await Future.delayed(const Duration(seconds: 2));

      loader = false;
      notifyListeners();

      context.navigator.pushReplacementNamed(SignInScreen.routeName);
    } catch (e) {
      loader = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
