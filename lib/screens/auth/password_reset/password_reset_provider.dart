import 'package:aura_real/aura_real.dart';
import 'package:aura_real/screens/auth/check_your_email/check_your_email_screen.dart';
// Updated Provider
class PasswordResetProvider extends ChangeNotifier {
  PasswordResetProvider();

  bool loader = false;
  String? selectedMethod;

  TextEditingController accountController = TextEditingController(
    text: "test0001",
  );
  TextEditingController passwordController = TextEditingController(
    text: "123456789",
  );
  String accountError = "";
  String pwdError = "";
  bool isPwdVisible = false;

  void onPwdVisibilityChanged() {
    isPwdVisible = !isPwdVisible;
    notifyListeners();
  }

  void selectResetMethod(String method) {
    selectedMethod = method;
    notifyListeners();
  }

  Future<void> onSendTap(BuildContext context) async {
    if (selectedMethod == null) return;

    loader = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(Duration(seconds: 2));


      showSuccessToast( selectedMethod == 'SMS'
          ? 'Reset code sent to your mobile number'
          : 'Reset link sent to your email',);

      // Navigate to verification screen or back
     context.navigator.pushNamed(CheckYourEmailScreen.routeName);

    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Something went wrong. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      loader = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    accountController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}