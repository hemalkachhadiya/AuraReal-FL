import 'dart:ui' as ui;

import 'package:http/http.dart' as http; // Add for distance calculations
import 'package:aura_real/aura_real.dart';
import 'package:map_location_picker/map_location_picker.dart';
import 'package:torch_light/torch_light.dart';

class RatingProvider extends ChangeNotifier {
  bool isTorchOn = false; // Track torch state
  bool isTorchAvailable = false;

  RatingProvider() {
    init();
  }

  init() async {
    await _loadMapDataInBackground();
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
    if (latitude != null && longitude != null) {
      return LatLng(latitude, longitude);
    }

    return null;
  }

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

  /// on Map Created
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

  /// create Markers
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

  /// create Custom Marker
  Future<BitmapDescriptor> _createCustomMarker(
    RatingProfileUserModel user, {
    double size = 70.0,
  }) async {
    try {
      final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(pictureRecorder);
      final Paint paint = Paint()..isAntiAlias = true;

      const double borderWidth = 4.0;
      const double badgeHeight = 20.0;
      const double badgeWidth = 40.0;

      // Draw white circular border background
      final center = Offset(size / 2, size / 2);
      final radius = size / 2;
      canvas.drawCircle(center, radius, paint..color = Colors.white);

      // Draw primary color circle (inner border)
      canvas.drawCircle(
        center,
        radius - borderWidth / 2,
        paint..color = ColorRes.primaryColor,
      );

      // Load user profile image - use app logo as fallback
      ui.Image profileImage;
      bool usingAppLogo = false;

      if (user.profile?.profileImage != null) {
        try {
          final url =
              '${EndPoints.domain}${user.profile!.profileImage!.toBackslashPath()}';
          final response = await http.get(Uri.parse(url));
          if (response.statusCode == 200) {
            final codec = await ui.instantiateImageCodec(response.bodyBytes);
            final frame = await codec.getNextFrame();
            profileImage = frame.image;
          } else {
            // If image load fails, use app logo
            profileImage = await _loadAppLogoAsUiImage();
            usingAppLogo = true;
          }
        } catch (e) {
          print("Failed to load profile image: $e");
          // Use app logo if any error occurs
          profileImage = await _loadAppLogoAsUiImage();
          usingAppLogo = true;
        }
      } else {
        // If no profile image available, use app logo
        profileImage = await _loadAppLogoAsUiImage();
        usingAppLogo = true;
      }

      // If using app logo, don't draw the primary color border
      if (usingAppLogo) {
        // Redraw the white background to cover the primary color border
        canvas.drawCircle(center, radius, paint..color = Colors.white);
      }

      // Clip profile image into circle
      canvas.save();
      final clipPath =
          Path()..addOval(
            Rect.fromCircle(center: center, radius: radius - borderWidth),
          );
      canvas.clipPath(clipPath);

      // Draw profile image (or app logo) inside circle
      final srcRect = Rect.fromLTWH(
        0,
        0,
        profileImage.width.toDouble(),
        profileImage.height.toDouble(),
      );
      final dstRect = Rect.fromCircle(
        center: center,
        radius: radius - borderWidth,
      );
      canvas.drawImageRect(profileImage, srcRect, dstRect, paint);
      canvas.restore();

      // Draw rating badge (white rounded rectangle)
      final badgeRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          (size - badgeWidth) / 2,
          size - badgeHeight - 4,
          badgeWidth,
          badgeHeight,
        ),
        const Radius.circular(6),
      );
      canvas.drawRRect(badgeRect, paint..color = Colors.white);

      // Draw rating text in primary color
      final textPainter = TextPainter(
        text: TextSpan(
          text: user.ratingsAverage.toStringAsFixed(1),
          style: TextStyle(
            color: ColorRes.primaryColor,
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
          (size - textPainter.width) / 2,
          size - badgeHeight - 4 + (badgeHeight - textPainter.height) / 2,
        ),
      );

      // Convert canvas to BitmapDescriptor
      final ui.Image markerImage = await pictureRecorder.endRecording().toImage(
        size.toInt(),
        size.toInt(),
      );
      final byteData = await markerImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      return BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
    } catch (e) {
      print('Error creating custom marker: $e');
      // Fallback to simple app logo marker without primary color
      return await _createSimpleAppLogoMarker();
    }
  }

  /// Helper to load app logo as ui.Image
  Future<ui.Image> _loadAppLogoAsUiImage() async {
    try {
      final byteData = await rootBundle.load(AssetRes.appLogo);
      final codec = await ui.instantiateImageCodec(
        byteData.buffer.asUint8List(),
      );
      final frame = await codec.getNextFrame();
      return frame.image;
    } catch (e) {
      print('Error loading app logo: $e');
      // Fallback to a simple white circle
      return _createSimpleFallbackImage();
    }
  }

  /// Create a simple white circle as fallback
  Future<ui.Image> _createSimpleFallbackImage() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(25, 25), 25, paint);

    final picture = recorder.endRecording();
    return await picture.toImage(50, 50);
  }

  /// Create a simple marker with just the app logo (no primary color)
  Future<BitmapDescriptor> _createSimpleAppLogoMarker() async {
    try {
      final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(pictureRecorder);
      final Paint paint = Paint()..isAntiAlias = true;

      const double size = 70.0;
      final center = Offset(size / 2, size / 2);
      final radius = size / 2;

      // Draw white circular background only (no primary color)
      canvas.drawCircle(center, radius, paint..color = Colors.white);

      // Load and draw app logo
      final appLogoImage = await _loadAppLogoAsUiImage();

      canvas.save();
      final clipPath =
          Path()..addOval(Rect.fromCircle(center: center, radius: radius - 4));
      canvas.clipPath(clipPath);

      final srcRect = Rect.fromLTWH(
        0,
        0,
        appLogoImage.width.toDouble(),
        appLogoImage.height.toDouble(),
      );
      final dstRect = Rect.fromCircle(center: center, radius: radius - 4);
      canvas.drawImageRect(appLogoImage, srcRect, dstRect, paint);
      canvas.restore();

      // Draw rating badge (white rounded rectangle)
      const double badgeHeight = 20.0;
      const double badgeWidth = 40.0;
      final badgeRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          (size - badgeWidth) / 2,
          size - badgeHeight - 4,
          badgeWidth,
          badgeHeight,
        ),
        const Radius.circular(6),
      );
      canvas.drawRRect(badgeRect, paint..color = Colors.white);

      final ui.Image markerImage = await pictureRecorder.endRecording().toImage(
        size.toInt(),
        size.toInt(),
      );
      final byteData = await markerImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      return BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
    } catch (e) {
      print('Error creating simple app logo marker: $e');
      // Ultimate fallback - white circle with text
      return await _createUltimateFallbackMarker();
    }
  }

  /// Ultimate fallback marker - simple white circle with rating
  Future<BitmapDescriptor> _createUltimateFallbackMarker() async {
    final recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    final Paint paint = Paint()..isAntiAlias = true;

    const double size = 70.0;
    final center = Offset(size / 2, size / 2);
    final radius = size / 2;

    // Draw white circle
    canvas.drawCircle(center, radius, paint..color = Colors.white);

    // Draw gray border
    canvas.drawCircle(center, radius - 2, paint..color = Colors.grey);

    // Draw rating text in center
    final textPainter = TextPainter(
      text: TextSpan(
        text: "⭐",
        style: TextStyle(
          color: Colors.pink,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset((size - textPainter.width) / 2, (size - textPainter.height) / 2),
    );

    final ui.Image markerImage = await recorder.endRecording().toImage(
      size.toInt(),
      size.toInt(),
    );
    final byteData = await markerImage.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
  }

  // /// Helper to load app logo as ui.Image
  // Future<ui.Image> _loadAppLogoAsUiImage() async {
  //   try {
  //     final byteData = await rootBundle.load(AssetRes.appLogo);
  //     final codec = await ui.instantiateImageCodec(byteData.buffer.asUint8List());
  //     final frame = await codec.getNextFrame();
  //     return frame.image;
  //   } catch (e) {
  //     print('Error loading app logo: $e');
  //     // Fallback to a simple colored circle if app logo fails
  //     return _createFallbackImage();
  //   }
  // }

  /// Create a simple fallback image if app logo fails to load
  Future<ui.Image> _createFallbackImage() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint =
        Paint()
          ..color = ColorRes.primaryColor
          ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(25, 25), 25, paint);

    final picture = recorder.endRecording();
    return await picture.toImage(50, 50);
  }


  ///on Marker Tapped
  Future<void> _onMarkerTapped(RatingProfileUserModel user) async {
    selectedPost = null;
    selectedUser = user;
    notifyListeners();
    await _fetchOrCreateSelectedPost(user);
    mapController?.animateCamera(
      CameraUpdate.newLatLng(LatLng(user.latitude ?? 0, user.longitude ?? 0)),
    );
  }

  ///fetch Or Create Selected Post
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

  ///get All User Rating Profile
  Future<void> getAllUserRatingProfile() async {
    if (userData == null || userData?.id == null) return;
    loader = true;
    notifyListeners();
    var latitude = PrefService.getDouble(PrefKeys.latitude);
    var longitude = PrefService.getDouble(PrefKeys.longitude);

    print("Login User Lat $latitude Long $longitude");
    final response = await RatingProfileAPIS.getAllRatingProfileUSerListAPI(
      latitude: latitude.toString(),
      longitude: longitude.toString(),
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
    await _loadMapDataInBackground();
    if (result) {
      context.navigator.pop();
    }
    rateLoader = false;
    notifyListeners();
  }

  ///New Profile Rating API
  Future<void> newProfileRateAPI(
    BuildContext context, {
    String? raterId,
    String? rating,
  }) async {
    if (userData == null || userData?.id == null) return;

    try {
      rateLoader = true;
      notifyListeners();

      final result = await RatingProfileAPIS.ratingProfileAPI(
        raterId: raterId.toString(),
        newRating: rating.toString(),
      );
      if (!result) {
        // Revert changes if API failed - use original rating instead of 0.0

        // showCatchToast(result, null);
      }
    } catch (e) {
      // Revert changes on error - use original rating instead of 0.0

      showCatchToast("Error adding rating: ${e.toString()}", null);
    } finally {
      rateLoader = false;
      notifyListeners();
    }
  }

  ///New Rate API - Add new rating
  Future<void> updateProfileRateAPI(
    BuildContext context, {
    String? raterId,
    String? rating,
  }) async {
    if (userData == null || userData?.id == null) return;

    try {
      rateLoader = true;
      notifyListeners();

      final result = await RatingProfileAPIS.updateProfileRateAPI(
        raterId: raterId.toString(),
        newRating: rating.toString(),
      );
      if (!result) {
        // Revert changes if API failed - use original rating instead of 0.0

        // showCatchToast(result, null);
      }
    } catch (e) {
      // Revert changes on error - use original rating instead of 0.0

      showCatchToast("Error adding rating: ${e.toString()}", null);
    } finally {
      rateLoader = false;
      notifyListeners();
    }
  }

  ///Create Chat Room For Send Message
  Future<void> createChatRoom(BuildContext context) async {
    if (userData == null || userData?.id == null) return;

    loader = true;
    notifyListeners();

    try {
      final result = await ChatApis.createChatRoom(
        userId: userData!.id!,
        followUserId: selectedUser!.id!, // The profile user's ID
      );

      if (result.success! && result.data != null) {
        // Navigate to MessageScreen with provider
        // Build ChatUser for MessageScreen
        final chatUser = ChatUser(
          id: selectedUser?.id!,
          name: selectedUser?.fullName ?? "User",
          avatarUrl: selectedUser?.profile?.profileImage ?? "",
          isOnline: true,
          // lastSeen: DateTime.now().toString(),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => ChangeNotifierProvider(
                  create: (_) {
                    final provider = MessageProvider();
                    provider.initializeChat(
                      user: chatUser,
                      roomId: result.data?.id ?? "",
                    );
                    return provider;
                  },
                  child: MessageScreen(chatUser: chatUser),
                ),
          ),
        );
        // Navigate to chat screen or handle success

        // Navigator.push(context, MaterialPageRoute(
        //   builder: (context) => MessageScreen(chatUser: ),
        // ));
      } else {
        showCatchToast(result.message ?? "Failed to create chat room", null);
      }
    } catch (e) {
      showCatchToast(e.toString(), null);
    } finally {
      loader = false;
      notifyListeners();
    }
  }

  ///====================== Profile Rating Camera Section ======================
  final FlipCardController flipController = FlipCardController();
  File? capturedImage;
  bool isLoading = false;
  String? errorMessage;
  String currentMode = 'camera';

  bool get isCameraSelected => currentMode == 'camera';

  bool get isMapSelected => currentMode == 'map';

  /// Initialize torch availability check
  Future<void> initializeTorch() async {
    try {
      isTorchAvailable = await TorchLight.isTorchAvailable();
      notifyListeners();
    } catch (e) {
      print('Error checking torch availability: $e');
      isTorchAvailable = false;
      notifyListeners();
    }
  }

  /// Toggle torch on/off
  Future<void> toggleTorch() async {
    if (!isTorchAvailable) {
      errorMessage = 'Torch not available on this device';
      notifyListeners();
      return;
    }

    try {
      if (isTorchOn) {
        print('torhc---------------1');
        await TorchLight.disableTorch();
        isTorchOn = false;
      } else {
        print('torhc---------------2');

        await TorchLight.enableTorch();
        isTorchOn = true;
      }
      notifyListeners();
    } catch (e) {
      print('Error toggling torch: $e');
      errorMessage = 'Failed to toggle torch: $e';
      notifyListeners();
    }
  }

  /// Turn off torch when switching modes or disposing
  Future<void> turnOffTorch() async {
    if (isTorchOn && isTorchAvailable) {
      try {
        await TorchLight.disableTorch();
        isTorchOn = false;
        notifyListeners();
      } catch (e) {
        print('Error turning off torch: $e');
      }
    }
  }

  void showCamera() {
    // Check the current mode before changing it
    if (isMapSelected) {
      flipController.toggleCard();
    }
    setMode('camera');
  }

  Future<void> showMap() async {
    print('showMap called - current mode: $currentMode');
    // Check the current mode before changing it
    if (isCameraSelected) {
      print('Flipping card...');
      flipController.toggleCard();
    }
    setMode('map');
    print('Mode set to: $currentMode');

    print('Loading map data...');
    // Load data in background
    _loadMapDataInBackground();
    print('Map data loaded');
  }

  void setMode(String mode) {
    currentMode = mode;
    notifyListeners();
  }

  Future<void> _loadMapDataInBackground() async {
    try {
      await getAllUserRatingProfile();
    } catch (e) {
      print('Error loading map data: $e');
      // You might want to show an error message to the user
    }
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
}
