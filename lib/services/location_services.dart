import 'package:aura_real/aura_real.dart';
import 'package:geolocator/geolocator.dart';

enum LocationStatus {
  enabled,
  disabled,
  permissionDenied,
  permissionPermanentlyDenied,
  restricted,
  error
}

class GetLocationService {
  static Future<LocationStatus> checkLocationStatus() async {
    try {
      // Check if location services are enabled
      final isEnabled = await Geolocator.isLocationServiceEnabled();

      if (!isEnabled) {
        return LocationStatus.disabled;
      }

      // Check location permission
      final permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        return LocationStatus.permissionDenied;
      } else if (permission == LocationPermission.deniedForever) {
        return LocationStatus.permissionPermanentlyDenied;
      }   else {
        return LocationStatus.enabled;
      }
    } catch (e) {
      return LocationStatus.error;
    }
  }

  /// Checks if location services are enabled.
  /// Returns true if enabled, false if disabled, and shows a snackbar if disabled.
  static Future<bool> isLocationServiceEnabled(BuildContext context) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location services are disabled")),
      );
    }
    return serviceEnabled;
  }

  /// Navigates to dashboard if location services and permissions are enabled.
  /// Returns true if navigation occurs, false otherwise.
  static Future<bool> navigateToDashboardIfLocationEnabled(
    BuildContext context,
  ) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    print("serviceEnabled--------------- ${serviceEnabled}");
    LocationPermission permission = await Geolocator.checkPermission();

    if (!serviceEnabled) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location services are disabled")),
        );
      }
      return false;
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Location permission denied")),
          );
        }
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              "Location permission permanently denied. Please enable it in settings.",
            ),
            action: SnackBarAction(
              label: "Settings",
              onPressed: () => Geolocator.openAppSettings(),
            ),
          ),
        );
      }
      return false;
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      try {
        Position position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );
        String? address = await getAddressFromLatLng(
          context,
        ); // Reuse existing function
        if (address != null && context.mounted) {
          await PrefService.set(PrefKeys.location, address);
          if (context.mounted) {
            context.navigator.pushReplacementNamed(DashboardScreen.routeName);
            return true;
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error fetching location: $e")),
          );
        }
        return false;
      }
    }
    return false;
  }

  /// Fetches the current location if enabled and returns the address from latitude and longitude.
  /// Returns the address as a string, or null if location services are disabled or permission is denied.
  static Future<String?> getAddressFromLatLng(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location services are disabled")),
        );
      }
      return null;
    }

    // Check permission status
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Location permission denied")),
          );
        }
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              "Location permission permanently denied. Please enable it in settings.",
            ),
            action: SnackBarAction(
              label: "Settings",
              onPressed: () => Geolocator.openAppSettings(),
            ),
          ),
        );
      }
      return null;
    }

    // Get current position if permission is granted
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      try {
        Position position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );
        // Get address from coordinates using geocoding package
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          Placemark placemark = placemarks.first;
          print(
            "Place mark Location ${"${placemark.street}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}"}",
          );
          return "${placemark.street}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}";
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error fetching address: $e")));
        }
        return null;
      }
    }
    return null;
  }

  /// Fetches the current location if enabled and returns the position.
  /// Returns the position if successful, null otherwise.
  static Future<Position?> getCurrentLocation(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      // Recheck after opening settings (optional delay can be added if needed)
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Location services must be enabled to proceed"),
            ),
          );
        }
        return null;
      }
    }

    // Check permission status
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        await _openSettingsIfNeeded(context);
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      await _openSettingsIfNeeded(context);
      return null;
    }

    // If permission is granted, get current position
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      return position;
    }

    return null;
  }

  // Helper function to open app settings with a snackbar prompt
  static Future<void> _openSettingsIfNeeded(BuildContext context) async {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Location permission denied. Please enable it in settings.",
          ),
          action: SnackBarAction(
            label: "Settings",
            onPressed: () async {
              await Geolocator.openAppSettings();
            },
          ),
        ),
      );
    }
  }
}
