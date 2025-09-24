import 'package:aura_real/aura_real.dart';
import 'package:video_compress/video_compress.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart'; // Assuming you import this for lookupMimeType

class AddPostProvider extends ChangeNotifier {
  final TextEditingController textController = TextEditingController();
  File? selectedMedia; // Handles both image and video
  VideoPlayerController? videoController; // For video playback
  bool loader = false;
  final ImagePicker _picker = ImagePicker();
  final List<String> selectedHashtags = [];

  AddPostProvider() {
    textController.addListener(() {
      notifyListeners();
    });
  }

  // Toggle hashtag selection
  void toggleHashtag(String tag) {
    if (selectedHashtags.contains(tag)) {
      selectedHashtags.remove(tag);
    } else {
      selectedHashtags.add(tag);
    }
    notifyListeners();
  }

  Future<void> pickMedia() async {
    try {
      final File? mediaFile = await openMediaPicker(
        navigatorKey.currentContext!,
      );
      if (mediaFile != null) {
        final mimeType = lookupMimeType(mediaFile.path);
        if (mimeType != null && mimeType.startsWith('video/')) {
          selectedMedia = mediaFile;
          videoController?.dispose();
          videoController = VideoPlayerController.file(selectedMedia!)
            ..initialize().then((_) {
              notifyListeners();
            });
        } else {
          selectedMedia = mediaFile;
          videoController?.dispose();
          videoController = null;
        }
        notifyListeners();
      }
    } catch (e) {
      print('Error picking media: $e');
    }
  }

  bool canPublish() {
    final isTextValid = textController.text.trim().isNotEmpty;
    final hasMedia = selectedMedia != null;
    print("textController.text====== ${textController.text}");
    print("selectedMedia ====== $selectedMedia");
    print(
      "canPublish result ====== $isTextValid && $hasMedia = ${isTextValid && hasMedia}",
    );
    return isTextValid && hasMedia;
  }

  /// Reset form fields
  void _resetForm() {
    textController.clear();
    selectedMedia = null;
    videoController?.dispose();
    videoController = null;
    selectedHashtags.clear();
    notifyListeners();
  }

  /// Create Post API
  Future<bool> createPostAPI(BuildContext context) async {
    if (!canPublish()) {
      print("Cannot publish: Validation failed");
      showErrorMsg("Please add text and media to publish.");
      return false;
    }
    if (userData == null || userData?.id == null) {
      print("Cannot publish: User data or ID is null");
      showErrorMsg("User data is missing. Please log in again.");
      return false;
    }

    loader = true;
    notifyListeners();

    var latitude = PrefService.getDouble(PrefKeys.latitude);
    var longitude = PrefService.getDouble(PrefKeys.longitude);
    var locationId = PrefService.getString(PrefKeys.locationId);

    String? postImg;
    String? postVideo;

    final mimeType = lookupMimeType(selectedMedia!.path);

    if (mimeType != null && mimeType.startsWith('video/')) {
      final compressed = await VideoCompress.compressVideo(
        selectedMedia!.path,
        quality: VideoQuality.MediumQuality,
        deleteOrigin: false,
      );

      if (compressed != null && compressed.file != null) {
        final file = compressed.file!;
        final sizeInBytes = await file.length();
        final sizeInMB = sizeInBytes / (1024 * 1024);

        if (sizeInMB <= 2) {
          postVideo = file.path;
        } else {
          print(
            "Video still larger than 2 MB (${sizeInMB.toStringAsFixed(2)} MB)",
          );
          showErrorMsg(
            "Video is too large (${sizeInMB.toStringAsFixed(2)} MB). Max size is 2 MB.",
          );
          loader = false;
          notifyListeners();
          return false;
        }
      } else {
        print("Video compression failed");
        showErrorMsg("Video compression failed. Please try again.");
        loader = false;
        notifyListeners();
        return false;
      }
    } else {
      postImg = selectedMedia!.path;
    }

    final result = await PostAPI.createPostAPI(
      longitude: longitude,
      latitude: latitude,
      content: textController.text,
      locationId: locationId,
      selectedHashtags: selectedHashtags,
      postImg: postImg ?? '',
      postVideo: postVideo ?? "",
    );

    loader = false;

    if (result != null) {
      print("Post created successfully");
      if (context.mounted) {
        Navigator.pop(context, true); // Signal success
      }
      _resetForm();
      return true;
    } else {
      print("Failed to create post. Keeping selectedMedia for retry.");
      showErrorMsg("Failed to create post. Please try again.");
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    textController.dispose();
    videoController?.dispose();
    super.dispose();
  }

  /// Helper to show error messages
  void showErrorMsg(String message) {
    if (navigatorKey.currentContext != null) {
      ScaffoldMessenger.of(
        navigatorKey.currentContext!,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
