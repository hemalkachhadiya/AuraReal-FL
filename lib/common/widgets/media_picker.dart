import 'package:aura_real/aura_real.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

Future<File?> openMediaPicker(
    BuildContext context, {
      bool useCameraForImage = false,
    }) async {
  final picker = ImagePicker();

  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) return true;
    if (status.isDenied) return false; // user denied, can try again
    if (status.isPermanentlyDenied) return false; // user denied permanently
    return false;
  }

  // If using camera directly for image
  if (useCameraForImage) {
    final canOpenCamera = await requestCameraPermission();
    print("canOpenCamera============= $canOpenCamera");
    if (canOpenCamera) {
      final xFile = await picker.pickImage(source: ImageSource.camera);
      if (xFile != null) {
        return await compressImage(File(xFile.path),
            requestedSize: 1024 * 1024 * 0.5);
      }
    } else {
      // Permission denied, do nothing, don't redirect to settings
      return null;
    }
  }

  // Step 1: Choose Media Type
  final mediaType = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
    ),
    builder: (BuildContext context) {
      return Container(
        width: 100.w,
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Select Media Type",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            ListTile(
              leading: Icon(Icons.image, color: Colors.blue),
              title: Text("Image"),
              onTap: () => Navigator.pop(context, 'image'),
            ),
            16.ph.spaceVertical,
            ListTile(
              leading: Icon(Icons.video_collection, color: Colors.red),
              title: Text("Video"),
              onTap: () => Navigator.pop(context, 'video'),
            ),
          ],
        ),
      );
    },
  );

  if (mediaType == null) return null;

  File? selectedFile;

  // Step 2: Show options based on selected media type
  if (mediaType == 'image') {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (BuildContext context) {
        return MediaPicker(mediaType: 'image');
      },
    );

    if (source != null) {
      if (source == ImageSource.camera) {
        final canOpenCamera = await requestCameraPermission();
        if (canOpenCamera) {
          final xFile = await picker.pickImage(source: ImageSource.camera);
          if (xFile != null) {
            selectedFile = await compressImage(File(xFile.path),
                requestedSize: 1024 * 1024 * 0.5);
          }
        } else {
          print("Camera permission denied for image. Not opening Settings.");
          return null;
        }
      } else {
        final xFile = await picker.pickImage(source: source);
        if (xFile != null) {
          selectedFile = await compressImage(File(xFile.path),
              requestedSize: 1024 * 1024 * 0.5);
        }
      }
    }
  } else if (mediaType == 'video') {
    final source = await showModalBottomSheet<File?>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (BuildContext context) {
        return MediaPicker(mediaType: 'video');
      },
    );

    if (source != null) {
      selectedFile = source;
    }
  }

  return selectedFile;
}

class MediaPicker extends StatelessWidget {
  final String? mediaType;

  const MediaPicker({super.key, this.mediaType});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.w,
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            mediaType == 'image' ? "Select Image From" : "Select Video From",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          if (mediaType == 'image') ...[
            ListTile(
              leading: Icon(Icons.photo_library, color: Colors.blue),
              title: Text("Gallery"),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            16.ph.spaceVertical,
            ListTile(
              leading: Icon(Icons.camera_alt, color: Colors.green),
              title: Text("Camera"),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ] else if (mediaType == 'video') ...[
            ListTile(
              leading: Icon(Icons.video_library, color: Colors.red),
              title: Text("Gallery"),
              onTap: () async {
                final xFile =
                await ImagePicker().pickVideo(source: ImageSource.gallery);
                Navigator.pop(context, xFile != null ? File(xFile.path) : null);
              },
            ),
            16.ph.spaceVertical,
            ListTile(
              leading: Icon(Icons.videocam, color: Colors.purple),
              title: Text("Camera"),
              onTap: () async {
                final xFile =
                await ImagePicker().pickVideo(source: ImageSource.camera);
                Navigator.pop(context, xFile != null ? File(xFile.path) : null);
              },
            ),
          ],
        ],
      ),
    );
  }
}
