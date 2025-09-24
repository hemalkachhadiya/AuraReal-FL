import 'package:aura_real/apis/model/post_model.dart';
import 'package:aura_real/aura_real.dart';
import 'package:http/http.dart' as http;

class PostsProvider extends ChangeNotifier {
  PostsProvider() {
    init();
  }

  Future<void> init() async {
    await postLocationAPI();
    await getAllPostListAPI(showLoader: true, resetData: true);
  }

  late List<PostModel> posts = [];
  late final List<CommentModel> comments = [];
  bool _isLoading = false;
  String? _error;

  AppResponse2<PostModel>? paginationModel;
  AppResponse2<CommentModel>? paginationCommentModel;

  List<PostModel> get postListResponse => paginationModel?.list ?? [];

  List<CommentModel> get commentListResponse =>
      paginationCommentModel?.list ?? [];

  int currentPage = 0;
  int pageSize = 20;
  bool isApiCalling = false;
  bool loader = false;
  bool rateLoader = false;
  bool refreshLoader = false;
  bool _disposed = false;

  bool get isLoading => _isLoading;

  String? get error => _error;

  bool hasMoreData = false;

  ///=============Comments Variable
  late final Map<String, List<CommentModel>> _commentLists =
      {}; // Map to store comments by postId
  bool _isLoadingComments = false;
  String? _errorComments;
  int currentPageComments = 0;
  int pageSizeComments = 20;
  bool isApiCallingComments = false;
  bool loaderComments = false;

  bool get isLoadingComments => _isLoadingComments;
  late final List<CommentModel> commentModel = [];

  String? get errorComments => _errorComments;

  List<CommentModel> getCommentList(String postId) =>
      _commentLists[postId] ?? [];

  bool get hasMoreComments => paginationModel?.hasMorePages ?? false;
  double scrollPosition = 0.0; // Store scroll position

  /// Get All Post List API with pagination
  Future<void> getAllPostListAPI({
    bool showLoader = false,
    bool resetData = false,
    String? searchQuery, // <-- Added search param
  }) async {
    // Avoid calling API if no pagination model exists and no reset is requested
    if (paginationModel == null && !resetData) return;

    // Prevent multiple simultaneous API calls
    if (isApiCalling) return;
    isApiCalling = true;

    // Show loader if requested
    if (showLoader) {
      loader = true;
      _safeNotifyListeners();
    }

    // Reset data if requested
    if (resetData) {
      currentPage = 0;
      paginationModel = null;
      posts.clear();
    }

    try {
      final model = await PostAPI.getAllPostListAPI(
        page: currentPage + 1, // API expects 1-based indexing
        pageSize: pageSize,
        search: searchQuery, // <-- Pass search param
      );

      if (model != null) {
        if (resetData || paginationModel == null) {
          paginationModel = model.copyWith();
        } else {
          final existingIds =
              paginationModel?.list?.map((e) => e.id).toSet() ?? {};
          final newItems =
              (model.list ?? [])
                  .where((e) => !existingIds.contains(e.id))
                  .toList();

          paginationModel = paginationModel?.copyWith(
            list: [...(paginationModel?.list ?? []), ...newItems],
          );
        }

        // Update hasMoreData based on API response
        // Assuming AppResponse2 has a total or hasMore field; adjust if different
        hasMoreData =
            (model.totalPages != null &&
                (currentPage + 1) < model.totalPages!) ||
            ((model.list?.length ?? 0) >= pageSize);
        // hasMoreData = (model.list?.length ?? 0) >= pageSize;
        // If your API provides total pages or total items, use this instead:
        // hasMoreData = (currentPage + 1) < (model.totalPages ?? 0);

        currentPage++;
        print("paginationModel-------- ${paginationModel?.list?.length}");
      } else {
        _error = "Failed to fetch posts";
        hasMoreData = false;
      }
    } catch (e) {
      _error = e.toString();
      hasMoreData = false;
      if (showLoader) showCatchToast(_error, null);
    } finally {
      loader = false;
      isApiCalling = false;
      _safeNotifyListeners();
    }
  }

  /// Load posts (wrapper for getAllPostListAPI)
  Future<void> loadPosts({bool resetData = false}) async {
    _isLoading = true;
    _error = null;
    _safeNotifyListeners();

    await getAllPostListAPI(showLoader: true, resetData: resetData);

    _isLoading = false;
    _safeNotifyListeners();
  }

  /// Get post by ID
  PostModel? getPostById(String? postId) {
    if (postId == null) return null;
    try {
      return posts.firstWhere((post) => post.id == postId);
    } catch (e) {
      return null;
    }
  }

  ///Post Location
  Future<void> postLocationAPI() async {
    if (userData == null || userData?.id == null) return;
    loader = true;
    notifyListeners();
    var latitude = PrefService.getDouble(PrefKeys.latitude);
    var longitude = PrefService.getDouble(PrefKeys.longitude);
    var location = PrefService.getString(PrefKeys.location);
    var city = PrefService.getString(PrefKeys.city);
    var country = PrefService.getString(PrefKeys.country);
    var state = PrefService.getString(PrefKeys.state);
    final result = await AuthApis.postLocationAPI(
      longitude: double.parse(longitude.toString()),
      latitude: double.parse(latitude.toString()),
      address: location,
      city: city,
      country: country,
      state: state,
    );
    if (result != null) {
      notifyListeners();
    }
    loader = false;
    notifyListeners();
  }

  /// Helper method to update post rating locally
  void _updatePostRatingLocally(String? postId, String? newRating) {
    if (postId == null || newRating == null) return;

    try {
      final ratingValue = double.tryParse(newRating) ?? 0.0;

      // Update the post in paginationModel list
      if (paginationModel?.list != null) {
        final postIndex = paginationModel!.list!.indexWhere(
          (post) => post.id == postId,
        );
        if (postIndex != -1) {
          final currentPost = paginationModel!.list![postIndex];

          // Create updated post with new rating
          final updatedPost = currentPost.copyWith(
            postRating: ratingValue,
            // Update other rating-related fields if needed
            // userRating: ratingValue,
            // averageRating: calculateNewAverage(currentPost, ratingValue),
            // totalRatings: currentPost.totalRatings + 1,
          );

          // Replace the post in paginationModel list
          paginationModel!.list![postIndex] = updatedPost;

          print(
            "Updated post rating locally for postId: $postId to rating: $ratingValue",
          );
        }
      }

      // Also update in posts list if it exists and is being used
      final postsIndex = posts.indexWhere((post) => post.id == postId);
      if (postsIndex != -1) {
        final currentPost = posts[postsIndex];
        final updatedPost = currentPost.copyWith(postRating: ratingValue);
        posts[postsIndex] = updatedPost;
      }

      // Notify listeners to update UI
      _safeNotifyListeners();
    } catch (e) {
      print('Error updating post rating locally: $e');
      // Handle error - maybe show a message or revert changes
    }
  }

  /// Updated Rating APIs with local updates
  Future<void> updateRatePostAPI(
    BuildContext context, {
    String? postId,
    String? rating,
  }) async {
    if (userData == null || userData?.id == null) return;

    // Store original rating for rollback if needed
    final originalPost = paginationModel?.list?.firstWhere(
      (post) => post.id == postId,
      orElse: () => PostModel(),
    );
    final originalRating = originalPost?.postRating;

    // Update UI immediately for better UX
    _updatePostRatingLocally(postId, rating);

    try {
      rateLoader = true;
      notifyListeners();

      final result = await PostAPI.updateRatePostAPI(
        postId: postId.toString(),
        rating: rating.toString(),
      );
      print("Res === ${result}");
      if (!result) {
        // Revert changes if API failed
        if (originalRating != null) {
          _updatePostRatingLocally(postId, originalRating.toString());
        }
      }
    } catch (e) {
      // Revert changes on error
      if (originalRating != null) {
        _updatePostRatingLocally(postId, originalRating.toString());
      }
      showCatchToast("Error updating rating: ${e.toString()}", null);
    } finally {
      rateLoader = false;
      notifyListeners();
    }
  }

  ///New Rate API - Add new rating
  Future<void> newRatePostAPI(
    BuildContext context, {
    String? postId,
    String? rating,
  }) async {
    print("api rating ========== ${rating}");
    if (userData == null || userData?.id == null) return;

    // Store original rating for rollback if needed
    final originalPost = paginationModel?.list?.firstWhere(
      (post) => post.id == postId,
      orElse: () => PostModel(),
    );
    final originalRating =
        originalPost?.postRating ?? 0.0; // Store original rating

    // Update UI immediately for better UX
    _updatePostRatingLocally(postId, rating);

    try {
      rateLoader = true;
      notifyListeners();

      final result = await PostAPI.newRatePostAPI(
        postId: postId.toString(),
        newRating: rating.toString(),
      );

      print("Result == ${result}");
      if (!result) {
        // Revert changes if API failed - use original rating instead of 0.0
        _updatePostRatingLocally(postId, originalRating.toString());
        // showCatchToast(result, null);
      }
    } catch (e) {
      // Revert changes on error - use original rating instead of 0.0
      _updatePostRatingLocally(postId, originalRating.toString());
      showCatchToast("Error adding rating: ${e.toString()}", null);
    } finally {
      rateLoader = false;
      notifyListeners();
    }
  }

  ///Comment Post API
  /// Comment or Reply on Post
  Future<void> commentPostAPI(
    BuildContext context, {
    String? postId,
    String? content,
    String? parentCommentId, // <-- added
  }) async {
    if (userData == null || userData?.id == null) return;
    loaderComments = true;
    notifyListeners();

    try {
      final result = await PostAPI.commentOnPostAPI(
        postId: postId.toString(),
        content: content.toString(),
        parentCommentId: parentCommentId, // <-- pass here
      );

      if (result != null) {
        final response = result['response'] as http.Response?;
        if (response != null && result['success'] == true) {
          await getAllCommentListAPI(
            postId!,
            showLoader: true,
            resetData: true,
          );
        } else if (response != null &&
            response.statusCode == 400 &&
            result['isDuplicate'] == true) {
          print("Comment already exists, skipping refreshPostListPage");
        } else {
          _errorComments = "Failed to comment";
          if (loaderComments) showCatchToast(_errorComments, null);
        }
      } else {
        _errorComments = "Failed to comment";
        if (loaderComments) showCatchToast(_errorComments, null);
      }
    } catch (e) {
      _errorComments = e.toString();
      if (loaderComments) showCatchToast(_errorComments, null);
      print('Exception in commentPostAPI: $e');
    } finally {
      loaderComments = false;
      notifyListeners();
    }
  }

  /// Save scroll position
  void saveScrollPosition(double position) {
    scrollPosition = position;
  }

  /// Get All Comment List
  Future<void> getAllCommentListAPI(
    String postId, {
    bool showLoader = false,
    bool resetData = false,
  }) async {
    if (comments.isEmpty && !resetData) return;
    if (isApiCallingComments) return;

    isApiCallingComments = true;
    if (showLoader) {
      loaderComments = true;
      _safeNotifyListeners();
    }
    if (resetData) {
      currentPageComments = 0;
      paginationCommentModel = null;
      commentModel.clear();
    }

    try {
      final model = await PostAPI.getAllCommentListAPI(
        postId: postId,
        page: currentPageComments + 1,
        pageSize: pageSizeComments,
      );

      List<CommentModel> flatList = [];

      if (resetData || paginationCommentModel == null) {
        paginationCommentModel = model?.copyWith();
        flatList = model?.list ?? [];
      } else {
        final existingIds =
            paginationCommentModel?.list?.map((e) => e.id).toSet() ?? {};
        final newItems =
            (model?.list ?? [])
                .where((e) => !existingIds.contains(e.id))
                .toList();

        paginationCommentModel = paginationCommentModel?.copyWith(
          list: [...(paginationCommentModel?.list ?? []), ...newItems],
        );

        flatList = paginationCommentModel?.list ?? [];
      }

      // Build tree structure
      _commentLists[postId] = buildCommentTree(flatList);
    } catch (e) {
      _errorComments = e.toString();
      if (loaderComments) showCatchToast(_errorComments, null);
      print('Exception in getAllCommentListAPI: $e');
      if (showLoader) showCatchToast(_errorComments, null);
    } finally {
      loaderComments = false;
      isApiCallingComments = false;
      _safeNotifyListeners();
    }
  }

  List<CommentModel> buildCommentTree(List<CommentModel> flatComments) {
    final Map<String, CommentModel> lookup = {
      for (var c in flatComments) c.id!: c.copyWith(replies: []),
    };

    List<CommentModel> roots = [];

    for (var comment in lookup.values) {
      if (comment.parentCommentId != null &&
          lookup.containsKey(comment.parentCommentId)) {
        // Add as reply to parent
        lookup[comment.parentCommentId]!.replies!.add(comment);
      } else {
        // Root comment
        roots.add(comment);
      }
    }

    return roots;
  }

  /// Clear all posts
  void clearPosts() {
    posts.clear();
    paginationModel = null;
    currentPage = 0;
    _error = null;
    _safeNotifyListeners();
  }

  /// Helper method to safely call notifyListeners
  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
