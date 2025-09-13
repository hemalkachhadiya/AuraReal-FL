import 'dart:io';
import 'dart:ui' as ui;
import 'package:aura_real/apis/model/user_marker_data.dart';
import 'package:aura_real/common/methods.dart';
import 'package:aura_real/utils/color_res.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:map_location_picker/map_location_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../aura_real.dart';

class RatingProvider extends ChangeNotifier {
  ///====================== Profile Rating Map Section =========================
  Set<Marker> markers = {};
  // Google Maps related
  GoogleMapController? mapController;
  // Sample user data - replace with your actual data
  List<UserMarkerData> users = [
    UserMarkerData(
      id: '1',
      name: 'Kadin Schleifer',
      profileImage: 'https://example.com/profile1.jpg', // Replace with actual image URLs
      rating: 8.84,
      position: const LatLng(37.7849, -122.4094), // San Francisco
      age: 25,
    ),
    UserMarkerData(
      id: '2',
      name: 'Sarah Johnson',
      profileImage: 'https://example.com/profile2.jpg',
      rating: 9.2,
      position: const LatLng(37.7849, -122.4194),
      age: 28,
    ),
    UserMarkerData(
      id: '3',
      name: 'Mike Chen',
      profileImage: 'https://example.com/profile3.jpg',
      rating: 7.8,
      position: const LatLng(37.7749, -122.4294),
      age: 32,
    ),
    UserMarkerData(
      id: '4',
      name: 'Emma Davis',
      profileImage: 'https://example.com/profile4.jpg',
      rating: 8.5,
      position: const LatLng(37.7649, -122.4394),
      age: 24,
    ),
    UserMarkerData(
      id: '5',
      name: 'Alex Rodriguez',
      profileImage: 'https://example.com/profile5.jpg',
      rating: 9.1,
      position: const LatLng(37.7549, -122.4494),
      age: 29,
    ),
  ];

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _createMarkers();
  }

  // Create custom markers for users
  Future<void> _createMarkers() async {
    final Set<Marker> newMarkers = {};

    for (UserMarkerData user in users) {
      try {
        // Create custom marker icon with user profile
        BitmapDescriptor markerIcon = await _createCustomMarker(user);

        final Marker marker = Marker(
          markerId: MarkerId(user.id),
          position: user.position,
          icon: markerIcon,
          infoWindow: InfoWindow(
            title: user.name,
            snippet: '${user.rating}/10 ⭐ • ${user.age} years',
          ),
          onTap: () => _onMarkerTapped(user),
        );

        newMarkers.add(marker);
      } catch (e) {
        print('Error creating marker for ${user.name}: $e');
        // Fallback to default marker
        final Marker marker = Marker(
          markerId: MarkerId(user.id),
          position: user.position,
          infoWindow: InfoWindow(
            title: user.name,
            snippet: '${user.rating}/10 ⭐',
          ),
          onTap: () => _onMarkerTapped(user),
        );
        newMarkers.add(marker);
      }
    }

    markers = newMarkers;
    notifyListeners();
  }

  // Create custom marker with circular profile image
  Future<BitmapDescriptor> _createCustomMarker(UserMarkerData user) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..isAntiAlias = true;

    const double size = 120.0;
    const double borderWidth = 4.0;

    // Draw outer border (white)
    canvas.drawCircle(
      const Offset(size / 2, size / 2),
      size / 2,
      paint..color = Colors.white,
    );

    // Draw inner border (primary color)
    canvas.drawCircle(
      const Offset(size / 2, size / 2),
      (size / 2) - borderWidth,
      paint..color = const Color(0xFF6366F1), // Replace with your primary color
    );

    // Draw profile circle background
    canvas.drawCircle(
      const Offset(size / 2, size / 2),
      (size / 2) - (borderWidth * 2),
      paint..color = Colors.grey[300]!,
    );

    // Draw rating badge at the bottom
    const double badgeSize = 30.0;
    const double badgeY = size - 15;

    // Badge background
    canvas.drawCircle(
      const Offset(size / 2, badgeY),
      badgeSize / 2,
      paint..color = const Color(0xFF6366F1),
    );

    // Draw rating text
    final textPainter = TextPainter(
      text: TextSpan(
        text: user.rating.toStringAsFixed(1),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size / 2) - (textPainter.width / 2),
        badgeY - (textPainter.height / 2),
      ),
    );

    // Convert to image
    final ui.Picture picture = pictureRecorder.endRecording();
    final ui.Image image = await picture.toImage(size.toInt(), size.toInt());
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List uint8List = byteData!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(uint8List);
  }

  UserMarkerData? selectedUser;

  // Handle marker tap
  void _onMarkerTapped(UserMarkerData user) {

    print('Tapped on ${user.name}');
    selectedUser = user;
    notifyListeners();
    print('Selected user: ${user.name}');

    // Optional: Center map on selected user
    mapController?.animateCamera(
      CameraUpdate.newLatLng(user.position),
    );
    // You can add navigation to user profile or show bottom sheet here
    // For example:
    // Navigator.pushNamed(context, '/user_profile', arguments: user);
  }


  ///====================== Profile Rating Camera Section ======================
  final FlipCardController flipController = FlipCardController();
  File? capturedImage;
  bool isLoading = false;
  String? errorMessage;
  String currentMode = 'camera'; // Default mode

  // bool isCameraSelected = true;

  bool get isCameraSelected => currentMode == 'camera';

  bool get isMapSelected => currentMode == 'map';

  void showCamera() {
    if (isMapSelected) {
      flipController.toggleCard();
    }
    setMode('camera');
  }

  void showMap() {
    if (isCameraSelected) {
      flipController.toggleCard();
    }
    setMode('map');
  }

  final ImagePicker _picker = ImagePicker();

  ///Open Camera
  Future<void> openCamera(BuildContext context) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final hasPermission = await checkCameraPermission(context);
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

  ///Open Gallery
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

  ///Set Mode
  void setMode(String mode) {
    currentMode = mode;
    notifyListeners();
  }

  ///Get Camera Ta Bg
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
