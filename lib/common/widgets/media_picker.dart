import 'package:aura_real/aura_real.dart';

Future<File?> openMediaPicker(BuildContext context) async {
  final result = await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
    ),
    builder: (BuildContext context) {
      return MediaPicker();
    },
  );

  if (result is ImageSource) {
    if (result == ImageSource.camera && context.mounted) {
      final canOpenCamera = await checkCameraPermission(context);
      if (!canOpenCamera) return null;
    }
    final xFile = await ImagePicker().pickImage(source: result);
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
  return null;
}

class MediaPicker extends StatelessWidget {
  const MediaPicker({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.w,
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Select Image From",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
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
        ],
      ),
    );
  }
}
