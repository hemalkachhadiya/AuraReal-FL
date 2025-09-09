import 'package:aura_real/aura_real.dart';
import 'package:map_location_picker/map_location_picker.dart';

bool _splashInit = false;
bool _isLocationEnabled = false; // Variable to check location status

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  static const routeName = '/';

  static Widget builder(BuildContext context) {
    return SplashScreen();
  }

  // Future<void> checkLocationStatus() async {
  //   try {
  //     // Check if location services are enabled
  //     _isLocationEnabled = await Geolocator.isLocationServiceEnabled();
  //     print("Location services enabled: $_isLocationEnabled");
  //   } catch (e) {
  //     print("Error checking location status: $e");
  //     _isLocationEnabled = false;
  //   }
  // }

  Future<void> navigateScreen(BuildContext context) async {
    // final locationStatus = await GetLocationService.checkLocationStatus();
    // _isLocationEnabled = locationStatus == LocationStatus.enabled;
    // print("_isLocationEnabled============= ${_isLocationEnabled}");
    // final position = await GetLocationService.getCurrentLocation(context);
    // print("Location----------- ${position?.longitude} ${position?.latitude}");

    final address = await GetLocationService.getAddressFromLatLng(context);
    var latitude = await PrefService.getDouble(PrefKeys.latitude);

    print("latitude======= ${latitude}");

    print("address======= ${address}");

    try {
      if (_splashInit) return;
      _splashInit = true;

      await Future.delayed(1000.milliseconds);

      if (context.mounted) {
        final userData = PrefService.getString(PrefKeys.userData);

        if (kDebugMode) {
          print("token-------------- ${userData}");
        }
        // Navigate based on token
        if (userData.isNotEmpty) {
          final (isEnabled, error) =
              await GetLocationService.checkLocationService();
          if (isEnabled) {
            if (context.mounted && isEnabled) {
              final position = await GetLocationService.getCurrentLocation(
                context,
              );
              if (context.mounted) {
                final address = await GetLocationService.getAddressFromLatLng(
                  context,
                );
              }

              print("address------ ${address}");
              await PrefService.set(PrefKeys.location, address);
            }
            if (context.mounted) {
              var location = PrefService.getString(PrefKeys.location);

              print("Location---------- ${location}");
              context.navigator.pushNamedAndRemoveUntil(
                DashboardScreen.routeName,
                (route) => false,
              );
            }
          } else {
            context.navigator.pushReplacementNamed(
              YourLocationScreen.routeName,
              arguments: {'isComeFromSplash': true}, // Pass the flag
            );
          }
        } else {
          context.navigator.pushReplacementNamed(SignInScreen.routeName);
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    await Future.delayed(300.milliseconds);
    // FlutterNativeSplash.remove();
  }

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
