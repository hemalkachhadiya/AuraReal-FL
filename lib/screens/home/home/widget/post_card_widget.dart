import 'package:aura_real/apis/model/post_model.dart';
import 'package:aura_real/aura_real.dart';
import 'package:aura_real/screens/home/home/widget/star_rates_widget.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback onTap;

  const PostCard({super.key, required this.post, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final double postRating = post.postRating as double;
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
                    child: CachedImage(post.userId!.profile!=null?
                      EndPoints.domain +
                          post.userId!.profile!.profileImage.toString():"",
                    ),
                  ),
                ),
                8.pw.spaceHorizontal,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      post.userId?.fullName ?? "Unknown",
                      style: styleW600S12,
                    ),
                    4.ph.spaceVertical,
                    Row(
                      children: [
                        SvgAsset(
                          imagePath: AssetRes.starFillIcon,
                          height: 16,
                          width: 16,
                          color: ColorRes.yellowColor,
                        ),
                        2.pw.spaceHorizontal,
                        Text(post.postRating.toString(), style: styleW600S12),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          CachedImage(
            EndPoints.domain + post.postImage.toString().toBackslashPath(),
            height: 390.ph,
            fit: BoxFit.cover,
          ),
          10.ph.spaceVertical,
          // Rating and Actions
          InkWell(
            onTap: () {
              showRatingDialog(context);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      StarRatingWidget(
                        rating: postRating,
                        // Use the extension to convert rating to star count                      size: 20,
                        activeColor: ColorRes.primaryColor,
                        inactiveColor: ColorRes.primaryColor,
                      ),
                      10.pw.spaceHorizontal,
                      Text(post.postRating.toString(), style: styleW700S16),
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
                  Text(context.l10n?.rateThisPost ?? "", style: styleW400S13),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showRatingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Rate this Post'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              20.ph.spaceVertical,
              // StarRatingWidget(
              //   rating: 5,
              //   // Use the extension to convert rating to star count                      size: 20,
              //   activeColor: ColorRes.primaryColor,
              //   inactiveColor: ColorRes.primaryColor,
              // ),
              Rating2Screen(),

              // InteractiveStarRating(
              //   initialRating: 5,
              //   onRatingChanged: (rating) {
              //     // Provider.of<PostsProvider>(
              //     //   context,
              //     //   listen: false,
              //     // ).ratePost(post.id, rating);
              //     Navigator.of(context).pop();
              //     ScaffoldMessenger.of(context).showSnackBar(
              //       SnackBar(
              //         content: Text('Rated $rating stars!'),
              //         duration: const Duration(seconds: 2),
              //       ),
              //     );
              //   },
              // ),
            ],
          ),
          actions: [
            SubmitButton(
              onTap: () {},
              title: context.l10n?.submit ?? "",
              height: 42.ph,
              raduis: 15,
            ),
          ],
        );
      },
    );
  }
}
