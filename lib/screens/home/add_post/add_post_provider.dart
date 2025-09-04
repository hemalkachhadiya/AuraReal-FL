import 'package:aura_real/aura_real.dart';
import 'package:image_picker/image_picker.dart';

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
    return textController.text.trim().isNotEmpty || selectedImage != null;
  }

  void publishPost(BuildContext context) {
    if (!canPublish()) return;

    print('Publishing post with text: ${textController.text}');
    print('Selected hashtags: $selectedHashtags');
    if (selectedImage != null) {
      print('With image: ${selectedImage!.path}');
    }
    if (context.mounted) {
      context.navigator.pop();
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
