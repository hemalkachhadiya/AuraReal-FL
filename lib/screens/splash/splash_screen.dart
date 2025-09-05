import 'package:aura_real/aura_real.dart';
import 'package:aura_real/screens/auth/your_location/your_location_screen.dart';
import 'package:aura_real/screens/dahsboard/dashboard_screen.dart';
import 'package:aura_real/services/location_services.dart';

bool _splashInit = false;

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  static const routeName = '/';

  static Widget builder(BuildContext context) {
    return SplashScreen();
  }

  Future<void> navigateScreen(BuildContext context) async {
    try {
      if (_splashInit) return;
      _splashInit = true;

      await Future.delayed(1000.milliseconds);

      // Check location services and permissions
      final locationService = GetLocationService();

      final position = await locationService.getCurrentLocation(context);

      String token = PrefService.getString(PrefKeys.token);
      String userData = PrefService.getString(PrefKeys.userData);
      print("token -- $token");
      print("userData -- $userData");

      if (context.mounted) {
        if (position != null) {
          // Location services enabled and permissions granted
          final address = await locationService.getAddressFromLatLng(position);
          await PrefService.set(PrefKeys.location, address);

          // Navigate based on token
          if (token.trim().isNotEmpty) {
            if (context.mounted) {
              context.navigator.pushReplacementNamed(DashboardScreen.routeName);
            }
          } else {
            if (context.mounted) {
              context.navigator.pushReplacementNamed(SignInScreen.routeName);
            }
          }
        } else {
          context.navigator.pushReplacementNamed(
            YourLocationScreen.routeName,
            arguments: {'isComeFromSplash': true}, // Pass the flag
          );
        }
      }
    } catch (e) {
      debugPrint(e.toString());
      if (context.mounted) {
        context.navigator.pushReplacementNamed(
          YourLocationScreen.routeName,
          arguments: {'isComeFromSplash': true}, // Pass the flag
        );
      }
    }
    await Future.delayed(300.milliseconds);
    // FlutterNativeSplash.remove();
  }

  // Future<void> navigateScreen(BuildContext context) async {
  //   try {
  //     if (_splashInit) return;
  //     _splashInit = true;
  //     await Future.delayed(1000.milliseconds);
  //     // Check location services and permissions
  //     final locationService = GetLocationService();
  //     final position = await locationService.getCurrentLocation(context);
  //     String token = PrefService.getString(PrefKeys.token);
  //     String userData = PrefService.getString(PrefKeys.userData);
  //     print("token -- ${token}");
  //
  //     print("userData -- ${userData}");
  //
  //
  //     if (context.mounted) {
  //       if (token.trim().isNotEmpty) {
  //         context.navigator.pushReplacementNamed(DashboardScreen.routeName);
  //       } else {
  //         context.navigator.pushReplacementNamed(SignInScreen.routeName);
  //         // context.navigator.pushReplacementNamed(DashboardScreen.routeName);
  //       }
  //     }
  //   } catch (e) {
  //     debugPrint(e.toString());
  //   }
  //   await Future.delayed(300.milliseconds);
  //   // FlutterNativeSplash.remove();
  // }

  @override
  Widget build(BuildContext context) {
    navigateScreen(context);
    return Scaffold(
      backgroundColor: ColorRes.primaryColor,
      body: SafeArea(
        child: Center(
          child: SvgAsset(
            imagePath: AssetRes.splashLogo,
            width: 214.pw,
            height: 69.ph,
          ),
        ),
      ),
    );
  }
}
