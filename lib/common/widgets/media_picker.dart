import 'package:aura_real/aura_real.dart';
import 'package:file_picker/file_picker.dart';

Future<File?> openMediaPicker(
  BuildContext context, {
  bool useCameraForImage = false,
  String? mediaType, // New parameter to specify media type (e.g., 'profile')
}) async {
  // If useCameraForImage is true, open the camera directly for images
  if (useCameraForImage) {
    final canOpenCamera = await checkCameraPermission(context);
    if (canOpenCamera) {
      final xFile = await ImagePicker().pickImage(source: ImageSource.camera);
      if (xFile != null) {
        final compressedFile = await compressImage(
          File(xFile.path),
          requestedSize: (1024 * 1024 * 0.5), // 0.5 MB
        );
        return compressedFile;
      }
    }
    return null;
  }

  // Step 1: Choose between Image or Video
  if (mediaType == 'profile') {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (BuildContext context) {
        return MediaPicker(mediaType: 'image'); // Only image options
      },
    );

    if (source != null) {
      if (source == ImageSource.camera && context.mounted) {
        final canOpenCamera = await checkCameraPermission(context);
        if (canOpenCamera) {
          final xFile = await ImagePicker().pickImage(source: source);
          if (xFile != null) {
            final compressedFile = await compressImage(
              File(xFile.path),
              requestedSize: (1024 * 1024 * 0.5),
            );
            if (compressedFile != null) {
              return compressedFile;
            }
          }
        }
      } else {
        final xFile = await ImagePicker().pickImage(source: source);
        if (xFile != null) {
          final compressedFile = await compressImage(
            File(xFile.path),
            requestedSize: (1024 * 1024 * 0.5),
          );
          if (compressedFile != null) {
            return compressedFile;
          }
        }
      }
    }
    return null;
  }
  final mediaTypeSelected = await showModalBottomSheet<String>(
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

  if (mediaTypeSelected == null) return null;

  // Step 2: Show options based on selected media type
  File? selectedFile;
  if (mediaTypeSelected == 'image') {
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
      if (source == ImageSource.camera && context.mounted) {
        final canOpenCamera = await checkCameraPermission(context);
        if (canOpenCamera) {
          // Proceed directly if permission is granted
          final xFile = await ImagePicker().pickImage(source: source);
          if (xFile != null) {
            final compressedFile = await compressImage(
              File(xFile.path),
              requestedSize: (1024 * 1024 * 0.5),
            );
            if (compressedFile != null) {
              selectedFile = compressedFile;
            }
          }
        }
      } else {
        // For gallery, no permission check needed
        final xFile = await ImagePicker().pickImage(source: source);
        if (xFile != null) {
          final compressedFile = await compressImage(
            File(xFile.path),
            requestedSize: (1024 * 1024 * 0.5),
          );
          if (compressedFile != null) {
            selectedFile = compressedFile;
          }
        }
      }
    }
  } else if (mediaTypeSelected == 'video') {
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

Future<File?> openFilePicker({
  required BuildContext context,
  List<String>? allowedExtensions, // e.g. ['pdf', 'docx', 'jpg']
  bool allowMultiple = false,
}) async {
  try {
    final result = await FilePicker.platform.pickFiles(
      type: allowedExtensions != null ? FileType.custom : FileType.any,
      allowedExtensions: allowedExtensions,
      allowMultiple: allowMultiple,
    );

    if (result == null || result.files.isEmpty) return null;

    // If multiple, you can return a list of files instead
    final path = result.files.first.path;
    if (path != null) return File(path);

    return null;
  } catch (e) {
    print("Error picking file: $e");
    return null;
  }
}

class MediaPicker extends StatelessWidget {
  final String? mediaType; // Determines whether to show image or video options

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
              onTap: () async {
                Navigator.pop(context, ImageSource.gallery);
              },
            ),
            16.ph.spaceVertical,
            ListTile(
              leading: Icon(Icons.camera_alt, color: Colors.green),
              title: Text("Camera"),
              onTap: () async {
                Navigator.pop(context, ImageSource.camera);
              },
            ),
          ] else if (mediaType == 'video') ...[
            ListTile(
              leading: Icon(Icons.video_library, color: Colors.red),
              title: Text("Gallery"),
              onTap: () async {
                final xFile = await ImagePicker().pickVideo(
                  source: ImageSource.gallery,
                );
                if (xFile != null) {
                  Navigator.pop(context, File(xFile.path));
                } else {
                  Navigator.pop(context, null);
                }
              },
            ),
            16.ph.spaceVertical,
            ListTile(
              leading: Icon(Icons.videocam, color: Colors.purple),
              title: Text("Camera"),
              onTap: () async {
                final xFile = await ImagePicker().pickVideo(
                  source: ImageSource.camera,
                );
                if (xFile != null) {
                  Navigator.pop(context, File(xFile.path));
                } else {
                  Navigator.pop(context, null);
                }
              },
            ),
          ],
        ],
      ),
    );
  }
}
