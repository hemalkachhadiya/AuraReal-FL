import 'package:aura_real/aura_real.dart';
import 'package:aura_real/screens/home/post/posts/image_preview_screen.dart';
import 'package:aura_real/screens/home/post/posts/video_player_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  static const routeName = "search_screen";

  static Widget builder(BuildContext context) {
    return ChangeNotifierProvider<PostsProvider>(
      create: (_) => PostsProvider(),
      child: const SearchScreen(),
    );
  }

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearch(BuildContext context, String value) {
    final provider = context.read<PostsProvider>();
    provider.getAllPostListAPI(
      resetData: true,
      showLoader: true,
      searchQuery: value.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PostsProvider>(
      builder: (context, provider, child) {
        return StackedLoader(
          loading: provider.loader,
          child: Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            appBar: AppBar(
              backgroundColor: ColorRes.white,
              title: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: "Search posts...",
                  border: InputBorder.none,
                ),
                onSubmitted: (val) => _onSearch(context, val),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _searchController.clear();
                    provider.getAllPostListAPI(resetData: true);
                  },
                ),
              ],
            ),
            body: CustomListView(
              controller: _scrollController,
              padding: EdgeInsets.all(Constants.horizontalPadding),
              itemCount:
                  provider.loader ? 0 : provider.postListResponse.length + 1,
              onRefresh:
                  () => provider.getAllPostListAPI(
                    resetData: true,
                    searchQuery: _searchController.text.trim(),
                  ),
              emptyWidget: const Center(child: Text("No posts found")),
              showEmptyWidget:
                  !provider.loader && provider.postListResponse.isEmpty,
              separatorBuilder:
                  (_, __) =>
                      Divider(color: ColorRes.black.withValues(alpha: 0.1)),
              itemBuilder: (context, index) {
                if (index >= provider.postListResponse.length) {
                  if (!provider.hasMoreData) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          'No more items',
                          style: styleW500S12.copyWith(color: ColorRes.grey),
                        ),
                      ),
                    );
                  }
                  if (!provider.isApiCalling) {
                    provider.getAllPostListAPI(
                      searchQuery: _searchController.text.trim(),
                    );
                  }
                  return const SizedBox(height: 100, child: SmallLoader());
                }

                return PostCard(
                  post: provider.postListResponse[index],
                  loading: provider.loader,
                  onTapPost: () {
                    _handleMediaNavigation(context, provider, index);
                  },
                  onTap: () {
                    context.navigator.pushNamed(
                      UploadScreen.routeName,
                      arguments: provider.postListResponse[index],
                    );
                  },
                  onRatingSubmitted: (rate) {
                    var rating = DoubleRatingExtension(rate).toStars();
                    final post = provider.postListResponse[index];
                    if (post.postRating?.toStarCount() == 0) {
                      provider.newRatePostAPI(
                        context,
                        postId: post.id,
                        rating: rating.toString(),
                      );
                    } else {
                      provider.updateRatePostAPI(
                        context,
                        postId: post.id,
                        rating: rating.toString(),
                      );
                    }
                  },
                  onCommentSubmitted: (val) {
                    print("Comment ===== $val");
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _handleMediaNavigation(
    BuildContext context,
    PostsProvider provider,
    int index,
  ) {
    final post = provider.postListResponse[index];
    final media = post.media;

    if (media == null || media.url == null) {
      showErrorMsg('Media not available');
      return;
    }

    final url = EndPoints.domain + media.url!;
    final title = post.content ?? 'Post Content';

    if (media.type == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ImagePreviewScreen(imageUrl: url, title: title),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) =>
                  VideoPlayerScreen(thumbnailUrl: url, title: title, url: url),
        ),
      );
    }
  }
}
