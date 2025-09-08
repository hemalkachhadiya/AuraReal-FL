import 'package:aura_real/apis/app_response.dart';
import 'package:aura_real/apis/auth_apis.dart';
import 'package:aura_real/aura_real.dart';
import 'package:aura_real/screens/auth/sign_in/model/google_login_response_model.dart';
import 'package:aura_real/screens/auth/sign_in/model/login_response_model.dart';
import 'package:aura_real/screens/dahsboard/dashboard_screen.dart';
import 'package:aura_real/services/api_services.dart';
import 'package:aura_real/utils/end_points.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignInProvider extends ChangeNotifier {
  SignInProvider();

  bool loader = false;
  bool loaderGoogleLogin = false;
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

  LoginRes? userData;

  GoogleLoginRes? googleLoginUserData;

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
}
