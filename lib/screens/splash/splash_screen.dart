import 'package:aura_real/aura_real.dart';
import 'package:aura_real/screens/dahsboard/dashboard_screen.dart';

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
      String token = PrefService.getString(PrefKeys.sessionToken);
      if (context.mounted) {
        if (token.trim().isNotEmpty) {
          context.navigator.pushReplacementNamed(DashboardScreen.routeName);
        } else {
          // context.navigator.pushReplacementNamed(SignInScreen.routeName);

          context.navigator.pushReplacementNamed(DashboardScreen.routeName);
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
