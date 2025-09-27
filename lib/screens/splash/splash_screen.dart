import 'package:aura_real/aura_real.dart';

bool _splashInit = false;

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  static const routeName = '/';

  static Widget builder(BuildContext context) {
    return SplashScreen();
  }

  Future<void> navigateScreen(BuildContext context) async {
    final address = await GetLocationService.getAddressFromLatLng(context);

    try {
      if (_splashInit) return;
      _splashInit = true;

      await Future.delayed(1000.milliseconds);

      if (context.mounted) {
        final userData = PrefService.getString(PrefKeys.userData);

        if (kDebugMode) {
          print("token-------------- ${userData}");
        }

        /// Navigate based on token
        if (userData.isNotEmpty) {
          final (isEnabled, error) =
              await GetLocationService.checkLocationService();
          if (isEnabled) {
            if (context.mounted && isEnabled) {
              await PrefService.set(PrefKeys.location, address);
            }
            if (context.mounted) {
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
