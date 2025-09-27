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
  late double _localRawRating;
  int _localCommentCount = 0;
  String? _commentString;
  bool _isCommentTapped = false;

  @override
  void initState() {
    super.initState();
    // Initialize _localRawRating from API rating
    _updateLocalRating(widget.post.postRating ?? 0.0);
    _localCommentCount = widget.post.commentsCount ?? 0;
    _commentString = widget.post.content ?? "";

    print("=== PostCard Debug ===");
    print("API returned: ${widget.post.postRating}");
    print("Storing as raw rating: $_localRawRating");
    print("Will display: ${_localRawRating.toStarRating()} filled stars");
    print("Will show text: ${_localRawRating.toStringAsFixed(2)}");
    print("===================");
  }

  @override
  void didUpdateWidget(PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post.postRating != widget.post.postRating) {
      setState(() {
        // Apply the same conversion logic as initState
        _updateLocalRating(widget.post.postRating ?? 0.0);
      });
    }
    if (oldWidget.post.commentsCount != widget.post.commentsCount) {
      _localCommentCount = widget.post.commentsCount ?? 0;
    }
    if (oldWidget.post.content != widget.post.content) {
      _commentString = widget.post.content ?? "";
    }
  }

  // Helper method to handle rating conversion
  void _updateLocalRating(double apiRating) {
    if (apiRating >= 1.0) {
      // If API returned integer format (e.g., 2.0), convert to decimal (e.g., 0.04)
      _localRawRating = apiRating.toRawRating();
    } else {
      // If API returned decimal format (e.g., 0.04), use as is
      _localRawRating = apiRating;
    }
  }

  void _handleCommentSubmitted(String comment) async {
    if (comment.trim().isEmpty) return;
    widget.onCommentSubmitted?.call(comment);
    setState(() {
      _localCommentCount += 1;
    });
  }

  void _handleRatingSubmitted(double starRating) {
    // starRating comes as 3.0 (from popup)
    // Convert to raw decimal for display (0.02, 0.04, 0.06, 0.08, 0.10)
    double rawRating = starRating.toRawRating();
    // Convert to integer for API (1, 2, 3, 4, 5)
    int integerRating = starRating.round();

    setState(() {
      _localRawRating = rawRating; // Store as decimal (e.g., 0.06)
    });

    print("=== Rating Submission Debug ===");
    print("Star Rating selected: $starRating stars");
    print("Sending to API: $integerRating (integer)");
    print("Storing for display: $rawRating (decimal)");
    print("Will show: ${rawRating.toStarRating()} filled stars");
    print("=============================");

    // Send integer to API
    widget.onRatingSubmitted?.call(integerRating.toDouble());
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
                    if (widget.post.userId?.profile?.ratingsAvg != null &&
                        (widget.post.userId?.profile?.ratingsAvg ?? 0) > 0)
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
                            widget.post.userId!.profile!.ratingsAvg!
                                .toStringAsFixed(2),
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
                    widget.post.postRating ?? 0.0,
                    loading: widget.loading,
                    onSubmit: () {
                      print("Rating submitted for post ${widget.post.id}");
                    },
                  );
                  if (selectedRating != null) {
                    _handleRatingSubmitted(selectedRating);
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
                          _localRawRating.toStringAsFixed(2),
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
                  if (widget.loading == true) return;
                  setState(() {
                    _isCommentTapped = true;
                  });
                  print(
                    "Opening comment bottom sheet for post ${widget.post.id}",
                  );
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
                      customChild: Container(
                        child: ChangeNotifierProvider.value(
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
