import 'package:aura_real/aura_real.dart';
import 'package:aura_real/common/methods.dart';
import 'package:aura_real/screens/auth/your_location/your_location_provider.dart';
import 'package:aura_real/screens/dahsboard/dashboard_screen.dart';
import 'package:aura_real/services/location_permission.dart';
import 'package:aura_real/services/location_services.dart';
import 'package:map_location_picker/map_location_picker.dart';

class YourLocationScreen extends StatelessWidget {
  final bool isComeFromSplash;

  const YourLocationScreen({super.key, this.isComeFromSplash = false});

  static const routeName = "your_location_screen";

  static Widget builder(BuildContext context, {bool isComeFromSplash = false}) {
    return ChangeNotifierProvider<YourLocationProvider>(
      create: (c) => YourLocationProvider(isComeFromSplash: isComeFromSplash),
      child: YourLocationScreen(isComeFromSplash: isComeFromSplash),
    );
  }

  // static const routeName = "your_location_screen";
  //
  // static Widget builder(BuildContext context) {
  //
  //   return ChangeNotifierProvider<YourLocationProvider>(
  //     create: (c) => YourLocationProvider(  ),
  //     child: const YourLocationScreen(),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Consumer<YourLocationProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Constants.horizontalPadding,
              vertical: 30,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                8.ph.spaceVertical,
                if (!provider.isComeFromSplash) AppBackIcon(),
                30.ph.spaceVertical,
                Text(
                  context.l10n?.whatIsYOurLocation ?? "",
                  style: styleW700S24,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n?.locationForRestaurantAndProduct ?? "",
                  style: styleW400S16.copyWith(color: ColorRes.grey6),
                  textAlign: TextAlign.center,
                ),
                56.ph.spaceVertical,

                // Illustration
                SizedBox(
                  height: 220,
                  width: double.infinity,

                  child: Center(
                    child: AssetsImg(imagePath: AssetRes.locationImg),
                  ),
                ),
                123.ph.spaceVertical,
                // Allow location button
                SubmitButton(
                  onTap: () async {
                    // requestLocationPermission(context);
                    provider.allowLocation();
                    Geolocator.openLocationSettings();
                    // final locationService = GetLocationService();
                    // final position = await locationService.getCurrentLocation(
                    //   context,
                    // );
                    // if (position != null && context.mounted) {
                    //   final address = await locationService
                    //       .getAddressFromLatLng(position);
                    //   provider.setManualLocation(address);
                    //   await PrefService.set(PrefKeys.location, address);
                    //   String token = PrefService.getString(PrefKeys.token);
                    //   String location = PrefService.getString(
                    //     PrefKeys.location,
                    //   );
                    //
                    //   print("Location======== ${location}");
                    //   // if (token.trim().isNotEmpty) {
                    //   //   if (context.mounted) {
                    //   //     context.navigator.pushReplacementNamed(
                    //   //       DashboardScreen.routeName,
                    //   //     );
                    //   //   }
                    //   // } else {
                    //   //   if (context.mounted) {
                    //   //     context.navigator.pushReplacementNamed(
                    //   //       SignInScreen.routeName,
                    //   //     );
                    //   //   }
                    //   // }
                    // } else if (context.mounted) {
                    //   await openAppSettings();
                    // }
                  },
                  title:
                      context.l10n?.allowLocationAccess ??
                      "Allow Location Access",
                ),

                // SubmitButton(
                //   onTap: () async {
                //     // provider.allowLocation();
                //     // await requestPermissions();
                //     // if (context.mounted) {
                //     //   await checkCameraPermission(context);
                //     // }
                //     // if (context.mounted) {
                //     //   context.navigator.pushReplacementNamed(
                //     //     DashboardScreen.routeName,
                //     //   );
                //     // }
                //   },
                //
                //   title: context.l10n?.allowLocationAccess ?? "",
                // ),
                12.ph.spaceVertical,

                // Enter manually
                TextButton(
                  onPressed: () async {
                    final location = await _showManualLocationDialog(context);
                    if (location != null && location.isNotEmpty) {
                      provider.setManualLocation(location);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Manual location: $location")),
                      );
                    }
                  },
                  child: Text(
                    context.l10n?.interLocationManually ?? "",
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
                20.ph.spaceVertical,
              ],
            ),
          ),
        );
      },
    );
  }

  Future<String?> _showManualLocationDialog(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Enter Location"),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: "Type your city or area",
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, null),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, controller.text.trim()),
                child: const Text("Save"),
              ),
            ],
          ),
    );
  }
}
