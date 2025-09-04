import 'package:aura_real/aura_real.dart';
import 'package:aura_real/screens/home/add_post/add_post_screen.dart';

import 'package:aura_real/screens/home/home/widget/post_list_screen.dart';
import 'package:aura_real/screens/home/notification/notification_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const routeName = "home_screen";

  static Widget builder(BuildContext context) {
    return ChangeNotifierProvider<PostsProvider>(
      create: (c) => PostsProvider(),
      child: const HomeScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context, listen: true);
    return ChangeNotifierProvider<PostsProvider>(
      create: (context) => PostsProvider(),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.navigator.pushNamed(AddPostScreen.routeName),
          backgroundColor: ColorRes.primaryColor,
          elevation: 6.0,
          // Added elevation for a raised effect
          shape: const CircleBorder(),
          // Ensures a perfectly round shape
          child: SvgAsset(imagePath: AssetRes.addIcon, height: 20, width: 20),
        ),
        body: SafeArea(
          child: Directionality(
            textDirection:
                appProvider.locale?.languageCode == 'ar'
                    ? TextDirection.rtl
                    : TextDirection.ltr,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                8.ph.spaceVertical,
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Constants.horizontalPadding,
                  ),
                  child: Row(
                    mainAxisAlignment:
                        appProvider.locale?.languageCode == 'ar'
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                    children: [
                      SvgAsset(
                        imagePath: AssetRes.logoNameIcon,
                        width: 100,
                        height: 40,
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          _buildIconButton(AssetRes.searchIcon, () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  context.l10n?.message ?? "Search",
                                ),
                              ),
                            );
                          }),
                          const SizedBox(width: 15),
                          _buildIconButton(AssetRes.warnIcon, () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  context.l10n?.message ?? "Warning",
                                ),
                              ),
                            );

                            context.navigator.pushNamed(
                              NotificationScreen.routeName,
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
                25.ph.spaceVertical,
                Expanded(child: PostsListScreen()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(String assetPath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: ColorRes.primaryColor.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SvgAsset(imagePath: assetPath, width: 20, height: 20),
        ),
      ),
    );
  }

  void _showAddPostDialog(BuildContext context) {
    final nameController = TextEditingController();
    final imageController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            "Add New Post",
            style: TextStyle(color: ColorRes.primaryColor),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: context.l10n?.fullName ?? "User Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: ColorRes.primaryColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: imageController,
                decoration: InputDecoration(
                  labelText: "Image URL",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: ColorRes.primaryColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                context.l10n?.back ?? "Cancel",
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            Consumer<PostsProvider>(
              builder: (context, postsProvider, child) {
                return ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty &&
                        imageController.text.isNotEmpty) {
                      final newPost = PostModel(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        userName: nameController.text,
                        userProfileImage:
                            'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop&crop=face',
                        postImage: imageController.text,
                        rating: 0.0,
                        totalRatings: 0,
                        imageSize: '640 x 480',
                        createdAt: DateTime.now(),
                        userRating: 0,
                      );
                      postsProvider.addPost(newPost);
                      Navigator.of(dialogContext).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorRes.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    context.l10n?.save ?? "Add Post",
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
