import 'package:aura_real/apis/model/post_model.dart';
import 'package:aura_real/aura_real.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback onTap;
  final VoidCallback? onRateTap;

  const PostCard({super.key, required this.post, required this.onTap, this.onRateTap});

  @override
  Widget build(BuildContext context) {
    final double postRating = post.postRating ?? 0.0;
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Constants.horizontalPadding,
              vertical: 8.0,
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
                  padding: const EdgeInsets.all(2),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: CachedImage(
                      (post.userId != null && post.userId.runtimeType != String)
                          ? EndPoints.domain +
                              post.userId!.profile!.profileImage.toString()
                          : "",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      post.userId?.fullName ?? "Unknown",
                      style: styleW600S12,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        SvgAsset(
                          imagePath: AssetRes.starFillIcon,
                          height: 16,
                          width: 16,
                          color: ColorRes.yellowColor,
                        ),
                        const SizedBox(width: 2),
                        Text(postRating.toString(), style: styleW600S12),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          CachedImage(
            EndPoints.domain + post.postImage.toString().toBackslashPath(),
            height: 390.0,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 10),
          // Rating and Actions
          InkWell(
            onTap: () {
              showRatingDialog(context, post);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      StarRatingWidget(
                        rating: postRating,
                        size: 20,
                        activeColor: ColorRes.primaryColor,
                        inactiveColor: ColorRes.primaryColor,
                      ),
                      const SizedBox(width: 10),
                      Text(postRating.toString(), style: styleW700S16),
                      const Spacer(),
                      SvgAsset(
                        imagePath: AssetRes.commentIcon,
                        height: 22,
                        width: 22,
                      ),
                      const SizedBox(width: 10),
                      Text(post.commentsCount.toString(), style: styleW700S16),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (postRating == 0)
                    Text(context.l10n?.rateThisPost ?? "", style: styleW400S13),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showRatingDialog(BuildContext context, PostModel post) {
    double selectedRating = post.postRating ?? 0.0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Rate this Post'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              StarRatingWidget(
                rating: selectedRating,
                size: 30.0,
                activeColor: Colors.amber,
                inactiveColor: Colors.grey,
                onRatingChanged: (rating) {
                  selectedRating = rating;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed:
                  selectedRating > 0
                      ? onRateTap/*() {
                        // Update rating via provider
                        // Provider.of<PostsProvider>(
                        //   context,
                        //   listen: false,
                        // ).ratePost(post.id, selectedRating);

                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Rated $selectedRating stars!'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }*/
                      : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(100, 42),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}
