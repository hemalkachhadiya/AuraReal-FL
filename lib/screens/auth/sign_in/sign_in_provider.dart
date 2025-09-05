import 'package:aura_real/apis/app_response.dart';
import 'package:aura_real/apis/auth_apis.dart';
import 'package:aura_real/aura_real.dart';
import 'package:aura_real/screens/auth/sign_in/model/login_response_model.dart';
import 'package:aura_real/screens/dahsboard/dashboard_screen.dart';
import 'package:aura_real/services/api_services.dart';
import 'package:aura_real/utils/end_points.dart';

class SignInProvider extends ChangeNotifier {
  SignInProvider();

  bool loader = false;
  TextEditingController emailController = TextEditingController(
    text: "nehal.smarttechnica@gmail.com",
  );
  TextEditingController passwordController = TextEditingController(
    text: "Nehal@123",
  );

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
  // Simulated login API call
  // Future<void> onLoginTap(BuildContext context) async {
  //   if (!isFormValid) return;
  //
  //   loader = true;
  //   notifyListeners();
  //
  //   try {
  //     final response = await ApiService.postApi(
  //       url: EndPoints.login, // Replace with your login endpoint
  //       body: {
  //         "email": emailController.text,
  //         "password": passwordController.text,
  //       },
  //     );
  //
  //     if (response == null) {
  //       showCatchToast('No response from server', null);
  //       loader = false;
  //       notifyListeners();
  //       return;
  //     }
  //
  //     final model = appResponseFromJson<bool>(response.body);
  //     if (model.success == true) {
  //       showSuccessToast('Login Successful');
  //       if(context.mounted){
  //         context.navigator.pushReplacementNamed(
  //           DashboardScreen.routeName,
  //         ); // Replace with your home route
  //       }
  //
  //     } else {
  //       // Handle invalid login attempt
  //       if (model.message?.toLowerCase().contains(
  //             "invalid email or password",
  //           ) ==
  //           true) {
  //         showErrorMsg('Email not registered, please sign up');
  //         if (context.mounted) {
  //           context.navigator.pushNamed(
  //             SignUpScreen.routeName,
  //             arguments: {
  //               'email': emailController.text,
  //               "password": passwordController.text,
  //             },
  //           );
  //         }
  //       } else {
  //         showCatchToast(model.message ?? 'Login failed', null);
  //       }
  //     }
  //   } catch (exception, stack) {
  //     showCatchToast(exception, stack);
  //   } finally {
  //     loader = false;
  //     notifyListeners();
  //   }
  // }

  LoginRes? userData;

  Future<void> onLoginTap(BuildContext context) async {
    if (!isFormValid) return;
    if (isFormValid) {
      loader = true;
      notifyListeners();
      final result = await AuthApis.loginAPI(
        email: emailController.text,
        password: passwordController.text,
      );
      userData = result;
      if (userData != null) {
        print("LOGIN USER DATA  $userData");

        if (context.mounted) {
          context.navigator.pushNamedAndRemoveUntil(
            DashboardScreen.routeName,
            (route) => false,
          );
        }
      }
      loader = false;
      notifyListeners();
    }
  }
}
