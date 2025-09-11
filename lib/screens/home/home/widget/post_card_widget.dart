import 'package:aura_real/apis/model/post_model.dart';
import 'package:aura_real/aura_real.dart';
import 'package:aura_real/screens/home/home/widget/ratins_widget.dart'; // Assuming this is StarRatingWidget

class PostCard extends StatefulWidget {
  // Changed to Stateful for local updates
  final PostModel post;
  final VoidCallback onTap;
  final bool? loading;
  final Function(double rating)? onRatingSubmitted;

  const PostCard({
    super.key,
    required this.post,
    required this.onTap,
    this.onRatingSubmitted,
    this.loading = false,
  });

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late double _localRating;

  @override
  void initState() {
    super.initState();
    _localRating = widget.post.postRating ?? 0.0;
  }

  @override
  void didUpdateWidget(PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post.postRating != widget.post.postRating) {
      _localRating = widget.post.postRating ?? 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
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
                      _getProfileImageUrl(),
                      fit: BoxFit.cover,

                      // Add error placeholder if needed
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      widget.post.userId?.fullName ?? "Unknown",
                      style: styleW600S12,
                    ),
                    const SizedBox(height: 4),
                    if (_localRating > 0) ...[
                      // Only show if rated
                      Row(
                        children: [
                          SvgAsset(
                            imagePath: AssetRes.starFillIcon,
                            height: 16,
                            width: 16,
                            color: ColorRes.yellowColor,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            widget.post.userId?.profile?.ratingsAvg
                                    .toString() ??
                                "0",
                            style: styleW600S12,
                          ), // Fixed to 1 decimal
                        ],
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          CachedImage(
            EndPoints.domain + (widget.post.postImage?.toBackslashPath() ?? ''),
            height: 390.0,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 10),
          // Rating and Actions
          InkWell(
            onTap: () async {
              if (widget.loading == true) return; // Prevent if loading
              print('Rating InkWell tapped - opening dialog');
              final selectedRating = await showRatingDialog(
                context,
                widget.post,
                loading: widget.loading,

                onSubmit: () {
                  print('Submit callback executed from PostCard');
                  // Add API call here if needed
                },
              );
              print('Dialog closed with rating: $selectedRating');
              if (selectedRating != null) {
                setState(() {
                  _localRating = selectedRating; // Optimistic local update
                });
                if (widget.onRatingSubmitted != null) {
                  widget.onRatingSubmitted!(selectedRating);
                }
              }
            },

            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      StarRatingWidget(
                        rating: _localRating.toStarRating(),
                        // Use local for immediate feedback
                        size: 20,
                        activeColor: ColorRes.primaryColor,
                        inactiveColor: ColorRes.primaryColor.withOpacity(
                          0.3,
                        ), // Faded inactive
                      ),
                      const SizedBox(width: 10),
                      Text(
                        widget.post.postRating!.toStarCount().toStringAsFixed(
                          1,
                        ),
                        style: styleW700S16,
                      ),
                      const Spacer(),
                      SvgAsset(
                        imagePath: AssetRes.commentIcon,
                        height: 22,
                        width: 22,
                        color: ColorRes.primaryColor,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        (widget.post.commentsCount ?? 0).toString(),
                        style: styleW700S16,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (_localRating == 0)
                    Text(
                      context.l10n?.rateThisPost ?? "Rate this post",
                      style: styleW400S13.copyWith(
                        color: ColorRes.primaryColor,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getProfileImageUrl() {
    if (widget.post.userId?.profile?.profileImage == null) return '';
    final userId = widget.post.userId;
    if (userId == null || userId.runtimeType == String) return '';
    return EndPoints.domain + userId.profile!.profileImage.toString();
  }
}
