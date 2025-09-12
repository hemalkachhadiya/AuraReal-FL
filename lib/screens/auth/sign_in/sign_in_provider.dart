import 'package:aura_real/apis/app_response.dart';
import 'package:aura_real/apis/auth_apis.dart';
import 'package:aura_real/aura_real.dart';
import 'package:aura_real/screens/auth/check_your_email/check_your_email_screen.dart';
import 'package:aura_real/screens/auth/sign_in/model/google_login_response_model.dart';
import 'package:aura_real/screens/auth/sign_in/model/login_response_model.dart';
import 'package:aura_real/screens/dahsboard/dashboard_screen.dart';
import 'package:aura_real/services/api_services.dart';
import 'package:aura_real/utils/end_points.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignInProvider extends ChangeNotifier {
  SignInProvider({Map<String, dynamic>? args}) {
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
  bool loaderGoogleLogin = false;
  TextEditingController emailController = TextEditingController(text: "");
  TextEditingController passwordController = TextEditingController(text: "");

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

  void onEmailChanged(String value) {
    emailError = ""; // Clear email error on change
    validate(navigatorKey.currentState!.context);
  }

  void onPasswordChanged(String value) {
    pwdError = ""; // Clear password error on change
    validate(navigatorKey.currentState!.context);
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
    } else if (emailText.hasSpaces()) {
      emailError =
          context.l10n?.emailShouldNotContainSpace ??
          "Email should not contain spaces";
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


  /// Handle login tap and display password error for 402
  Future<void> onLoginTap(BuildContext context) async {
    if (!isFormValid) return;
    if (isFormValid) {
      loader = true;
      notifyListeners();

      final result = await AuthApis.loginAPI(
        email: emailController.text,
        password: passwordController.text,
      );

      if (result.loginRes != null) {
        if (context.mounted) {
          await PrefService.set(PrefKeys.email, emailController.text);

          final (isEnabled, error) =
              await GetLocationService.checkLocationService();
          await checkLocation();
          if (context.mounted && isEnabled) {
            final address = await GetLocationService.getAddressFromLatLng(
              context,
            );
            await PrefService.set(PrefKeys.location, address);

            if (context.mounted) {
              context.navigator.pushNamedAndRemoveUntil(
                DashboardScreen.routeName,
                (route) => false,
              );
            }
          } else {
            if (context.mounted) {
              context.navigator.pushReplacementNamed(
                YourLocationScreen.routeName,
                arguments: {'isComeFromSplash': true},
              );
            }
          }
        }
      } else {
        print("result=========== ${result.loginRes}");
        print("isInCorrectPassword========= ${result.isInCorrectPassword}");

        if (result.isInCorrectPassword) {
          pwdError =
              context.l10n?.incorrectPassword ??
              "Incorrect password"; // Set password error
          notifyListeners(); // Update UI to show error
        } else if (!result.isInCorrectPassword && context.mounted) {
          context.navigator.pushNamed(
            SignUpScreen.routeName,
            arguments: {
              "email": emailController.text,
              "password": passwordController.text,
            },
          );
        }
        // No navigation for 402; toast is already shown in loginAPI
      }

      loader = false;
      notifyListeners();
    }
  }

  Future<void> checkLocation() async {
    final (isEnabled, error) = await GetLocationService.checkLocationService();
    _isLocationEnabled = isEnabled;
    _error = error;
    if (!_isLocationEnabled && _error != null) {
      final (newEnabled, newError) =
          await GetLocationService.requestLocationPermission();
      _isLocationEnabled = newEnabled;
      _error = newError;
    }
    notifyListeners();
  }

  GoogleLoginRes? googleLoginUserData;

  bool _isLocationEnabled = false;
  String? _error;

  Future<void> googleSignIn(BuildContext context) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final GoogleSignIn googleSignIn1 = GoogleSignIn();
    if (await googleSignIn1.isSignedIn()) {
      await googleSignIn1.signOut();
    }
    await FirebaseAuth.instance.signOut();
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await auth.signInWithCredential(
        credential,
      );

      final User? firebaseUser = userCredential.user;
      loaderGoogleLogin = true;
      notifyListeners();

      googleLoginAPi(
        context,
        firebaseUser!.email.toString(),
        firebaseUser.uid.toString(),
      );
    } catch (e) {}
  }

  Future<void> googleLoginAPi(
    BuildContext context,
    String email,
    String googleId,
  ) async {
    final result = await AuthApis.googleAPI(email: email, googleId: googleId);
    googleLoginUserData = result;
    if (googleLoginUserData != null) {
      print("GOOGLE LOGIN USER DATA  $googleLoginUserData");

      if (context.mounted) {
        context.navigator.pushNamedAndRemoveUntil(
          DashboardScreen.routeName,
          (route) => false,
        );
      }
    }
    loaderGoogleLogin = false;
    notifyListeners();
  }

  Future<void> reqPasswordReset(BuildContext context, String email) async {
    loader = true;
    notifyListeners();
    final result = await AuthApis.reqPasswordResetAPI(email: email);
    if (result!) {
      if (context.mounted) {
        print("result------------- req------- ${result}");
        navigatorKey.currentState?.context.navigator.pop();
        context.navigator.pushNamed(
          CheckYourEmailScreen.routeName,
          // Replace with your OTP screen route
          arguments: {
            "email": email,
            "isComeFromSignUp": false,
            "isReset": true,
            "otp_type": "0",
          },
        );
      }
    }
    loader = false;
    notifyListeners();
  }
}
