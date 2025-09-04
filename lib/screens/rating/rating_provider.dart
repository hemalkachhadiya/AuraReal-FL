import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class RatingProvider extends ChangeNotifier {
  final ImagePicker _picker = ImagePicker();

  // Public fields (implicit getters, no setters)
  File? capturedImage;
  bool isLoading = false;
  String? errorMessage;

  // Camera functionality
  Future<void> openCamera(BuildContext context) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      // Check and request camera permission
      final hasPermission = await _checkCameraPermission(context);
      if (!hasPermission) {
        errorMessage = 'Camera permission denied';
        notifyListeners();
        return;
      }

      // Open camera
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        preferredCameraDevice: CameraDevice.front,
      );

      if (image != null) {
        capturedImage = File(image.path);
        notifyListeners();
        _showCaptureSuccess(context);
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
        _showCaptureSuccess(context);
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
      _showPermissionDialog(context);
      return false;
    }

    return false;
  }

  // Show permission dialog
  void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Camera Permission Required'),
        content: const Text(
            'Please enable camera permission in app settings to take photos.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Settings'),
          ),
        ],
      ),
    );
  }

  // Show capture success message
  void _showCaptureSuccess(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Photo captured successfully!'),
        backgroundColor: Theme.of(context).primaryColor, // Replaced ColorRes
        duration: const Duration(seconds: 2),
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
      errorMessage = null;
      notifyListeners();

      // Simulate image upload
      await Future.delayed(const Duration(seconds: 2));

      // Add your upload logic here
      // await uploadImageToServer(capturedImage!);
    } catch (e) {
      errorMessage = 'Failed to save image: $e';
      notifyListeners();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    // Add cleanup if needed (e.g., closing streams or releasing resources)
    super.dispose();
  }
}