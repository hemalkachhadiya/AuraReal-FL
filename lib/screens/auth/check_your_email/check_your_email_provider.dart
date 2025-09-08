import 'package:aura_real/apis/auth_apis.dart';
import 'package:aura_real/aura_real.dart';
import 'package:aura_real/screens/auth/your_location/your_location_screen.dart';
import 'package:aura_real/screens/dahsboard/dashboard_screen.dart';
import 'package:aura_real/services/location_services.dart';
import 'package:geolocator/geolocator.dart';

class CheckYourMailProvider extends ChangeNotifier {
  CheckYourMailProvider({required this.email});

  String otp = "";
  String otpError = "";
  bool loader = false;

  final String email;

  void setOtp(BuildContext context, String value) {
    otp = value;

    if (otp.length == 6) {
      onVerifyOTPTap(context);
    }
    notifyListeners();
  }

  Future<void> onVerifyOTPTap(BuildContext context) async {
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid 6-digit code")),
      );
      return;
    }

    loader = true;
    notifyListeners();

    final result = await AuthApis.verifyOTPAPI(email: email, otp: otp);
    if (result != null) {
      // Use GetLocationService to check location permissions
      final locationService = GetLocationService();
      if (context.mounted) {
        final position = await GetLocationService.getCurrentLocation(context);
        if (position != null && context.mounted) {
          // Permission granted, get address and navigate to Dashboard
          final address = await GetLocationService.getAddressFromLatLng(context);
          // Optionally store address in provider or shared preferences
          await PrefService.set(PrefKeys.location, address);
          if (context.mounted) {
            context.navigator.pushReplacementNamed(DashboardScreen.routeName);
          }
        } else if (context.mounted) {
          // Permission not granted or services disabled, navigate to LocationServiceScreen
          context.navigator.pushReplacementNamed(
            YourLocationScreen.routeName,
            arguments: {'isComeFromSplash': false}, // Pass the flag
          );
        }
      }
    } else {
      otpError = "Invalid OTP";
    }

    loader = false;
    notifyListeners();
  }
}
