import 'package:aura_real/apis/auth_apis.dart';
import 'package:aura_real/aura_real.dart';
import 'package:aura_real/screens/auth/create_new_password/create_new_password_screen.dart';
import 'package:map_location_picker/map_location_picker.dart';

class CheckYourMailProvider extends ChangeNotifier {
  CheckYourMailProvider({
    required this.email,
    this.phoneNumber,
    required this.isComeFromSignUp,
    this.isReset = false,
    this.otpType = "1",
  });

  String otp = "";
  String otpError = "";
  bool loader = false;

  final String email;
  final String? phoneNumber;
  final bool? isComeFromSignUp;
  final bool? isReset;
  final String? otpType;

  // Check if the provider is disposed
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void setOtp(BuildContext context, String value) {
    if (_disposed) return; // Prevent updates if disposed
    otp = value;

    if (otpType == "1" ? otp.length == 4 : otp.length == 6) {
      onVerifyOTPTap(context);
    }
    if (!_disposed) notifyListeners();
  }

  LocationPermission? permission;

  Future<void> onVerifyOTPTap(BuildContext context) async {
    print("type======== ${otpType}");

    // return;
    if (_disposed) return; // Prevent execution if disposed

    if (otpType == "1" ? otp.length != 4 : otp.length != 6) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Please enter a valid ${otpType == "1" ? "4" : "6"}-digit code",
            ),
          ),
        );
      }
      return;
    }

    loader = true;
    if (!_disposed) notifyListeners();

    try {
      Object? result;
      if (isReset == true) {
        print("For Reset=========");
        result = await AuthApis.otpVerifyForgotPasswordAPI(
          email: email,
          otp: otp,
        );
        if (result != null && context.mounted) {
          context.navigator.pushReplacementNamed(
            CreateNewPasswordScreen.routeName,
            arguments: {"email": email, "otp": otp},
          );
          return; // Exit early to avoid further state updates
        }
      } else {
        print("For Verify =============");
        print("type======== $otpType");
        result = await AuthApis.verifyOTPAPI(
          email: email,
          otp: otp,
          otpType: otpType ?? "0",
          phone: phoneNumber ?? "",
        );
      }
      final (isPermitted, permError) =
          await GetLocationService.requestLocationPermission();
      if (result != null && context.mounted) {
        if (isPermitted) {
          if (context.mounted) {
            context.navigator.pushNamedAndRemoveUntil(
              DashboardScreen.routeName,
              (route) => false,
            );

            // GetLocationService.navigateToDashboardIfLocationEnabled(context);
          }
        } else {
          if (context.mounted) {
            context.navigator.pushReplacementNamed(
              YourLocationScreen.routeName,
              arguments: {
                'isComeFromSplash': false,
                'error': 'Could not fetch location',
              },
            );
          }
        }

        // if (context.mounted) {
        //   print("isEnabled=============== $isEnabled");
        //   if (isEnabled) {
        //     final position = await GetLocationService.getCurrentLocation(context);
        //     print("Current position: $position");
        //     if (position != null && context.mounted) {
        //       final address = await GetLocationService.getAddressFromLatLng(context);
        //       print("Address: $address");
        //       if (address != null && context.mounted) {
        //         await PrefService.set(PrefKeys.location, address);
        //         print("Navigating to DashboardScreen");
        //         context.navigator.pushReplacementNamed(DashboardScreen.routeName);
        //       }
        //     } else {
        //       print("Position is null, navigating to YourLocationScreen");
        //       context.navigator.pushReplacementNamed(
        //         YourLocationScreen.routeName,
        //         arguments: {'isComeFromSplash': false, 'error': 'Could not fetch location'},
        //       );
        //     }
        //   }
        // }
      } else {
        otpError = "Invalid OTP";
        if (!_disposed) notifyListeners();
      }
      notifyListeners();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${context.l10n?.error ?? 'Error'}: $e")),
        );
      }
      otpError = "${context.l10n?.error ?? 'Error'}: $e";
      if (!_disposed) notifyListeners();
    } finally {
      loader = false;
      if (!_disposed) notifyListeners(); // Only notify if not disposed
    }
  }
}

// import 'package:aura_real/apis/auth_apis.dart';
// import 'package:aura_real/aura_real.dart';
// import 'package:aura_real/screens/auth/create_new_password/create_new_password_screen.dart';
// import 'package:aura_real/screens/auth/your_location/your_location_screen.dart';
// import 'package:aura_real/screens/dahsboard/dashboard_screen.dart';
// import 'package:aura_real/services/location_services.dart';
// import 'package:geolocator/geolocator.dart';
//
// class CheckYourMailProvider extends ChangeNotifier {
//   CheckYourMailProvider({
//     required this.email,
//     required this.isComeFromSignUp,
//     this.isReset = false,
//   });
//
//   String otp = "";
//   String otpError = "";
//   bool loader = false;
//
//   final String email;
//   final bool? isComeFromSignUp;
//   final bool? isReset;
//
//   void setOtp(BuildContext context, String value) {
//     otp = value;
//
//     if (otp.length == 6) {
//       onVerifyOTPTap(context);
//     }
//     notifyListeners();
//   }
//
//   Future<void> onVerifyOTPTap(BuildContext context) async {
//     if (otp.length != 6) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please enter a valid 6-digit code")),
//       );
//       return;
//     }
//
//     loader = true;
//     notifyListeners();
//     final Object? result;
//     if (isReset!) {
//       print("For Reset========= ");
//       result = await AuthApis.otpVerifyForgotPasswordAPI(
//         email: email,
//         otp: otp,
//       );
//       if (context.mounted) {
//         context.navigator.pushReplacementNamed(
//           CreateNewPasswordScreen.routeName,
//           arguments: {
//             "email": email
//           }
//         );
//       }
//     } else {
//       print("For Verify ============== ");
//
//       result = await AuthApis.verifyOTPAPI(email: email, otp: otp);
//     }
//
//     if (result != null) {
//       if (context.mounted) {
//         final (isEnabled, error) =
//             await GetLocationService.checkLocationService();
//         print("isEnabled=============== ${isEnabled}");
//         if (isEnabled) {
//           await GetLocationService.getCurrentLocation(context);
//           if (context.mounted && isEnabled) {
//             final address = await GetLocationService.getAddressFromLatLng(
//               context,
//             );
//             await PrefService.set(PrefKeys.location, address);
//           }
//           if (context.mounted) {
//             context.navigator.pushReplacementNamed(DashboardScreen.routeName);
//           }
//         } else {
//           context.navigator.pushReplacementNamed(
//             YourLocationScreen.routeName,
//             arguments: {'isComeFromSplash': false}, // Pass the flag
//           );
//         }
//       }
//     } else {
//       otpError = "Invalid OTP";
//     }
//
//     loader = false;
//     notifyListeners();
//   }
// }
