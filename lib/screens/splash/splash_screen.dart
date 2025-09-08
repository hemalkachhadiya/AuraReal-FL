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


    print("address======= ${address}");
    try {
      if (_splashInit) return;
      _splashInit = true;

      await Future.delayed(1000.milliseconds);

      if (context.mounted) {
        String token = PrefService.getString(PrefKeys.token);

        // Navigate based on token
        if (token.trim().isNotEmpty) {
          if (address != null) {
            context.navigator.pushReplacementNamed(DashboardScreen.routeName);
          } else {
            print("hi====================");
            context.navigator.pushReplacementNamed(
              YourLocationScreen.routeName,
              arguments: {'isComeFromSplash': true},
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
