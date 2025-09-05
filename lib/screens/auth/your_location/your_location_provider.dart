import 'package:aura_real/aura_real.dart';

class YourLocationProvider extends ChangeNotifier {
  YourLocationProvider({isComeFromSplash});

  bool _isLocationGranted = false;
  final isComeFromSplash = false;
  String? _manualLocation;

  bool get isLocationGranted => _isLocationGranted;

  String? get manualLocation => _manualLocation;

  /// Call when user grants location permission
  void allowLocation() {
    _isLocationGranted = true;
    _manualLocation = null;
    notifyListeners();
  }

  /// Call when user enters location manually
  void setManualLocation(String location) {
    _manualLocation = location;
    _isLocationGranted = false;
    notifyListeners();
  }
}
