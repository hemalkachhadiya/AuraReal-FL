import 'package:aura_real/apis/model/post_model.dart';
import 'package:aura_real/aura_real.dart';

class PostCard extends StatefulWidget {
  // Changed to Stateful for local updates
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
  late double _localRating;
  late String _commentString;

  @override
  void initState() {
    super.initState();
    _localRating = widget.post.postRating ?? 0.0;
    _commentString = widget.post.content ?? "";
  }

  @override
  void didUpdateWidget(PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post.postRating != widget.post.postRating) {
      _localRating = widget.post.postRating ?? 0.0;
    }
    if (oldWidget.post.content != widget.post.content) {
      _commentString = widget.post.content ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final postsProvider = Provider.of<PostsProvider>(context, listen: false);
    return Column(
      children: [
        ///Profile
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
        ),

        ///Post Image / Video
        buildMedia(context, widget.post, widget.onTapPost),
        // InkWell(
        //   onTap: widget.onTapPost,
        //   child: CachedImage(
        //     EndPoints.domain + (widget.post.postImage?.toBackslashPath() ?? ''),
        //     height: 390.0,
        //     fit: BoxFit.cover,
        //   ),
        // ),

        ///Space
        10.ph.spaceVertical,

        /// Rating and Message
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),

          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ///Rate Section
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        StarRatingWidget(
                          rating: _localRating.toStarRating(),
                          // Use local for immediate feedback
                          size: 20,
                          activeColor: ColorRes.primaryColor,
                          inactiveColor:
                              ColorRes.primaryColor, // Faded inactive
                        ),
                        10.pw.spaceHorizontal,
                        Text(
                          widget.post.postRating.toString(),
                          style: styleW700S16,
                        ),
                      ],
                    ),

                    10.ph.spaceVertical,
                    if (_localRating == 0)
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          context.l10n?.rateThisPost ?? "Rate this post",
                          style: styleW400S13.copyWith(
                            color: ColorRes.primaryColor,
                          ),
                          textAlign: TextAlign.start,
                        ),
                      ),
                  ],
                ),
              ),

              ///Comment Section
              InkWell(
                onTap: () async {
                  final postsProvider = Provider.of<PostsProvider>(
                    context,
                    listen: false,
                  );

                  final scrollProvider = Provider.of<PostsProvider>(
                    context,
                    listen: false,
                  );
                  scrollProvider.saveScrollPosition(
                    context
                            .findAncestorStateOfType<ScrollableState>()
                            ?.position
                            .pixels ??
                        0.0,
                  );

                  await postsProvider.getAllCommentListAPI(
                    widget.post.id!,
                    showLoader: true,
                    resetData: true,
                  );
                  print(
                    "Comment list ===== ${postsProvider.commentListResponse.length}",
                  );
                  openCustomDraggableBottomSheet(
                    context,
                    title: context.l10n?.comments ?? "",
                    customChild: CommentsWidget(
                      post: widget.post,
                      comments: postsProvider.commentListResponse,
                      onCommentSubmitted: (val) async {
                        print("val -------- ${val}");
                        if (widget.onCommentSubmitted != null) {
                          widget.onCommentSubmitted!(val);
                        }
                        await postsProvider.commentPostAPI(
                          context,
                          postId: widget.post.id,
                          content: val,
                        );

                        navigatorKey.currentState?.context.navigator.pop(
                          context,
                        );

                        // await postsProvider.getAllCommentListAPI(
                        //   widget.post.id!,
                        //   showLoader: true,
                        //   resetData: true,
                        // );
                      },
                    ),
                    showButtons: false,
                    borderRadius: 20,
                    padding: const EdgeInsets.all(0),
                  );

                  /// Restore scroll position after operation
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    final scrollableState =
                        context.findAncestorStateOfType<ScrollableState>();
                    if (scrollableState != null) {
                      scrollableState.position.jumpTo(
                        scrollProvider.scrollPosition,
                      );
                    }
                  });
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
                    Text(
                      (widget.post.commentsCount ?? 0).toString(),
                      style: styleW700S16,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        ///Space
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
      // 🎬 Video post
      final videoUrl = EndPoints.domain + post.media!.url!.toBackslashPath();
      return GestureDetector(
        onTap: onTapPost,
        child: FutureBuilder<File?>(
          future: generateVideoThumbnail(videoUrl),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                height: 390,
                color: Colors.black,
                child: const Center(child: CircularProgressIndicator()),
              );
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
      // 🖼 Image post
      final imageUrl =
          post.media?.url != null
              ? (EndPoints.domain + post.media!.url!.toBackslashPath())
              : "";

      return GestureDetector(
        onTap: onTapPost,
        child: CachedImage(imageUrl, height: 390.0, fit: BoxFit.cover),
      );
    }
  }

  // Widget buildMedia(
  //   BuildContext context,
  //   PostModel post,
  //   VoidCallback onTapPost,
  // ) {
  //   if (post.media != null && post.media?.type == 1) {
  //     // Video
  //     return GestureDetector(
  //       onTap: onTapPost /* () {
  //         // open video player
  //         // Navigator.push(
  //         //   context,
  //         //   MaterialPageRoute(
  //         //     builder: (_) => VideoPlayerScreen(url: post.media!.url ?? ""),
  //         //   ),
  //         // );
  //       }*/,
  //       child: Container(
  //         height: 390,
  //         color: Colors.black,
  //         child: Center(
  //           child: Icon(Icons.play_circle_fill, color: Colors.white, size: 50),
  //         ),
  //       ),
  //     );
  //   } else {
  //     // Image (either media.type == 0 OR fallback to postImage)
  //     final imageUrl =
  //         post.media?.url != null
  //             ? (EndPoints.domain + post.media!.url!.toBackslashPath())
  //             : "";
  //     // print("image url========== ${EndPoints.domain + widget.post.postImage!.toBackslashPath()}");
  //     return GestureDetector(
  //       onTap: onTapPost /*() {
  //         // open image in fullscreen
  //         // Navigator.push(
  //         //   context,
  //         //   MaterialPageRoute(
  //         //     builder: (_) => ImagePreviewScreen(imageUrl: imageUrl),
  //         //   ),
  //         // );
  //       }*/,
  //       child: CachedImage(
  //         // EndPoints.domain + (widget.post.postImage?.toBackslashPath() ?? ''),
  //         imageUrl,
  //         height: 390.0,
  //         fit: BoxFit.cover,
  //       ),
  //       /*Image.network(
  //         imageUrl,
  //         height: 390,
  //         width: double.infinity,
  //         fit: BoxFit.cover,
  //         errorBuilder: (c, e, s) => const Icon(Icons.broken_image),
  //       )*/
  //     );
  //   }
  // }

  String _getProfileImageUrl() {
    if (widget.post.userId?.profile?.profileImage == null) return '';
    final userId = widget.post.userId;
    if (userId == null || userId.runtimeType == String) return '';
    return EndPoints.domain +
        userId.profile!.profileImage!.toBackslashPath().toString();
  }
}
