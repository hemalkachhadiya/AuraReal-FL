import 'dart:ui' as ui;

import 'package:http/http.dart' as http; // Add for distance calculations
import 'package:aura_real/aura_real.dart';
import 'package:map_location_picker/map_location_picker.dart';

class RatingProvider extends ChangeNotifier {
  bool isTorchOn = false; // Track torch state
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
    double size = 70.0, // default small
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

      // Load user profile image
      ui.Image? profileImage;
      if (user.profile?.profileImage != null) {
        try {
          final url =
              '${EndPoints.domain}${user.profile!.profileImage!.toBackslashPath()}';
          final response = await http.get(Uri.parse(url));
          if (response.statusCode == 200) {
            final codec = await ui.instantiateImageCodec(response.bodyBytes);
            final frame = await codec.getNextFrame();
            profileImage = frame.image;
          }
        } catch (e) {
          print("Failed to load profile image: $e");
        }
      }

      // Use default avatar if profile image fails
      profileImage ??= await _loadDefaultAvatarAsUiImage();

      // Clip profile image into circle
      canvas.save();
      final clipPath =
          Path()..addOval(
            Rect.fromCircle(center: center, radius: radius - borderWidth),
          );
      canvas.clipPath(clipPath);

      // Draw profile image inside circle
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
      return BitmapDescriptor.defaultMarker;
    }
  }

  /// Helper to load default avatar as ui.Image
  Future<ui.Image> _loadDefaultAvatarAsUiImage() async {
    final byteData = await rootBundle.load(AssetRes.appLogo);
    final codec = await ui.instantiateImageCodec(byteData.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    return frame.image;
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
