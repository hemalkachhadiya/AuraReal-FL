import 'package:aura_real/aura_real.dart';
import 'package:aura_real/screens/auth/create_new_password/create_new_password_screen.dart';

class CheckYourMailProvider extends ChangeNotifier {
  String otp = "";
  bool loader = false;

  void setOtp(BuildContext context, String value) {
    otp = value;
    if (otp.length == 4) {
      onSendTap(context);
    }
    notifyListeners();
  }

  Future<void> onSendTap(BuildContext context) async {
    if (otp.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid 4-digit code")),
      );
      return;
    }

    loader = true;
    notifyListeners();

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    loader = false;
    notifyListeners();

    // Navigate or show success
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("OTP Verified: $otp")));

    if (context.mounted) {
      context.navigator.pushNamed(CreateNewPasswordScreen.routeName);
    }
  }
}
