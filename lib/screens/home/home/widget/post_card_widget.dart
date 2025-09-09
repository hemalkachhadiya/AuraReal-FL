import 'package:aura_real/apis/model/post_model.dart';
import 'package:aura_real/aura_real.dart';
import 'package:aura_real/screens/home/upload/upload_screen.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback onTap;

  const PostCard({super.key, required this.post, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
   onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Constants.horizontalPadding,
              vertical: 8.ph,
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    border: Border.all(color: ColorRes.primaryColor, width: 2),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  padding: EdgeInsets.all(2),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: CachedImage(post.postImage),
                  ),
                ),
                8.pw.spaceHorizontal,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      post.userId?.profile?.username ?? "",
                      style: styleW600S12,
                    ),
                    4.ph.spaceVertical,
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 16,
                          color: Color(0xFFFFD700),
                        ),
                        1.pw.spaceHorizontal,
                        Text("5", style: styleW600S12),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          AssetsImg(
            imagePath: AssetRes.post_1,
            height: 390.ph,
            fit: BoxFit.cover,
          ),
          10.ph.spaceVertical,
          // Rating and Actions
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    StarRatingWidget(
                      rating: 4,
                      size: 20,
                      activeColor: ColorRes.primaryColor,
                      inactiveColor: ColorRes.primaryColor,
                    ),
                    10.pw.spaceHorizontal,
                    Text("5", style: styleW700S16),
                    const Spacer(),

                    SvgAsset(
                      imagePath: AssetRes.commentIcon,
                      height: 22,
                      width: 22,
                    ),
                    10.pw.spaceHorizontal,
                    Text(post.commentsCount.toString(), style: styleW700S16),

                  ],
                ),
                10.ph.spaceVertical,
                InkWell(
                  onTap: () {
                    _showRatingDialog(context);
                  },
                  child: Text(
                    context.l10n?.rateThisPost ?? "",
                    style: styleW400S13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Rate this Post'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'How would you rate ${post.userId?.profile?.username}\'s post?',
              ),
              const SizedBox(height: 20),
              InteractiveStarRating(
                initialRating: 5,
                onRatingChanged: (rating) {
                  // Provider.of<PostsProvider>(
                  //   context,
                  //   listen: false,
                  // ).ratePost(post.id, rating);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Rated $rating stars!'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
