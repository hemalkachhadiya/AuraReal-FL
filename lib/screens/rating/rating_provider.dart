import 'dart:io';
import 'package:aura_real/utils/color_res.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class RatingProvider extends ChangeNotifier {
  // Public fields (no getters/setters)
  File? capturedImage;
  bool isLoading = false;
  String? errorMessage;
  String currentMode = 'camera'; // Default mode

  final ImagePicker _picker = ImagePicker();

  // Camera functionality
  Future<void> openCamera(BuildContext context) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final hasPermission = await _checkCameraPermission(context);
      if (!hasPermission) {
        errorMessage = 'Camera permission denied';
        notifyListeners();
        return;
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        preferredCameraDevice: CameraDevice.front,
      );

      if (image != null) {
        capturedImage = File(image.path);
        notifyListeners();
      }
    } catch (e) {
      errorMessage = 'Failed to capture image: $e';
      notifyListeners();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Open gallery
  Future<void> openGallery(BuildContext context) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        capturedImage = File(image.path);
        notifyListeners();
      }
    } catch (e) {
      errorMessage = 'Failed to select image: $e';
      notifyListeners();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Check camera permission
  Future<bool> _checkCameraPermission(BuildContext context) async {
    final status = await Permission.camera.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await Permission.camera.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        _showPermissionDialog(context);
      }
      return false;
    }

    return false;
  }

  // Show permission dialog
  void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Camera Permission Required'),
            content: Text(
              'Please enable camera permission in app settings to take photos.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
                child: Text('Settings'),
              ),
            ],
          ),
    );
  }

  // Clear captured image
  void clearImage() {
    capturedImage = null;
    notifyListeners();
  }

  // Save image to profile or upload
  Future<void> saveImage() async {
    if (capturedImage == null) return;

    try {
      isLoading = true;
      notifyListeners();

      await Future.delayed(Duration(seconds: 2)); // Simulate upload
    } catch (e) {
      errorMessage = 'Failed to save image: $e';
      notifyListeners();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Switch mode
  void setMode(String mode) {
    currentMode = mode;
    notifyListeners();
  }
  // Helper method to check if camera tab is selected
  bool get isCameraSelected => currentMode == 'camera';

  // Helper method to check if map tab is selected
  bool get isMapSelected => currentMode == 'map';

  // Get background color for camera tab
  Color getCameraTabBgColor() {
    return isCameraSelected ? ColorRes.primaryColor : ColorRes.lightBlue;
  }

  // Get text color for camera tab
  Color getCameraTabTextColor() {
    return isCameraSelected ? ColorRes.white : ColorRes.primaryColor;
  }

  // Get background color for map tab
  Color getMapTabBgColor() {
    return isMapSelected ? ColorRes.primaryColor : ColorRes.lightBlue;
  }

  // Get text color for map tab
  Color getMapTabTextColor() {
    return isMapSelected ? ColorRes.white : ColorRes.primaryColor;
  }
}
