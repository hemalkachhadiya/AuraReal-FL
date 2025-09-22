import 'dart:io';
import 'dart:ui' as ui;
import 'package:aura_real/apis/model/geo_location_model.dart';
import 'package:aura_real/apis/model/post_model.dart';
import 'package:aura_real/apis/model/user_marker_data.dart';
import 'package:aura_real/apis/model/user_model.dart';
import 'package:aura_real/apis/rating_profile_apis.dart';
import 'package:aura_real/common/methods.dart';
import 'package:aura_real/screens/rating/model/rating_profile_list_model.dart';
import 'package:aura_real/services/location_permission.dart';
import 'package:aura_real/utils/color_res.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:aura_real/aura_real.dart';
import 'package:geolocator/geolocator.dart'; // Add for distance calculations

class RatingProvider extends ChangeNotifier {
  bool isTorchOn = false; // Track torch state
  RatingProvider() {
    init();
  }

  init() async {
    await getAllUserRatingProfile();
  }

  ///====================== Profile Rating Map Section =========================
  Set<Marker> markers = {};
  GoogleMapController? mapController;
  List<RatingProfileUserModel> users = [];
  RatingProfileUserModel? selectedUser;
  bool loader = false;
  bool rateLoader = false;
  PostModel? selectedPost; // New variable to hold the selected post

  Future<LatLng?> getCurrentLocation() async {
    // Try to get location from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final double? latitude = prefs.getDouble(PrefKeys.latitude);
    final double? longitude = prefs.getDouble(PrefKeys.longitude);

    print("Provider latitude------- $latitude");
    print("Provider longitude------- $longitude");
    if (latitude != null && longitude != null) {
      return LatLng(latitude, longitude);
    }

    return null;
  }

  // Filter users within 10 miles
  List<RatingProfileUserModel> getUsersWithinRadius(
    LatLng userLocation,
    double radiusMiles,
  ) {
    const double milesToMeters = 1609.34; // 1 mile = 1609.34 meters
    return users.where((user) {
      if (user.latitude == null || user.longitude == null) return false;
      final distance = Geolocator.distanceBetween(
        userLocation.latitude,
        userLocation.longitude,
        user.latitude!,
        user.longitude!,
      );
      return distance <=
          (radiusMiles * milesToMeters); // Convert miles to meters
    }).toList();
  }

  List<Widget> mapOverlays = [];

  Future<void> _createMapOverlays() async {
    final currentLocation = await getCurrentLocation();
    final nearbyUsers =
        currentLocation != null
            ? getUsersWithinRadius(currentLocation, 10.0)
            : users;

    mapOverlays = await Future.wait(
      nearbyUsers.map((user) async {
        if (!user.hasLocation) return SizedBox.shrink();

        final imageProvider =
            user.profile?.profileImage != null
                ? NetworkImage(
                  '${EndPoints.domain}${user.profile?.profileImage}',
                )
                : SvgAsset(imagePath: AssetRes.appLogo) as ImageProvider;

        return Positioned(
          left: 0,
          // Convert lat/lng to screen coordinates (requires map controller)
          top: 0,
          // Convert lat/lng to screen coordinates (requires map controller)
          child: GestureDetector(
            onTap: () => _onMarkerTapped(user),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(radius: 30, backgroundImage: imageProvider),
                Text('${user.ratingsAverage.toStringAsFixed(1)}/10 ⭐'),
              ],
            ),
          ),
        );
      }).toList(),
    );

    notifyListeners();
  }

  Future<void> onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    await _createMarkers();
    final currentLocation = await getCurrentLocation();
    print("currentLocation=====123========= ${currentLocation}");
    if (currentLocation != null) {
      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(currentLocation, 12), // Zoom level 12
      );
    }
    notifyListeners();
  }

  Future<void> _createMarkers() async {
    final Set<Marker> newMarkers = {};
    final currentLocation = await getCurrentLocation();

    // Only create markers for users within 10 miles
    final nearbyUsers =
        currentLocation != null
            ? getUsersWithinRadius(currentLocation, 10.0)
            : users;

    for (RatingProfileUserModel user in nearbyUsers) {
      if (!user.hasLocation) continue;

      try {
        BitmapDescriptor markerIcon = await _createCustomMarker(user);

        final Marker marker = Marker(
          markerId: MarkerId(user.id ?? ""),
          position: LatLng(user.latitude ?? 0, user.longitude ?? 0),
          icon: markerIcon,
          infoWindow: InfoWindow(
            title: user.displayName,
            snippet: '${user.ratingsAverage.toStringAsFixed(1)}/10 ⭐',
          ),
          onTap: () => _onMarkerTapped(user),
        );

        newMarkers.add(marker);
      } catch (e) {
        print('Error creating marker for ${user.displayName}: $e');
        final Marker marker = Marker(
          markerId: MarkerId(user.id ?? ""),
          position: LatLng(user.latitude ?? 0, user.longitude ?? 0),
          infoWindow: InfoWindow(
            title: user.displayName,
            snippet: '${user.ratingsAverage.toStringAsFixed(1)}/10 ⭐',
          ),
          onTap: () => _onMarkerTapped(user),
        );

        newMarkers.add(marker);
      }
    }

    markers = newMarkers;
    notifyListeners();
  }

  Future<BitmapDescriptor> _createCustomMarker(
    RatingProfileUserModel user,
  ) async {
    try {
      final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(pictureRecorder);
      final Paint paint = Paint()..isAntiAlias = true;

      const double size = 120.0; // Total size of the marker
      const double borderWidth = 4.0; // Border width
      const double imageSize = 80.0; // Size of the SVG image inside the marker

      // Draw outer white circle
      canvas.drawCircle(
        const Offset(size / 2, size / 2),
        size / 2,
        paint..color = Colors.white,
      );

      // Draw primary color border
      canvas.drawCircle(
        const Offset(size / 2, size / 2),
        (size / 2) - borderWidth,
        paint..color = ColorRes.primaryColor,
      );

      // Draw inner grey circle
      canvas.drawCircle(
        const Offset(size / 2, size / 2),
        (size / 2) - (borderWidth * 2),
        paint..color = Colors.grey[300]!,
      );

      // Load and render the SVG app logo
      final String svgString = await DefaultAssetBundle.of(
        navigatorKey.currentState!.context,
      ).loadString(AssetRes.appLogo);
      final SvgPicture svgPicture = SvgPicture.string(
        svgString,
        width: imageSize,
        height: imageSize,
      );

      // Convert SvgPicture to ui.Image
      final ui.Image svgImage = await _svgPictureToImage(
        svgPicture,
        imageSize.toInt(),
      );

      // Draw the SVG image in the center of the marker
      canvas.drawImage(
        svgImage,
        Offset((size - imageSize) / 2, (size - imageSize) / 2),
        paint,
      );

      // Draw the rating badge at the bottom
      const double badgeSize = 30.0;
      const double badgeY = size - 15;

      canvas.drawCircle(
        const Offset(size / 2, badgeY),
        badgeSize / 2,
        paint..color = ColorRes.primaryColor,
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: user.ratingsAverage.toStringAsFixed(1),
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

      // Convert the canvas to an image
      final ui.Image markerImage = await pictureRecorder.endRecording().toImage(
        size.toInt(),
        size.toInt(),
      );
      final ByteData? byteData = await markerImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      final Uint8List uint8List = byteData!.buffer.asUint8List();

      return BitmapDescriptor.fromBytes(uint8List);
    } catch (e) {
      print('Error creating custom marker for ${user.displayName}: $e');
      return BitmapDescriptor.defaultMarker;
    }
  }

  // Helper method to convert SvgPicture to ui.Image
  Future<ui.Image> _svgPictureToImage(SvgPicture svgPicture, int size) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    // svgPicture.paint(canvas, Size(size.toDouble(), size.toDouble()));
    final picture = pictureRecorder.endRecording();
    return await picture.toImage(size, size);
  }

  // Future<BitmapDescriptor> _createCustomMarker(
  //   RatingProfileUserModel user,
  // ) async {
  //   print(
  //     "User PRofile image -- ${EndPoints.domain}${user.profile?.profileImage}",
  //   );
  //   final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
  //   final Canvas canvas = Canvas(pictureRecorder);
  //   final Paint paint = Paint()..isAntiAlias = true;
  //
  //   const double size = 120.0;
  //   const double borderWidth = 4.0;
  //
  //   canvas.drawCircle(
  //     const Offset(size / 2, size / 2),
  //     size / 2,
  //     paint..color = Colors.white,
  //   );
  //
  //   canvas.drawCircle(
  //     const Offset(size / 2, size / 2),
  //     (size / 2) - borderWidth,
  //     paint..color = ColorRes.primaryColor,
  //   );
  //
  //   canvas.drawCircle(
  //     const Offset(size / 2, size / 2),
  //     (size / 2) - (borderWidth * 2),
  //     paint..color = Colors.grey[300]!,
  //   );
  //
  //   const double badgeSize = 30.0;
  //   const double badgeY = size - 15;
  //
  //   canvas.drawCircle(
  //     const Offset(size / 2, badgeY),
  //     badgeSize / 2,
  //     paint..color = ColorRes.primaryColor,
  //   );
  //
  //   final textPainter = TextPainter(
  //     text: TextSpan(
  //       text: user.ratingsAverage.toStringAsFixed(1),
  //       style: const TextStyle(
  //         color: Colors.white,
  //         fontSize: 12,
  //         fontWeight: FontWeight.bold,
  //       ),
  //     ),
  //     textDirection: TextDirection.ltr,
  //   );
  //   textPainter.layout();
  //   textPainter.paint(
  //     canvas,
  //     Offset(
  //       (size / 2) - (textPainter.width / 2),
  //       badgeY - (textPainter.height / 2),
  //     ),
  //   );
  //
  //   final ui.Picture picture = pictureRecorder.endRecording();
  //   final ui.Image image = await picture.toImage(size.toInt(), size.toInt());
  //   final ByteData? byteData = await image.toByteData(
  //     format: ui.ImageByteFormat.png,
  //   );
  //   final Uint8List uint8List = byteData!.buffer.asUint8List();
  //
  //   return BitmapDescriptor.fromBytes(uint8List);
  // }

  Future<void> _onMarkerTapped(RatingProfileUserModel user) async {
    selectedPost = null;
    selectedUser = user;
    notifyListeners();
    await _fetchOrCreateSelectedPost(user);
    mapController?.animateCamera(
      CameraUpdate.newLatLng(LatLng(user.latitude ?? 0, user.longitude ?? 0)),
    );
  }

  // Future<void> _onMarkerTapped(RatingProfileUserModel user) async {
  //   selectedPost=null;
  //   selectedUser = user;
  //   notifyListeners();
  //   await _fetchOrCreateSelectedPost(user);
  //   mapController?.animateCamera(
  //     CameraUpdate.newLatLng(LatLng(user.latitude ?? 0, user.longitude ?? 0)),
  //   );
  // }

  Future<void> _fetchOrCreateSelectedPost(RatingProfileUserModel user) async {
    try {
      // Option 2: Create a placeholder PostModel if API fetch fails or no userId
      if (selectedPost == null) {
        selectedPost = PostModel(
          userId: UserId(
            id: user.id,
            email: user.email,
            fullName: user.fullName,
            phoneNumber: user.phoneNumber,
            profile: user.profile,
          ),
          content: "Sample post content for ${user.displayName}",
          postImage: user.profile?.profileImage,
          // Use profile image as post image
          postRating: user.ratingsAverage,
          createdAt: DateTime.now(),
          // Add other fields as needed (e.g., location from geoLocation)
          geoLocation: GeoLocation(
            coordinates: [user.latitude ?? 0.0, user.longitude ?? 0.0],
          ),
        );
        print("Created placeholder PostModel for ${user.displayName}");
      }
    } catch (e) {
      print("Error fetching/creating post: $e");
      // Fallback to placeholder if error occurs
      selectedPost = PostModel(
        userId: UserId(
          id: user.id,
          email: user.email,
          fullName: user.fullName,
          phoneNumber: user.phoneNumber,
          profile: user.profile,
        ),
        content: "Default post for ${user.displayName}",
        postRating: user.ratingsAverage,
        createdAt: DateTime.now(),
      );
    }
  }

  Future<void> getAllUserRatingProfile() async {
    if (userData == null || userData?.id == null) return;
    loader = true;
    notifyListeners();
    var latitude = PrefService.getDouble(PrefKeys.latitude);
    var longitude = PrefService.getDouble(PrefKeys.longitude);

    print("Login User Lat $latitude Long $longitude");
    final response = await RatingProfileAPIS.getAllRatingProfileUSerListAPI(
      latitude: latitude.toString() ?? "0",
      longitude: longitude.toString() ?? "0",
    );

    if (response != null && response.isSuccess) {
      users = response.list ?? [];
      print("✅ Loaded ${users.length} users");
      await _createMarkers();
    } else {
      print("❌ Failed to fetch users");
    }

    loader = false;
    notifyListeners();
  }

  ///RateAPI
  Future<void> updateRatePostAPI(
    BuildContext context, {
    String? postId,
    String? rating,
  }) async {
    if (userData == null || userData?.id == null) return;
    rateLoader = true;
    notifyListeners();
    final result = await PostAPI.updateRatePostAPI(
      postId: postId.toString(),
      rating: rating.toString(),
    );
    await getAllUserRatingProfile();
    if (result) {
      context.navigator.pop();
    }
    rateLoader = false;
    notifyListeners();
  }

  ///New Rate API
  Future<void> newRatePostAPI(
    BuildContext context, {
    String? postId,
    String? rating,
  }) async {
    if (userData == null || userData?.id == null) return;
    rateLoader = true;
    notifyListeners();
    final result = await PostAPI.newRatePostAPI(
      postId: postId.toString(),
      newRating: rating.toString(),
    );
    await getAllUserRatingProfile();
    if (result) {
      context.navigator.pop();
    }
    rateLoader = false;
    notifyListeners();
  }

  ///====================== Profile Rating Camera Section ======================
  final FlipCardController flipController = FlipCardController();
  File? capturedImage;
  bool isLoading = false;
  String? errorMessage;
  String currentMode = 'camera';

  bool get isCameraSelected => currentMode == 'camera';

  bool get isMapSelected => currentMode == 'map';

  void showCamera() {
    if (isMapSelected) {
      flipController.toggleCard();
    }
    setMode('camera');
  }

  Future<void> showMap() async {
    await getAllUserRatingProfile();
    if (isCameraSelected) {
      flipController.toggleCard();
    }
    setMode('map');
  }

  final ImagePicker _picker = ImagePicker();

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

  Future<void> openGallery(BuildContext context) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
      final hasPermission = await checkGalleryPermission(context);
      if (!hasPermission) {
        errorMessage = 'Gallery permission denied';
        notifyListeners();
        return;
      }
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

  void setMode(String mode) {
    currentMode = mode;
    notifyListeners();
  }

  Color getCameraTabBgColor() {
    return isCameraSelected ? ColorRes.primaryColor : ColorRes.lightBlue;
  }

  Color getCameraTabTextColor() {
    return isCameraSelected ? ColorRes.white : ColorRes.primaryColor;
  }

  Color getMapTabBgColor() {
    return isMapSelected ? ColorRes.primaryColor : ColorRes.lightBlue;
  }

  Color getMapTabTextColor() {
    return isMapSelected ? ColorRes.white : ColorRes.primaryColor;
  }

  // Future<void> toggleTorch() async {
  //   try {
  //     // Request camera permission
  //     var status = await Permission.camera.request();
  //     if (status.isGranted) {
  //       if (isTorchOn) {
  //         await TorchLight.disableTorch(); // Turn off torch
  //         isTorchOn = false;
  //       } else {
  //         await TorchLight.enableTorch(); // Turn on torch
  //         isTorchOn = true;
  //       }
  //       print('Torch ${isTorchOn ? "on" : "off"}');
  //       notifyListeners(); // Update UI if needed
  //     } else if (status.isDenied) {
  //       print('Camera permission denied');
  //     } else if (status.isPermanentlyDenied) {
  //       print('Camera permission permanently denied. Open app settings to grant.');
  //       await openAppSettings(); // Open settings for user to grant permission
  //     }
  //   } catch (e) {
  //     print('Error toggling torch: $e');
  //     isTorchOn = false; // Reset state on error
  //     notifyListeners();
  //   }
  // }
}
