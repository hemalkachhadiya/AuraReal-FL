import 'package:aura_real/aura_real.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

// ================== MEDIA TYPE ==================
MediaType? getMediaType(String filePath) {
  final mimeType = lookupMimeType(filePath);
  if (mimeType != null) {
    final parts = mimeType.split('/');
    return MediaType(parts[0], parts[1]);
  }
  return MediaType('application', 'octet-stream'); // fallback
}

// ================== AUTH ==================
Future<void> logoutUser() async {
  await PrefService.removeKey(PrefKeys.token);
  await PrefService.removeKey(PrefKeys.userData);
}

// ================== NORMALIZE ==================
dynamic normalizeFalseToNull(dynamic input) {
  if (input is Map) {
    return input.map(
      (key, value) => MapEntry(key, normalizeFalseToNull(value)),
    );
  } else if (input is List) {
    return input.map(normalizeFalseToNull).toList();
  } else if (input == false) {
    return null;
  } else {
    return input;
  }
}

// ================== ERROR ==================
void recordError(dynamic exception, StackTrace? stack) {
  debugPrint(exception.toString());
}

// ================== KEYBOARD ==================
void hideKeyboard({BuildContext? context}) {
  context ??= navigatorKey.currentContext;
  if (context == null) return;
  if (FocusScope.of(context).hasFocus) {
    FocusScope.of(context).requestFocus(FocusNode());
  }
}

// ================== USER ==================
LoginRes? get userData {
  try {
    final str = PrefService.getString(PrefKeys.userData);
    if (str.isNotEmpty) {
      return LoginRes.fromJson(jsonDecode(str));
    }
  } catch (e) {
    debugPrint(e.toString());
  }
  return null;
}

// ================== CAMERA PERMISSION ==================
Future<bool> checkCameraPermission(BuildContext context) async {
  MethodChannel _platform = MethodChannel("camera_permission_channel");
  if (Platform.isAndroid) {
    final status = await Permission.camera.request();

    if (!context.mounted) return false;

    if (status.isGranted || status.isLimited) {
      return true;
    } else if (status.isDenied ||
        status.isPermanentlyDenied ||
        status.isRestricted) {
      openAppBottomShit(
        context: context,
        title: context.l10n?.cameraPermission,
        content: context.l10n?.cameraPermissionContent,
        btnText: context.l10n?.openSettings,
        image: AssetRes.cameraIcon,
        onBtnTap: () {
          openAppSettings();
          context.navigator.pop();
        },
      );
      return false;
    }
    return false;
  } else {
    try {
      final status = await _platform.invokeMethod<String>(
        "checkCameraPermission",
      );
      debugPrint("📸 iOS Camera permission status = $status");

      switch (status) {
        case "authorized":
        case "granted":
          return true;
        case "denied":
        case "permanentlyDenied":
          await showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('Camera Permission Required'),
                  content: const Text(
                    'Camera access is permanently denied. Please enable it from Settings.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        openAppSettings();
                        Navigator.of(context).pop();
                      },
                      child: const Text('Open Settings'),
                    ),
                  ],
                ),
          );
          return false;
        default:
          return false;
      }
    } on PlatformException catch (e) {
      debugPrint("⚠️ iOS permission channel error: $e");
      return false;
    }
  }
}

/// --- CAMERA PERMISSION ---
Future<bool> requestCameraPermission(BuildContext context) async {
  MethodChannel _platform = MethodChannel("camera_permission_channel");
  final status = await Permission.camera.status;

  if (Platform.isAndroid) {
    if (status.isGranted) {
      return true;
    } else if (status.isDenied) {
      final result = await Permission.camera.request();
      return result.isGranted;
    } else if (status.isPermanentlyDenied) {
      // Show dialog directing user to settings
      await showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Camera Permission Required'),
              content: Text(
                'Camera access is permanently denied. Please enable it from Settings.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    openAppSettings();
                    Navigator.of(context).pop();
                  },
                  child: Text('Open Settings'),
                ),
              ],
            ),
      );
      return false;
    }
    return false;
  } else {
    try {
      final status = await _platform.invokeMethod<String>(
        "checkCameraPermission",
      );
      debugPrint("📸 iOS Camera permission status = $status");

      switch (status) {
        case "authorized":
        case "granted":
          return true;
        case "denied":
        case "permanentlyDenied":
          await showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('Camera Permission Required'),
                  content: const Text(
                    'Camera access is permanently denied. Please enable it from Settings.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        openAppSettings();
                        Navigator.of(context).pop();
                      },
                      child: const Text('Open Settings'),
                    ),
                  ],
                ),
          );
          return false;
        default:
          return false;
      }
    } on PlatformException catch (e) {
      debugPrint("⚠️ iOS permission channel error: $e");
      return false;
    }
  }
}

// ================== GALLERY PERMISSION ==================
Future<bool> checkGalleryPermission(BuildContext context) async {
  final status = await Permission.photos.request(); // iOS Photos permission

  if (!context.mounted) return false;

  if (status.isGranted || status.isLimited) {
    return true;
  } else if (status.isDenied ||
      status.isPermanentlyDenied ||
      status.isRestricted) {
    openAppBottomShit(
      context: context,
      title: context.l10n?.galleryPermission,
      content: context.l10n?.galleryPermissionContent,
      btnText: context.l10n?.openSettings,
      image: AssetRes.cameraIcon2,
      onBtnTap: () {
        openAppSettings();
        context.navigator.pop();
      },
    );
    return false;
  }
  return false;
}

// ================== STRING HELPERS ==================
String calculateMd5(String input) {
  var bytes = utf8.encode(input);
  var digest = md5.convert(bytes);
  var base64Encoded = base64.encode(utf8.encode(digest.toString()));
  return base64Encoded;
}

String generateCustomString(DateTime dateTime) {
  String timestamp = dateTime.millisecondsSinceEpoch.toString();
  String timestampReversed = timestamp.split('').reversed.join();
  String str = '$timestamp&-api-&$timestampReversed';
  String result = calculateMd5(str) + timestamp;
  return result;
}

// ================== PERMISSION REQUESTS ==================
Future<void> requestPermissions() async {
  await [
    Permission.location,
    Permission.bluetoothScan,
    Permission.bluetoothConnect,
    Permission.locationWhenInUse,
  ].request();
}

// ================== COMMENT SHEET ==================
Future<T?> openCommentBottomSheet<T>({
  required BuildContext context,
  required PostModel post,
  Function(String)? onCommentSubmitted,
}) async {
  return await showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return CommentBottomSheetContent(
        post: post,
        onCommentSubmitted: onCommentSubmitted,
      );
    },
  );
}

// ================== CHAT TIME ==================
String formatTime(DateTime dateTime) {
  final now = DateTime.now();
  final isToday =
      now.year == dateTime.year &&
      now.month == dateTime.month &&
      now.day == dateTime.day;

  if (isToday) {
    return "${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
  } else {
    return "${dateTime.day.toString().padLeft(2, '0')}/"
        "${dateTime.month.toString().padLeft(2, '0')}/"
        "${dateTime.year}";
  }
}

// ================== PERMISSION DIALOG ==================
void showPermissionDialog(BuildContext context) {
  showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
          title: Text('Permission Required'),
          content: Text(
            'Please enable permission in app settings to continue.',
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

// ================== LOCATION ==================
Future<void> fetchLocation(BuildContext context) async {
  final (lat, lon, error) = await GetLocationService.getCurrentLatLon(context);
  if (lat != null && lon != null) {
    await PrefService.set('latitude', lat);
    await PrefService.set('longitude', lon);
    if (context.mounted) {
      context.navigator.pushReplacementNamed(DashboardScreen.routeName);
    }
  }
}

// ================== IMAGE COMPRESS ==================
Future<File?> compressImage(File? file, {double? requestedSize}) async {
  if (file == null) return null;

  Directory directory = await getTemporaryDirectory();
  double requiredSize = requestedSize ?? (1024 * 1024 * 2);
  int fileSize = file.lengthSync();
  int quality = ((100 * requiredSize) / fileSize).round();

  var byte = await FlutterImageCompress.compressWithList(
    file.absolute.readAsBytesSync(),
    quality: quality > 100 ? 95 : quality,
    rotate: 0,
  );

  File result = File(
    "${directory.path}/${DateTime.now().microsecondsSinceEpoch}.jpg",
  );

  if (result.existsSync()) {
    await result.delete();
  }
  result.writeAsBytesSync(byte);
  return result;
}

// ================== VIDEO THUMBNAIL ==================
Future<File?> generateVideoThumbnail(String videoUrl) async {
  try {
    final response = await http.get(Uri.parse(videoUrl));
    if (response.statusCode != 200) return null;

    final tempDir = await getTemporaryDirectory();
    final videoFile = File(
      "${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.mp4",
    );
    await videoFile.writeAsBytes(response.bodyBytes);

    final String? thumbPath = await VideoThumbnail.thumbnailFile(
      video: videoFile.path,
      imageFormat: ImageFormat.JPEG,
      maxHeight: 300,
      quality: 75,
    );

    if (thumbPath == null) return null;
    return File(thumbPath);
  } catch (e) {
    debugPrint("Thumbnail generation failed: $e");
    return null;
  }
}

// ================== FCM TOKEN ==================
getFCMToken() async {
  try {
    NotificationSettings settings = await FirebaseMessaging.instance
        .requestPermission(alert: true, badge: true, sound: true);

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        debugPrint("FCM KEY:- ${token}");
        await PrefService.set(PrefKeys.fcmToken, token);
      }
    }
  } catch (e) {
    debugPrint("Error getting FCM token: $e");
  }
}
