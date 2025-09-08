import 'package:aura_real/aura_real.dart';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:aura_real/aura_real.dart';
import 'package:aura_real/services/location_services.dart';
import 'package:aura_real/screens/dahsboard/dashboard_screen.dart';
import 'package:aura_real/services/pref_services.dart';
import 'package:aura_real/utils/pref_keys.dart';

class YourLocationProvider extends ChangeNotifier {
  final bool isComeFromSplash;
  bool _isLocationGranted = false;
  bool _isLocationSettingsOpened = false;
  String? _manualLocation;
  String? _errorMessage;
  bool _isLoading = false;

  YourLocationProvider({required this.isComeFromSplash});

  // Getters
  bool get isLocationGranted => _isLocationGranted;

  String? get manualLocation => _manualLocation;

  String? get errorMessage => _errorMessage;

  bool get isLoading => _isLoading;

  /// Call when user initiates location permission request
  void allowLocation() {
    _isLocationSettingsOpened = true;
    _isLocationGranted = false;
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();
  }

  /// Call when user enters location manually
  void setManualLocation(String location) {
    _manualLocation = location;
    _isLocationGranted = false;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Checks permissions and services after returning from settings
  Future<void> checkPermissionsAfterSettings(BuildContext context) async {
    if (!_isLocationSettingsOpened) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      bool navigated =
          await GetLocationService.navigateToDashboardIfLocationEnabled(
            context,
          );
      notifyListeners();
      if (!navigated && context.mounted) {
        _errorMessage =
            context.l10n?.somethingWentWrong ??
            "Something went wrong. Please try again.";
        notifyListeners();
      }
    } catch (e) {
      if (context.mounted) {
        _errorMessage = "${context.l10n?.error ?? 'Error'}: $e";
        notifyListeners();
      }
    } finally {
      _isLoading = false;
      _isLocationSettingsOpened = false;
      notifyListeners();
    }
  }

  /// Clears error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
