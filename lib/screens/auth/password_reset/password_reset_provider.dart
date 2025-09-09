import 'package:aura_real/apis/auth_apis.dart';
import 'package:aura_real/aura_real.dart';
import 'package:aura_real/screens/auth/check_your_email/check_your_email_screen.dart';

// Updated Provider
class PasswordResetProvider extends ChangeNotifier {
  final bool isComeFromSignUp;
  final String? email;
  final String? fullName;
  final String? phoneNumber;
  final String? password;

  PasswordResetProvider(
    this.email,
    this.fullName,
    this.phoneNumber,
    this.password, {
    required this.isComeFromSignUp,
  });

  bool loader = false;
  String? selectedMethod;

  void selectResetMethod(String method) {
    selectedMethod = method;
    notifyListeners();
  }

  /// Submit signup
  Future<void> signUpAPI(BuildContext context) async {
    print('on sgn up');

    print(
      'onSignUpTap =============${email} ${password} ${phoneNumber} ${fullName}',
    );
    loader = true;
    notifyListeners();
    final result = await AuthApis.registerAPI(
      email: email ?? "",
      fullName: fullName ?? "",
      password: password ?? "",
      phoneNumber: phoneNumber ?? "",
      otpType:  selectedMethod == 'SMS'?"1":"0"
    );
    if (result) {
      if (context.mounted) {
        context.navigator.pushNamed(
          CheckYourEmailScreen.routeName,
          arguments: {'email': email},
        );
      }
    }
    loader = false;
    notifyListeners();
  }

  Future<void> onSendTap(BuildContext context) async {
    if (selectedMethod == null) return;

    loader = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(Duration(seconds: 2));

      showSuccessToast(
        selectedMethod == 'SMS'
            ? 'Reset code sent to your mobile number'
            : 'Reset link sent to your email',
      );

      // Navigate to verification screen or back
      if (context.mounted) {
        context.navigator.pushNamed(CheckYourEmailScreen.routeName);
      }
    } catch (e) {
      // Handle error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Something went wrong. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      loader = false;
      notifyListeners();
    }
  }
}
