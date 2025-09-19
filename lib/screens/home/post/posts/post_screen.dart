import 'package:aura_real/apis/model/post_model.dart';
import 'package:aura_real/aura_real.dart';
import 'package:aura_real/screens/home/post/posts/image_preview_screen.dart';
import 'package:aura_real/screens/home/post/posts/video_player_screen.dart';
import 'package:aura_real/screens/home/search/search_screen.dart';

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
      child: Consumer<PostsProvider>(
        builder: (context, provider, child) {
          final ScrollController scrollController = ScrollController();
          return StackedLoader(
            loading: provider.loader,
            child: Scaffold(
              backgroundColor: Theme.of(context).colorScheme.surface,
              // floatingActionButton: FloatingActionButton(
              //   onPressed:
              //       () => context.navigator.pushNamed(AddPostScreen.routeName),
              //   backgroundColor: ColorRes.primaryColor,
              //   elevation: 6.0,
              //   // Added elevation for a raised effect
              //   shape: const CircleBorder(),
              //   // Ensures a perfectly round shape
              //   child: SvgAsset(
              //     imagePath: AssetRes.addIcon,
              //     height: 20,
              //     width: 20,
              //   ),
              // ),
              body: Stack(
                children: [
                  SafeArea(
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
                                    _buildIconButton(
                                      AssetRes.searchIcon,
                                      () async {
                                        context.navigator.pushNamed(
                                          SearchScreen.routeName,
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 15),
                                    _buildIconButton(AssetRes.warnIcon, () {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
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
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(color: ColorRes.white),
                              child: CustomListView(
                                controller: scrollController,
                                padding: EdgeInsets.only(
                                  bottom: Constants.horizontalPadding+50,
                                ),
                                // Add ScrollController
                                itemCount:
                                    provider.loader
                                        ? 0
                                        : provider.postListResponse.length + 1,
                                onRefresh:
                                    () => provider.getAllPostListAPI(
                                      resetData: true,
                                    ),
                                emptyWidget: UnKnownScreen(),
                                showEmptyWidget:
                                    !provider.loader &&
                                    provider.postListResponse.isEmpty,
                                separatorBuilder:
                                    (ctx, ind) => Container(
                                      height: 1.ph,
                                      width: 100.pw,
                                      color: ColorRes.black.withValues(
                                        alpha: 0.1,
                                      ),
                                    ),
                                itemBuilder: (context, index) {
                                  if (index >=
                                      provider.postListResponse.length) {
                                    if (!provider.hasMoreData) {
                                      return Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Center(
                                          child: Text(
                                            'No more items',
                                            style: styleW500S12.copyWith(
                                              color: ColorRes.grey,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                    if (!provider.isApiCalling) {
                                      provider.getAllPostListAPI();
                                    }
                                    return SizedBox(
                                      height: 100.ph,
                                      child: const SmallLoader(),
                                    );
                                  }
                                  return PostCard(
                                    onTapPost: () {
                                      try {
                                        final post =
                                            provider.postListResponse[index];
                                        final media = post.media;

                                        // Always navigate to ImagePreviewScreen, let it handle null cases
                                        if (media?.type == 0) {
                                          // Image case
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (_) => ImagePreviewScreen(
                                                    imageUrl:
                                                        media?.url != null
                                                            ? EndPoints.domain +
                                                                media!.url!
                                                            : null,
                                                    title: post.content,
                                                  ),
                                            ),
                                          );
                                          print("Image Screen");
                                        } else if (media?.type == 1) {
                                          // Video case
                                          final videoUrl =
                                              media?.url != null
                                                  ? EndPoints.domain +
                                                      media!.url!
                                                  : null;
                                          if (videoUrl != null) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (_) => VideoPlayerScreen(
                                                      thumbnailUrl: videoUrl,
                                                      title: post.content,
                                                      url: videoUrl,
                                                    ),
                                              ),
                                            );
                                            print("Video Screen");
                                          } else {
                                            // Show error for video with no URL
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Video URL not available',
                                                ),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        } else {
                                          // Unknown media type or null media
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (_) => ImagePreviewScreen(
                                                    imageUrl: null,
                                                    // Will show empty widget
                                                    title:
                                                        post.content ??
                                                        'Post Content',
                                                  ),
                                            ),
                                          );
                                        }
                                      } catch (e, stackTrace) {
                                        print('Error in navigation: $e');
                                        print('Stack trace: $stackTrace');

                                        // Navigate to empty screen on error
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) => ImagePreviewScreen(
                                                  imageUrl: null,
                                                  title:
                                                      'Error Loading Content',
                                                ),
                                          ),
                                        );
                                      }
                                    },
                                    loading: provider.loader,
                                    onRatingSubmitted: (rate) {
                                      var rating =
                                          DoubleRatingExtension(rate).toStars();

                                      if (provider
                                              .postListResponse[index]
                                              .postRating!
                                              .toStarCount() ==
                                          0) {
                                        provider.newRatePostAPI(
                                          context,
                                          postId:
                                              provider
                                                  .postListResponse[index]
                                                  .id,
                                          rating: rating.toString(),
                                        );
                                      } else {
                                        provider.updateRatePostAPI(
                                          context,
                                          postId:
                                              provider
                                                  .postListResponse[index]
                                                  .id,
                                          rating: rating.toString(),
                                        );
                                      }
                                    },
                                    onCommentSubmitted: (val) {
                                      print("value comment ========= ${val}");
                                      // provider.commentPostAPI(
                                      //   context,
                                      //   postId: provider.postListResponse[index].id,
                                      //   content: val.toString(),
                                      // );
                                    },
                                    post: provider.postListResponse[index],
                                    onTap: () {
                                      context.navigator.pushNamed(
                                        UploadScreen.routeName,
                                        arguments:
                                            provider.postListResponse[index],
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Positioned(
                    right: Constants.horizontalPadding,
                    bottom: 100,
                    child: FloatingActionButton(
                      onPressed:
                          () => context.navigator.pushNamed(
                            AddPostScreen.routeName,
                          ),
                      backgroundColor: ColorRes.primaryColor,
                      elevation: 6.0,
                      // Added elevation for a raised effect
                      shape: const CircleBorder(),
                      // Ensures a perfectly round shape
                      child: SvgAsset(
                        imagePath: AssetRes.addIcon,
                        height: 20,
                        width: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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

  void _handleMediaNavigation(
    BuildContext context,
    PostsProvider provider,
    int index,
  ) {
    try {
      final post = provider.postListResponse[index];
      final media = post.media;

      // Validate media exists
      if (media == null) {
        showErrorMsg('No media available for this post');
        return;
      }

      // Validate URL exists
      final url = media.url;
      if (url == null || url.isEmpty) {
        showErrorMsg('Media URL not available');
        return;
      }

      final fullMediaUrl = EndPoints.domain + url;
      final postTitle = post.content ?? 'Post Media';

      // Navigate based on media type
      if (media.type == 0) {
        // Image
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => ImagePreviewScreen(
                  imageUrl: fullMediaUrl,
                  title: postTitle,
                ),
          ),
        );
      } else {
        // Video
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => VideoPlayerScreen(
                  thumbnailUrl: fullMediaUrl,
                  title: postTitle,
                  url: fullMediaUrl,
                ),
          ),
        );
      }
    } catch (e) {
      print('Error navigating to media: $e');
      showErrorMsg('Unable to open media');
    }
  }
}
