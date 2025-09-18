import 'package:aura_real/apis/model/post_model.dart';
import 'package:aura_real/aura_real.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

// Helper function to get media type
MediaType? getMediaType(String filePath) {
  final mimeType = lookupMimeType(filePath);
  if (mimeType != null) {
    final parts = mimeType.split('/');
    return MediaType(parts[0], parts[1]);
  }
  return MediaType('application', 'octet-stream'); // Fallback for unknown types
}

Future<void> logoutUser() async {
  await PrefService.removeKey(PrefKeys.token);
  await PrefService.removeKey(PrefKeys.userData);
}

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

void recordError(dynamic exception, StackTrace? stack) {
  debugPrint(exception.toString());
}

void hideKeyboard({BuildContext? context}) {
  context ??= navigatorKey.currentContext;
  if (context == null) {
    return;
  }
  if (FocusScope.of(context).hasFocus) {
    FocusScope.of(context).requestFocus(FocusNode());
  }
}

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

Future<bool> checkCameraPermission(BuildContext context) async {
  final permission = await Permission.camera.request();

  if (!context.mounted) return false;

  if (permission.isGranted || permission.isLimited) {
    return true;
  } else if (permission.isDenied ||
      permission.isPermanentlyDenied ||
      permission.isRestricted) {
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
}

String calculateMd5(String input) {
  // Compute MD5 hash
  var bytes = utf8.encode(input);
  var digest = md5.convert(bytes);

  // Encode MD5 hex digest to Base64
  var base64Encoded = base64.encode(utf8.encode(digest.toString()));
  return base64Encoded;
}

String generateCustomString(DateTime dateTime) {
  // Get current timestamp in milliseconds
  String timestamp = dateTime.millisecondsSinceEpoch.toString();

  // Reverse timestamp
  String timestampReversed = timestamp.split('').reversed.join();

  // Create the original string
  String str = '$timestamp&-api-&$timestampReversed';

  // Compute the encoded MD5 + timestamp
  String result = calculateMd5(str) + timestamp;

  return result;
}

Future<void> requestPermissions() async {
  await [
    Permission.location,
    Permission.bluetoothScan,
    Permission.bluetoothConnect,
    Permission.locationWhenInUse,
  ].request();
}

// Function to open the comment bottom sheet
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

// Function to open Comments Bottom Sheet specifically
// void openCommentsBottomSheet(
//   BuildContext context, {
//   required List<Comment> comments,
// }) {
//   openCustomDraggableBottomSheet(
//     context,
//     customChild: CommentsContent(comments: comments),
//     showButtons: false,
//     initialChildSize: 0.7,
//     minChildSize: 0.5,
//     maxChildSize: 1.0,
//     padding: EdgeInsets.zero,
//   );
// }

// Check camera permission
// Future<bool>  checkCameraPermission(BuildContext context) async {
//   final status = await Permission.camera.status;
//
//   if (status.isGranted) {
//     return true;
//   }
//
//   if (status.isDenied) {
//     final result = await Permission.camera.request();
//     return result.isGranted;
//   }
//
//   if (status.isPermanentlyDenied) {
//     if (context.mounted) {
//       showPermissionDialog(context);
//     }
//     return false;
//   }
//
//   return false;
// }

// Show permission dialog
void showPermissionDialog(BuildContext context) {
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

Future<void> fetchLocation(BuildContext context) async {
  final (lat, lon, error) = await GetLocationService.getCurrentLatLon(context);
  if (lat != null && lon != null) {
    // Use latitude and longitude (e.g., save to PrefService or navigate)
    await PrefService.set('latitude', lat);
    await PrefService.set('longitude', lon);
    if (context.mounted) {
      context.navigator.pushReplacementNamed(DashboardScreen.routeName);
    }
  } else {}
}

Future<File?> compressImage(File? file, {double? requestedSize}) async {
  if (file == null) {
    return null;
  }
  Directory directory = await getTemporaryDirectory();
  double requiredSize = requestedSize ?? (1024 * 1024 * 2);
  int fileSize = file.lengthSync();
  int quality = ((100 * requiredSize) / fileSize).round();
  var byte = await FlutterImageCompress.compressWithList(
    file.absolute.readAsBytesSync(),
    quality: quality > 100 ? 95 : quality,
    rotate: 0,
  );

  debugPrint(file.lengthSync().toString());

  File result = File(
    "${directory.path}/${DateTime.now().microsecondsSinceEpoch}.jpg",
  );

  if (result.existsSync()) {
    await result.delete();
  }
  result.writeAsBytesSync(byte);
  debugPrint(result.lengthSync().toString());

  final size = result.lengthSync();
  debugPrint(size.toString());

  return result;
}

Future<File?> generateVideoThumbnail(String videoUrl) async {
  try {
    // 1. Download video to temp file
    final response = await http.get(Uri.parse(videoUrl));

    if (response.statusCode != 200) return null;

    final tempDir = await getTemporaryDirectory();
    final videoFile = File(
      "${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.mp4",
    );
    await videoFile.writeAsBytes(response.bodyBytes);

    // 2. Generate thumbnail from local video file
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

/// Get FCM token
  getFCMToken() async {
  try {
    // Request permission for notifications
    NotificationSettings settings = await FirebaseMessaging.instance
        .requestPermission(alert: true, badge: true, sound: true);

    debugPrint('User granted permission: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      String? token = await FirebaseMessaging.instance.getToken();

      if (token != null) {
        debugPrint('FCM Token: $token');
        // Store the token in shared preferences
        await PrefService.set(PrefKeys.fcmToken, token);
      } else {
        debugPrint('Failed to retrieve FCM token');
      }
    } else {
      debugPrint('Notification permission denied');
    }
  } catch (e) {
    debugPrint("Error getting FCM token: $e");
  }
}


