import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map_location_picker/map_location_picker.dart';
import 'package:aura_real/aura_real.dart'; // Assuming this provides PrefService and PrefKeys

enum LocationStatus {
  enabled,
  disabled,
  permissionDenied,
  permissionPermanentlyDenied,
  restricted,
  error,
}

class GetLocationService {
  static Future<String?> getAddressFromLatLngs(BuildContext context) async {
    final (lat, lon, error) = await getCurrentLatLon(context);
    if (lat == null || lon == null) return null;

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        return "${placemark.street}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}";
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error fetching address: $e")));
      }
    }
    return null;
  }

  static Future<(double?, double?, String?)> getCurrentLatLon(
    BuildContext context,
  ) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Location services are disabled"),
            action: SnackBarAction(
              label: "Enable",
              onPressed: () async {
                await Geolocator.openLocationSettings();
                await Future.delayed(const Duration(seconds: 2));
                await _retryLocationCheck(context);
              },
            ),
          ),
        );
      }
      return (null, null, "Location services are disabled");
    }

    // Check and request permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Location permissions are denied")),
          );
        }
        return (null, null, "Location permissions are denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              "Location permissions are permanently denied. Enable in settings.",
            ),
            action: SnackBarAction(
              label: "Settings",
              onPressed: () => Geolocator.openAppSettings(),
            ),
          ),
        );
      }
      return (null, null, "Location permissions are permanently denied");
    }

    // Get current position
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      print("Latitude: ${position.latitude}, Longitude: ${position.longitude}");
      return (
        position.latitude,
        position.longitude,
        null,
      ); // Success with lat, lon, and no error
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error fetching location: $e")));
      }
      return (null, null, "Error fetching location: $e");
    }
  }

  /// Checks if location services are enabled and returns the status with an error message if applicable.
  static Future<(bool, String?)> checkLocationService() async {
    try {
      final isEnabled = await Geolocator.isLocationServiceEnabled();
      print("Location service check: isEnabled = $isEnabled");
      if (!isEnabled) {
        return (
          false,
          "Location services are disabled. Please enable them in settings.",
        );
      }
      return (true, null);
    } catch (e) {
      print("Error checking location services: $e");
      return (false, "Error checking location services: $e");
    }
  }

  /// Requests location permission and re-checks location service.
  static Future<(bool, String?)> requestLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      print("Initial permission: $permission");
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        print("After request permission: $permission");
        if (permission == LocationPermission.denied) {
          return (false, "Location permissions are denied.");
        }
      }
      if (permission == LocationPermission.deniedForever) {
        return (
          false,
          "Location permissions are permanently denied. Please enable in settings.",
        );
      }
      final (isEnabled, error) = await checkLocationService();
      return (isEnabled, error);
    } catch (e) {
      print("Error requesting location permission: $e");
      return (false, "Error requesting location permission: $e");
    }
  }

  /// Fetches the current location if enabled and returns the address from latitude and longitude.
  /// Returns the address as a string, or null if location services are disabled or permission is denied.
  static Future<Map<String, String>> getAddressFromLatLng1({
    LatLng? location,
  }) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location!.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        return {
          "name": place.name ?? "",
          "streetNumber": place.subThoroughfare ?? "",
          "street": place.thoroughfare ?? "",
          "neighborhood": place.subLocality ?? "",
          "city": place.locality ?? "",
          "county": place.subAdministrativeArea ?? "",
          "state": place.administrativeArea ?? "",
          "postalCode": place.postalCode ?? "",
          "country": place.country ?? "",
        };
      } else {
        return {"error": "Address not found"};
      }
    } catch (e) {
      debugPrint("Error: $e");
      return {"error": "Error fetching address"};
    }
  }

  static Future<LocationStatus> checkLocationStatus() async {
    try {
      final isEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isEnabled) return LocationStatus.disabled;

      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied)
        return LocationStatus.permissionDenied;
      if (permission == LocationPermission.deniedForever)
        return LocationStatus.permissionPermanentlyDenied;
      return LocationStatus.enabled;
    } catch (e) {
      print("Error checking location status: $e");
      return LocationStatus.error;
    }
  }

  /// Checks location service and shows a snackbar if disabled.
  static Future<bool> isLocationServiceEnabled(BuildContext context) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Location services are disabled"),
          action: SnackBarAction(
            label: "Enable",
            onPressed: () async {
              await Geolocator.openLocationSettings();
              // Retry after a short delay
              await Future.delayed(const Duration(seconds: 2));
              await _retryLocationCheck(context);
            },
          ),
        ),
      );
    }
    return serviceEnabled;
  }

  /// Navigates to dashboard if location services and permissions are enabled.
  static Future<bool> navigateToDashboardIfLocationEnabled(
    BuildContext context,
  ) async {
    print("Starting location check for navigation...");
    bool serviceEnabled = await isLocationServiceEnabled(context);
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    print("Permission check: $permission");
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
              "Location permission permanently denied. Enable in settings.",
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
        print("Position fetched: $position");
        String? address = await getAddressFromLatLng(context);
        if (address != null && context.mounted) {
          await PrefService.set(PrefKeys.location, address);
          print("Address saved, navigating to Dashboard");
          if (context.mounted) {
            context.navigator.pushReplacementNamed(DashboardScreen.routeName);
            return true;
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Could not fetch address")),
            );
          }
        }
      } catch (e) {
        print("Error fetching location: $e");
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

  /// Fetches the current location and returns the position.
  static Future<Position?> getCurrentLocation(BuildContext context) async {
    print("Checking current location...");
    bool serviceEnabled = await isLocationServiceEnabled(context);
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    print("Initial permission: $permission");
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      print("After request permission: $permission");
      if (permission == LocationPermission.denied) {
        await _openSettingsIfNeeded(context);
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      await _openSettingsIfNeeded(context);
      return null;
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      try {
        Position position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );
        print("Current position: $position");
        await PrefService.set(PrefKeys.latitude, position.latitude);
        await PrefService.set(PrefKeys.longitude, position.longitude);
        return position;
      } catch (e) {
        print("Error getting current location: $e");
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error fetching location: $e")),
          );
        }
        return null;
      }
    }
    return null;
  }

  /// Fetches address from current location.
  static Future<String?> getAddressFromLatLng(BuildContext context) async {
    print("Fetching address from location...");
    Position? position = await getCurrentLocation(context);
    if (position == null) return null;

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        String address =
            "${placemark.street}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}";
        print("Place mark Location: $address");
        await PrefService.set(PrefKeys.location, address);
        return address;
      }
    } catch (e) {
      print("Error fetching address: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error fetching address: $e")));
      }
    }
    return null;
  }

  /// Helper function to open app settings with a prompt.
  static Future<void> _openSettingsIfNeeded(BuildContext context) async {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Location permission denied. Enable in settings.",
          ),
          action: SnackBarAction(
            label: "Settings",
            onPressed: () async {
              await Geolocator.openAppSettings();
              await Future.delayed(const Duration(seconds: 2));
              await _retryLocationCheck(context);
            },
          ),
        ),
      );
    }
  }

  /// Retry location check after settings change.
  static Future<void> _retryLocationCheck(BuildContext context) async {
    if (context.mounted) {
      final (isEnabled, error) = await checkLocationService();
      if (isEnabled) {
        await navigateToDashboardIfLocationEnabled(context); // Retry navigation
      } else if (error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
      }
    }
  }
}
