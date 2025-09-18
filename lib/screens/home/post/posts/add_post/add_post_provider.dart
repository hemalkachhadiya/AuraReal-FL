import 'package:aura_real/aura_real.dart';
import 'package:http/http.dart'
    as http; // Ensure http is imported for MediaType
import 'package:mime/mime.dart'; // Ensure mime is imported for lookupMimeType

class AddPostProvider extends ChangeNotifier {
  final TextEditingController textController = TextEditingController();
  File? selectedMedia; // Handles both image and video
  VideoPlayerController? videoController; // For video playback
  bool loader = false;
  final ImagePicker _picker = ImagePicker();

  // 👉 Track selected hashtags
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
        // Determine if it's a video or image based on file extension or mime type
        final mimeType = lookupMimeType(mediaFile.path);
        if (mimeType != null && mimeType.startsWith('video/')) {
          selectedMedia = mediaFile;
          videoController?.dispose();
          videoController = VideoPlayerController.file(selectedMedia!)
            ..initialize().then((_) {
              notifyListeners(); // Notify after video is initialized
            });
        } else {
          selectedMedia = mediaFile;
          videoController?.dispose();
          videoController = null; // Clear video controller for images
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

  /// Create Post API
  Future<void> createPostAPI() async {
    if (!canPublish()) {
      print("Cannot publish: Validation failed");
      return;
    }
    if (userData == null || userData?.id == null) {
      print("Cannot publish: User data or ID is null");
      return;
    }
    loader = true;
    notifyListeners();
    var latitude = PrefService.getDouble(PrefKeys.latitude);
    var longitude = PrefService.getDouble(PrefKeys.longitude);
    var locationId = PrefService.getString(PrefKeys.locationId);

    // Determine if selectedMedia is an image or video
    String? postImg;
    String? postVideo;
    final mimeType = lookupMimeType(selectedMedia!.path);
    if (mimeType != null && mimeType.startsWith('video/')) {
      postVideo = selectedMedia!.path;
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
      // Pass empty string if no image
      postVideo: postVideo ?? "", // Pass video path or null
    );
    if (result != null) {
      print("Post created successfully");
      navigatorKey.currentState?.context.navigator.pop();

      notifyListeners();
    } else {
      print("Failed to create post. Keeping selectedMedia for retry.");
      // Do not clear selectedMedia on failure to allow retry
    }
    loader = false;
    // Only clear on success or manual reset
    if (result != null) {
      textController.clear();
      selectedMedia = null;
      videoController?.dispose();
      videoController = null;
      selectedHashtags.clear();
    }
    notifyListeners();
  }

  void publishPost(BuildContext context) {
    if (!canPublish()) {
      print("Cannot publish: Validation failed");
      return;
    }

    if (selectedMedia != null) {
      print('With media: ${selectedMedia!.path}');
    }
    if (context.mounted) {
      context.navigator.pop();
      final postsProvider = Provider.of<PostsProvider>(context, listen: false);
      postsProvider.getAllPostListAPI(showLoader: true, resetData: true);
    }
    // Reset
    textController.clear();
    selectedMedia = null;
    videoController?.dispose();
    videoController = null;
    selectedHashtags.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    textController.dispose();
    videoController?.dispose();
    super.dispose();
  }
}
