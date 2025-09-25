import 'package:aura_real/aura_real.dart';

class PostCard extends StatefulWidget {
  final PostModel post;
  final VoidCallback onTap;
  final VoidCallback onTapPost;
  final bool? loading;
  final Function(double rating)? onRatingSubmitted;
  final Function(String rating)? onCommentSubmitted;

  const PostCard({
    super.key,
    required this.post,
    required this.onTap,
    this.onRatingSubmitted,
    this.onCommentSubmitted,
    this.loading = false,
    required this.onTapPost,
  });

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late double _localRawRating; // Store rating in raw format (0.0–0.1)
  int _localCommentCount = 0;
  String? _commentString;
  bool _isCommentTapped = false; // Track comment tap state

  @override
  void initState() {
    super.initState();
    _localRawRating = widget.post.postRating?.toRawRating() ?? 0.0; // Use raw rating
    _localCommentCount = widget.post.commentsCount ?? 0;
    _commentString = widget.post.content ?? "";
    print("widget.post.postRating (raw) === $_localRawRating");
  }

  @override
  void didUpdateWidget(PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post.postRating != widget.post.postRating) {
      setState(() {
        _localRawRating = widget.post.postRating?.toRawRating() ?? 0.0;
      });
    }
    if (oldWidget.post.commentsCount != widget.post.commentsCount) {
      _localCommentCount = widget.post.commentsCount ?? 0;
    }
    if (oldWidget.post.content != widget.post.content) {
      _commentString = widget.post.content ?? "";
    }
  }

  void _handleCommentSubmitted(String comment) async {
    if (comment.trim().isEmpty) return;
    widget.onCommentSubmitted?.call(comment);
    setState(() {
      _localCommentCount += 1; // Update comment count locally
    });
  }

  void _handleRatingSubmitted(double starRating) {
    setState(() {
      _localRawRating = starRating.toRawRating(); // Convert stars (0–5) to raw (0.0–0.1)
    });
    print("Star Rating -- ${_localRawRating}");
    widget.onRatingSubmitted?.call(_localRawRating); // Pass raw rating
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// Profile Section
        InkWell(
          onTap: widget.onTap,
          child: Padding(
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
                    if (_localRawRating > 0)
                      Row(
                        children: [
                          SvgAsset(
                            imagePath: AssetRes.starFillIcon,
                            color: ColorRes.yellowColor,
                            height: 16.ph,
                            width: 16.pw,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.post.userId?.profile?.ratingsAvg!
                                .toStringAsFixed(2) ??
                                "0.0",
                            style: styleW600S12,
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),

        /// Post Media
        buildMedia(context, widget.post, widget.onTapPost),

        /// Space
        10.ph.spaceVertical,

        /// Rating & Comment Row
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// Rate Section
              InkWell(
                onTap: () async {
                  if (widget.loading == true) return;
                  final selectedRating = await showRatingDialog(
                    context,
                    widget.post,
                    loading: widget.loading,
                    onSubmit: () {
                      print("Rating submitted for post ${widget.post.id}");
                    },
                  );
                  if (selectedRating != null) {
                    _handleRatingSubmitted(selectedRating); // Handle star rating (0–5)
                  }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        StarRatingWidget(
                          rating: _localRawRating.toStarRating(),
                          size: 20,
                          activeColor: ColorRes.primaryColor,
                          inactiveColor: ColorRes.primaryColor,
                        ),
                        10.pw.spaceHorizontal,
                        Text(
                          widget.post.postRating!.toStringAsFixed(2),
                          style: styleW700S16,
                        ),
                      ],
                    ),
                    if (_localRawRating == 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          context.l10n?.rateThisPost ?? "Rate this post",
                          style: styleW400S13.copyWith(
                            color: ColorRes.primaryColor,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              /// Comment Section
              InkWell(
                onTap: () async {
                  setState(() {
                    _isCommentTapped = true; // Set flag when comment is tapped
                  });
                  print("Opening comment bottom sheet for post ${widget.post.id}");
                  try {
                    final postsProvider = Provider.of<PostsProvider>(
                      context,
                      listen: false,
                    );
                    await postsProvider.getAllCommentListAPI(
                      widget.post.id!,
                      showLoader: true,
                      resetData: true,
                    );
                    print(
                      "Comments fetched: ${postsProvider.commentListResponse.length}",
                    );
                    await openCustomDraggableBottomSheet(
                      context,
                      title: context.l10n?.comments ?? "Comments",
                      customChild: ChangeNotifierProvider.value(
                        value: postsProvider,
                        child: Consumer<PostsProvider>(
                          builder: (context, provider, _) {
                            return CommentsWidget(
                              post: widget.post,
                              comments: provider.commentListResponse,
                              onCommentSubmitted: (val) async {
                                print("Submitting comment: $val");
                                _handleCommentSubmitted(val);
                                print("Comment submitted successfully");
                              },
                            );
                          },
                        ),
                      ),
                      showButtons: false,
                      borderRadius: 20,
                      padding: const EdgeInsets.all(0),
                    );
                    print("Bottom sheet opened successfully");
                  } catch (e) {
                    print("Error opening comment bottom sheet: $e");
                  }
                },
                child: Row(
                  children: [
                    SvgAsset(
                      imagePath: AssetRes.commentIcon,
                      height: 22,
                      width: 22,
                      color: ColorRes.primaryColor,
                    ),
                    const SizedBox(width: 10),
                    Text(_localCommentCount.toString(), style: styleW700S16),
                  ],
                ),
              ),
            ],
          ),
        ),

        /// Space
        10.ph.spaceVertical,
      ],
    );
  }

  Widget buildMedia(
      BuildContext context,
      PostModel post,
      VoidCallback onTapPost,
      ) {
    if (post.media != null && post.media?.type == 1) {
      final videoUrl = EndPoints.domain + post.media!.url!.toBackslashPath();
      return GestureDetector(
        onTap: onTapPost,
        child: FutureBuilder<File?>(
          future: generateVideoThumbnail(videoUrl),
          builder: (context, snapshot) {
            if (_isCommentTapped) {
              // Skip shimmer if comment is tapped
              if (!snapshot.hasData || snapshot.data == null) {
                return Container(
                  height: 390,
                  width: double.infinity,
                  color: Colors.black,
                  child: const Icon(
                    Icons.play_circle_fill,
                    color: Colors.white,
                    size: 60,
                  ),
                );
              }
              return Stack(
                alignment: Alignment.center,
                children: [
                  Image.file(
                    snapshot.data!,
                    height: 390,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  const Icon(
                    Icons.play_circle_fill,
                    color: Colors.white,
                    size: 60,
                  ),
                ],
              );
            }
            // Show shimmer during loading if comment is not tapped
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CustomShimmer(height: 390, width: double.infinity);
            }
            if (!snapshot.hasData || snapshot.data == null) {
              return Container(
                height: 390,
                width: double.infinity,
                color: Colors.black,
                child: const Icon(
                  Icons.play_circle_fill,
                  color: Colors.white,
                  size: 60,
                ),
              );
            }
            return Stack(
              alignment: Alignment.center,
              children: [
                Image.file(
                  snapshot.data!,
                  height: 390,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                const Icon(
                  Icons.play_circle_fill,
                  color: Colors.white,
                  size: 60,
                ),
              ],
            );
          },
        ),
      );
    } else {
      final imageUrl =
      post.media?.url != null
          ? EndPoints.domain + post.media!.url!.toBackslashPath()
          : "";
      return GestureDetector(
        onTap: onTapPost,
        child: CachedImage(imageUrl, height: 390.0, fit: BoxFit.cover),
      );
    }
  }

  String _getProfileImageUrl() {
    if (widget.post.userId?.profile?.profileImage == null) return '';
    final userId = widget.post.userId;
    if (userId == null || userId.runtimeType == String) return '';
    return EndPoints.domain +
        userId.profile!.profileImage!.toBackslashPath().toString();
  }
}