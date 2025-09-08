import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:aura_real/aura_real.dart';
import 'package:aura_real/common/methods.dart';
import 'package:aura_real/screens/auth/your_location/your_location_provider.dart';
import 'package:aura_real/screens/dahsboard/dashboard_screen.dart';
import 'package:aura_real/services/location_permission.dart';
import 'package:aura_real/services/location_services.dart';
import 'package:map_location_picker/map_location_picker.dart';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:aura_real/aura_real.dart';
import 'package:aura_real/common/methods.dart';
import 'package:aura_real/screens/auth/your_location/your_location_provider.dart';
import 'package:aura_real/screens/dahsboard/dashboard_screen.dart';
import 'package:aura_real/screens/auth/sign_in/sign_in_screen.dart';
import 'package:aura_real/services/location_services.dart';
import 'package:map_location_picker/map_location_picker.dart';

class YourLocationScreen extends StatefulWidget {
  final bool isComeFromSplash;

  const YourLocationScreen({super.key, this.isComeFromSplash = false});

  static const routeName = "your_location_screen";

  static Widget builder(BuildContext context, {bool isComeFromSplash = false}) {
    return ChangeNotifierProvider<YourLocationProvider>(
      create: (c) => YourLocationProvider(isComeFromSplash: isComeFromSplash),
      child: YourLocationScreen(isComeFromSplash: isComeFromSplash),
    );
  }

  @override
  State<YourLocationScreen> createState() => _YourLocationScreenState();
}

class _YourLocationScreenState extends State<YourLocationScreen> {
  @override
  void didChangeDependencies() {
    print("test==============1");

    super.didChangeDependencies();
    // Use the correct context that has access to the provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        print("Call Did change");

        Provider.of<YourLocationProvider>(
          context as BuildContext,
          listen: false,
        ).checkPermissionsAfterSettings(context as BuildContext);
      }
    });
  }

  @override
  void didChangeAppLifecycleState() {
    print("test==============2");
    // Use the correct context that has access to the provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        print("Call Did change");

        Provider.of<YourLocationProvider>(
          context as BuildContext,
          listen: false,
        ).checkPermissionsAfterSettings(context as BuildContext);
      }
    });
  }

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
            child: CustomSingleChildScroll(
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
                  if (provider.errorMessage != null) ...[
                    20.ph.spaceVertical,
                    Text(
                      provider.errorMessage!,
                      style: styleW400S14.copyWith(color: ColorRes.red),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  56.ph.spaceVertical,
                  SizedBox(
                    height: 220,
                    width: double.infinity,
                    child: Center(
                      child: AssetsImg(imagePath: AssetRes.locationImg),
                    ),
                  ),
                  123.ph.spaceVertical,
                  SubmitButton(
                    loading: provider.isLoading,
                    onTap: () async {
                      print("loc-----------------1");
                      provider.allowLocation();
                      print("loc-----------------2");

                      await Geolocator.openLocationSettings();
                      print("loc-----------------3");

                      if (context.mounted) {
                        await provider.checkPermissionsAfterSettings(context);
                      }
                    },
                    title:
                        context.l10n?.allowLocationAccess ??
                        "Allow Location Access",
                  ),
                  12.ph.spaceVertical,
                  TextButton(
                    onPressed: () async {
                      final location = await _showManualLocationDialog(context);
                      if (location != null &&
                          location.isNotEmpty &&
                          context.mounted) {
                        provider.setManualLocation(location);
                        await PrefService.set(PrefKeys.location, location);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "${context.l10n?.manualLocationSet ?? 'Manual location set'}: $location",
                              ),
                            ),
                          );
                          String token = PrefService.getString(PrefKeys.token);
                          if (token.trim().isNotEmpty && context.mounted) {
                            context.navigator.pushReplacementNamed(
                              DashboardScreen.routeName,
                            );
                          } else if (context.mounted) {
                            context.navigator.pushReplacementNamed(
                              SignInScreen.routeName,
                            );
                          }
                        }
                      }
                    },
                    child: Text(
                      context.l10n?.interLocationManually ??
                          "Enter Location Manually",
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                  20.ph.spaceVertical,
                ],
              ),
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
            title: Text(
              context.l10n?.interLocationManually ?? "Enter Location",
            ),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText:
                    context.l10n?.typeYourCityOrArea ??
                    "Type your city or area",
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, null),
                child: Text(context.l10n?.cancel ?? "Cancel"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, controller.text.trim()),
                child: Text(context.l10n?.save ?? "Save"),
              ),
            ],
          ),
    );
  }
}
