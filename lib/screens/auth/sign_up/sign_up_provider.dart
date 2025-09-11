import 'package:aura_real/apis/auth_apis.dart';
import 'package:aura_real/aura_real.dart';
import 'package:aura_real/screens/auth/check_your_email/check_your_email_screen.dart';
import 'package:aura_real/screens/auth/password_reset/password_reset_screen.dart';
import 'package:map_location_picker/map_location_picker.dart';

class SignUpProvider extends ChangeNotifier {
  SignUpProvider({Map<String, dynamic>? args}) {
    // Prefill email and password if provided in args
    if (args != null) {
      final prefilledEmail = args['email'] as String? ?? '';
      final prefilledPassword = args['password'] as String? ?? '';
      if (prefilledEmail.isNotEmpty) {
        emailController.text = prefilledEmail;
        onEmailChanged(prefilledEmail); // Validate without context if null
      }
      if (prefilledPassword.isNotEmpty) {
        passwordController.text = prefilledPassword;
        onPasswordChanged(
          prefilledPassword,
        ); // Validate without context if null
      }
    }
  }

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
    final password = passwordController.text.trim();

    // Full name validation
    if (fullName.isEmpty) {
      fullNameError =
          navigatorKey.currentState?.context.l10n?.fullNameIsRequired ??
          "Full name is required";
    } else if (!fullName.isFullNameValid()) {
      fullNameError =
      fullName.isEmpty
          ? (navigatorKey.currentState?.context.l10n?.fullNameIsRequired ?? "Full name is required")
          : (navigatorKey.currentState?.context.l10n?.fullNameMinLength ?? "Full name must be at least 3 characters long");
    }else if (fullName.hasSpecialCharacters()) {
      fullNameError = navigatorKey.currentState?.context.l10n?.fullNameNoSpecialChars ??
          "Full name should not contain special characters";
    }else {
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

    // Password validation
    if (password.isEmpty) {
      pwdError =
          navigatorKey.currentState?.context.l10n?.passwordIsRequired ??
          "Password is required";
    } else if (password.length < 8) {
      pwdError =
          navigatorKey.currentState?.context.l10n?.passwordMinLength ??
          "Password must be at least 8 characters";
    } else if (!password.isValidPassword()) {
      pwdError =
          navigatorKey.currentState?.context.l10n?.passwordInvalid ??
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

  // Future<void> _fetchLocation() async {
  //   final (lat, lon, error) = await GetLocationService.getCurrentLatLon(context);
  //   setState(() {
  //     latitude = lat;
  //     longitude = lon;
  //     errorMessage = error;
  //   });
  // }
  Future<void> onSignUpTap(BuildContext context) async {
    if (validate()) {
      context.navigator.pushNamed(
        PasswordRestScreen.routeName,
        arguments: {
          "isComeFromSignUp": true,
          "email": emailController.text.trim(),
          "fullName": fullNameController.text.trim(),
          "phoneNumber": mobileController.text.trim(),
          "password": passwordController.text.trim(),
        },
      );
    }
  }

  // /// Submit signup
  // Future<void> signUpAPI(
  //   BuildContext context, {
  //   String? selectedOTPType,
  // }) async {
  //   print('on sgn up');
  //
  //   print('onSignUpTap =============');
  //   loader = true;
  //   notifyListeners();
  //   final result = await AuthApis.registerAPI(
  //     email: emailController.text,
  //     fullName: fullNameController.text,
  //     password: passwordController.text,
  //     phoneNumber: mobileController.text,
  //     otpType: selectedOTPType ?? "0",
  //   );
  //   if (result) {
  //     if (context.mounted) {
  //       context.navigator.pushNamed(
  //         CheckYourEmailScreen.routeName,
  //         arguments: {'email': emailController.text},
  //       );
  //     }
  //   }
  //   loader = false;
  //   notifyListeners();
  // }

  // @override
  // void dispose() {
  //   fullNameController.dispose();
  //   emailController.dispose();
  //   mobileController.dispose();
  //   passwordController.dispose();
  //   super.dispose();
  // }
}
