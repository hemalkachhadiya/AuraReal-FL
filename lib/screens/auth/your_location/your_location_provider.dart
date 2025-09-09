import 'package:aura_real/aura_real.dart';
import 'package:aura_real/screens/dahsboard/dashboard_screen.dart';
import 'package:aura_real/services/location_services.dart';
import 'package:aura_real/services/pref_services.dart';
import 'package:aura_real/utils/pref_keys.dart';
import 'package:geolocator/geolocator.dart';

class YourLocationProvider extends ChangeNotifier {
  final bool isComeFromSplash;
  bool _isLocationGranted = false;
  bool _isLocationSettingsOpened = false;
  String? _manualLocation;
  String? _errorMessage;
  bool _isLoading = false;

  YourLocationProvider({required this.isComeFromSplash}) {
    allowLocation(navigatorKey.currentState!.context);
  }

  bool get isLocationGranted => _isLocationGranted;

  String? get manualLocation => _manualLocation;

  String? get errorMessage => _errorMessage;

  bool get isLoading => _isLoading;

  Future<void> allowLocation(BuildContext context) async {
    _isLocationSettingsOpened = true;
    _isLocationGranted = false;
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    try {
      final (isEnabled, error) =
          await GetLocationService.checkLocationService();
      if (!isEnabled) {
        await Geolocator.openLocationSettings();
        final (newIsEnabled, _) =
            await GetLocationService.checkLocationService();
        if (!newIsEnabled) {
          _errorMessage = error ?? "Please enable location services.";
          _isLoading = false;
          notifyListeners();
          return;
        }
      }

      final (isPermitted, permError) =
          await GetLocationService.requestLocationPermission();
      if (isPermitted) {
        _isLocationGranted = true;
        _errorMessage = null;

        final position = await GetLocationService.getCurrentLocation(context);
        if (position != null && context.mounted) {
          await PrefService.set(PrefKeys.latitude, position.latitude);
          await PrefService.set(PrefKeys.longitude, position.longitude);
          final address = await GetLocationService.getAddressFromLatLng(
            context,
          );
          if (address != null && context.mounted) {
            await PrefService.set(PrefKeys.location, address);
            // Optional: Add a slight delay to ensure loader is visible
            await Future.delayed(Duration(milliseconds: 500));
            context.navigator.pushNamedAndRemoveUntil(
              DashboardScreen.routeName,
              (route) => false,
            );
          } else {
            _errorMessage = "Failed to fetch address.";
          }
        } else {
          _errorMessage = "Failed to fetch current location.";
        }
      } else {
        _errorMessage = permError ?? "Failed to grant location permission.";
        await Geolocator.openLocationSettings();
      }
    } catch (e) {
      _errorMessage = "Error processing location: $e";
    } finally {
      _isLoading = false;
      _isLocationSettingsOpened = false;
      notifyListeners();
    }
  }

  // Future<void> allowLocation(BuildContext context) async {
  //   _isLocationSettingsOpened = true;
  //   _isLocationGranted = false;
  //   _errorMessage = null;
  //   _isLoading = true;
  //   notifyListeners();
  //
  //   try {
  //     final (isEnabled, error) =
  //         await GetLocationService.checkLocationService();
  //     if (isEnabled) {
  //       final position = await GetLocationService.getCurrentLocation(context);
  //       final address = await GetLocationService.getAddressFromLatLng(context);
  //       print("Your Locaton Addres ====== ${address}");
  //     }
  //     if (!isEnabled) {
  //       await Geolocator.openLocationSettings();
  //       final (newIsEnabled, _) =
  //           await GetLocationService.checkLocationService();
  //       if (!newIsEnabled) {
  //         _errorMessage = error ?? "Please enable location services.";
  //         _isLoading = false;
  //         notifyListeners();
  //         return;
  //       }
  //     }
  //
  //     final (isPermitted, permError) =
  //         await GetLocationService.requestLocationPermission();
  //     if (isPermitted) {
  //       _isLocationGranted = true;
  //       _errorMessage = null;
  //
  //       final position = await GetLocationService.getCurrentLocation(context);
  //       if (position != null && context.mounted) {
  //         await PrefService.set(PrefKeys.latitude, position.latitude);
  //         await PrefService.set(PrefKeys.longitude, position.longitude);
  //         final address = await GetLocationService.getAddressFromLatLng(
  //           context,
  //         );
  //         if (address != null && context.mounted) {
  //           await PrefService.set(PrefKeys.location, address);
  //           context.navigator.pushNamedAndRemoveUntil(
  //             DashboardScreen.routeName,
  //             (route) => false,
  //           );
  //         } else {
  //           _errorMessage = "Failed to fetch address.";
  //         }
  //       } else {
  //         _errorMessage = "Failed to fetch current location.";
  //       }
  //     } else {
  //       _errorMessage = permError ?? "Failed to grant location permission.";
  //       await Geolocator.openLocationSettings();
  //     }
  //   } catch (e) {
  //     _errorMessage = "Error processing location: $e";
  //   } finally {
  //     _isLoading = false;
  //     _isLocationSettingsOpened = false;
  //     notifyListeners();
  //   }
  // }

  Future<void> checkPermissionsAfterSettings(BuildContext context) async {
    if (!_isLocationSettingsOpened) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final (isEnabled, error) =
          await GetLocationService.checkLocationService();
      if (!isEnabled) {
        _errorMessage = error ?? "Location services are still disabled.";
        _isLoading = false;
        notifyListeners();
        return;
      }

      final (isPermitted, permError) =
          await GetLocationService.requestLocationPermission();
      if (isPermitted) {
        _isLocationGranted = true;
        _errorMessage = null;

        final position = await GetLocationService.getCurrentLocation(context);
        if (position != null && context.mounted) {
          await PrefService.set(PrefKeys.latitude, position.latitude);
          await PrefService.set(PrefKeys.longitude, position.longitude);
          final address = await GetLocationService.getAddressFromLatLng(
            context,
          );
          if (address != null && context.mounted) {
            await PrefService.set(PrefKeys.location, address);
            // Optional: Add a slight delay to ensure loader is visible
            await Future.delayed(Duration(milliseconds: 500));
            context.navigator.pushNamedAndRemoveUntil(
              DashboardScreen.routeName,
              (route) => false,
            );
          } else {
            _errorMessage = "Failed to fetch address.";
          }
        } else {
          _errorMessage = "Failed to fetch current location.";
        }
      } else {
        _errorMessage = permError ?? "Location permission not granted.";
      }
    } catch (e) {
      _errorMessage = "${context.l10n?.error ?? 'Error'}: $e";
    } finally {
      _isLoading = false;
      _isLocationSettingsOpened = false;
      notifyListeners();
    }
  }

  void setManualLocation(String location) {
    _manualLocation = location;
    _isLocationGranted = false;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
