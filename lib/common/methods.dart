import 'dart:convert';
import 'dart:io';

import 'package:aura_real/apis/model/post_model.dart';
import 'package:aura_real/aura_real.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';

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
  final status = await Permission.camera.status;

  if (status.isGranted || status.isLimited) {
    return true;
  } else if (status.isDenied || status.isPermanentlyDenied || status.isRestricted) {
    showPermissionDialog(
      context,
      title: context.l10n?.cameraPermission ?? 'Camera Permission',
      content: context.l10n?.cameraPermissionContent ?? 'Camera access is required.',
      image: AssetRes.cameraIcon,
    );
    return false;
  } else {
    final result = await Permission.camera.request();
    return result.isGranted || result.isLimited;
  }
}

// ================== GALLERY PERMISSION ==================
Future<bool> checkGalleryPermission(BuildContext context) async {
  final status = await Permission.photos.status;

  if (status.isGranted || status.isLimited) {
    return true;
  } else if (status.isDenied || status.isPermanentlyDenied || status.isRestricted) {
    showPermissionDialog(
      context,
      title: context.l10n?.galleryPermission ?? 'Gallery Permission',
      content: context.l10n?.galleryPermissionContent ?? 'Gallery access is required.',
      image: AssetRes.cameraIcon2,
    );
    return false;
  } else {
    final result = await Permission.photos.request();
    return result.isGranted || result.isLimited;
  }
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
void showPermissionDialog(
    BuildContext context, {
      String? title,
      String? content,
      String? image,
    }) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title ?? 'Permission Required'),
      content: Text(content ?? 'Please enable permission in app settings to continue.'),
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
  await result.writeAsBytes(byte);
  return result;
}

// ================== VIDEO THUMBNAIL ==================
Future<File?> generateVideoThumbnail(String videoUrl) async {
  try {
    final response = await http.get(Uri.parse(videoUrl));
    if (response.statusCode != 200) return null;

    final tempDir = await getTemporaryDirectory();
    final videoFile = File("${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.mp4");
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
Future<void> getFCMToken() async {
  try {
    NotificationSettings settings = await FirebaseMessaging.instance
        .requestPermission(alert: true, badge: true, sound: true);

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await PrefService.set(PrefKeys.fcmToken, token);
      }
    }
  } catch (e) {
    debugPrint("Error getting FCM token: $e");
  }
}
