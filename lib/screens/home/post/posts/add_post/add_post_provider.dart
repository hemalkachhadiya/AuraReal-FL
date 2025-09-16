import 'package:aura_real/aura_real.dart';

class AddPostProvider extends ChangeNotifier {
  final TextEditingController textController = TextEditingController();
  File? selectedImage;
  int imageWidth = 0;
  int imageHeight = 0;
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

  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        selectedImage = File(image.path);
        await _getImageDimensions();
        notifyListeners();
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _getImageDimensions() async {
    if (selectedImage != null) {
      final image = await decodeImageFromList(selectedImage!.readAsBytesSync());
      imageWidth = image.width;
      imageHeight = image.height;
    }
  }

  bool canPublish() {
    final isTextValid = textController.text.trim().isNotEmpty;
    final hasImage = selectedImage != null;
    print("textController.text====== ${textController.text}");
    print("selectedImage ====== $selectedImage");
    print(
      "canPublish result ====== $isTextValid && $hasImage = ${isTextValid && hasImage}",
    );
    return isTextValid && hasImage;
  }

  ///Create Post PI
  Future<void> createPostAPI() async {
    if (!canPublish()) return;
    if (userData == null || userData?.id == null) return;
    loader = true;
    notifyListeners();
    var latitude = PrefService.getDouble(PrefKeys.latitude);
    var longitude = PrefService.getDouble(PrefKeys.longitude);

    var locationId = PrefService.getString(PrefKeys.locationId);

    final result = await PostAPI.createPostAPI(
      longitude: longitude,
      latitude: latitude,
      content: textController.text,
      locationId: locationId,
      postImg: selectedImage!.path,
      selectedHashtags: selectedHashtags,
    );
    if (result != null) {
      navigatorKey.currentState?.context.navigator.pop();

      notifyListeners();
    }
    loader = false;
    textController.clear();
    selectedImage = null;
    imageWidth = 0;
    imageHeight = 0;
    selectedHashtags.clear();
    notifyListeners();
  }

  void publishPost(BuildContext context) {
    if (!canPublish()) return;

    if (selectedImage != null) {
      print('With image: ${selectedImage!.path}');
    }
    if (context.mounted) {
      context.navigator.pop();
      final postsProvider = Provider.of<PostsProvider>(context, listen: false);
      postsProvider.getAllPostListAPI(showLoader: true, resetData: true);
    }
    // Reset
    textController.clear();
    selectedImage = null;
    imageWidth = 0;
    imageHeight = 0;
    selectedHashtags.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }
}
