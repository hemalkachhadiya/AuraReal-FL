import 'package:aura_real/aura_real.dart';

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
              floatingActionButton: FloatingActionButton(
                onPressed:
                    () => context.navigator.pushNamed(AddPostScreen.routeName),
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
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(color: ColorRes.white),
                          child: CustomListView(
                            controller: scrollController,
                            // Add ScrollController
                            itemCount:
                                provider.loader
                                    ? 0
                                    : provider.postListResponse.length + 1,
                            onRefresh:
                                () =>
                                    provider.getAllPostListAPI(resetData: true),
                            emptyWidget: UnKnownScreen(),
                            showEmptyWidget:
                                !provider.loader &&
                                provider.postListResponse.isEmpty,
                            separatorBuilder:
                                (ctx, ind) => Container(
                                  height: 1.ph,
                                  width: 100.pw,
                                  color: ColorRes.black.withValues(alpha: 0.1),
                                ),
                            itemBuilder: (context, index) {
                              if (index >= provider.postListResponse.length) {
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
                                  // provider.getAllPostListAPI();
                                }
                                return SizedBox(
                                  height: 100.ph,
                                  child: const SmallLoader(),
                                );
                              }

                              return PostCard(
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
                                          provider.postListResponse[index].id,
                                      rating: rating.toString(),
                                    );
                                  } else {
                                    provider.updateRatePostAPI(
                                      context,
                                      postId:
                                          provider.postListResponse[index].id,
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
                                    arguments: provider.postListResponse[index],
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                      25.ph.spaceVertical,
                    ],
                  ),
                ),
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
}
