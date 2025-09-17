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
  int pageSize = 5;
  bool isApiCalling = false;
  bool loader = false;
  bool refreshLoader = false;
  bool _disposed = false;

  bool get isLoading => _isLoading;

  String? get error => _error;

  bool hasMoreData = false;
  ///=============Comments Variable

  /// Get All Comment List API for a specific post
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

  ///RateAPI
  Future<void> updateRatePostAPI(
    BuildContext context, {
    String? postId,
    String? rating,
  }) async {
    if (userData == null || userData?.id == null) return;
    loader = true;
    notifyListeners();
    final result = await PostAPI.updateRatePostAPI(
      postId: postId.toString(),
      rating: rating.toString(),
    );
    await getAllPostListAPI(resetData: true, showLoader: true);
    if (result) {}
    loader = false;
    notifyListeners();
  }

  ///New Rate API
  Future<void> newRatePostAPI(
    BuildContext context, {
    String? postId,
    String? rating,
  }) async {
    if (userData == null || userData?.id == null) return;
    loader = true;
    notifyListeners();
    final result = await PostAPI.newRatePostAPI(
      postId: postId.toString(),
      newRating: rating.toString(),
    );
    await getAllPostListAPI(resetData: true, showLoader: true);
    if (result) {}
    loader = false;
    notifyListeners();
  }

  ///Comment Post API
  Future<void> commentPostAPI(
    BuildContext context, {
    String? postId,
    String? content,
  }) async {
    if (userData == null || userData?.id == null) return;
    loaderComments = true;
    notifyListeners();

    try {
      final result = await PostAPI.commentOnPostAPI(
        postId: postId.toString(),
        content: content.toString(),
      );
      print("RESULT ===== ${result}");

      if (result != null) {
        final response = result['response'] as http.Response?;
        if (response != null && result['success'] == true) {
          await getAllCommentListAPI(
            postId!,
            showLoader: true,
            resetData: true,
          ); // Refresh comments only if successful
        } else if (response != null &&
            response.statusCode == 400 &&
            result['isDuplicate'] == true) {
          // Skip further actions for duplicate comment
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

  Future<void> refreshPostListPage({
    required int page,
    bool showLoader = false,
    bool replacePage = false, // Whether to replace or append the page data
  }) async {
    print("currernt page ======== ${currentPage}");
    print("refresh==================1");
    if (isApiCalling) return;
    isApiCalling = true;

    if (showLoader) {
      print("refresh==================2");

      refreshLoader = true;
      _safeNotifyListeners();
    }

    try {
      print("refresh==================3");
      // Fetch the page data
      final model = await PostAPI.getAllPostListAPI(
        page: page,
        pageSize: pageSize,
      );

      if (model != null) {
        print("refresh==================4");
        if (replacePage || paginationModel == null) {
          // Replace the data for the specific page
          final startIndex = (page - 1) * pageSize;
          final endIndex = startIndex + (model.list?.length ?? 0);

          if (paginationModel?.list != null &&
              startIndex < paginationModel!.list!.length) {
            paginationModel?.list?.replaceRange(
              startIndex,
              endIndex,
              model.list ?? [],
            );
            posts = paginationModel?.list ?? [];
          } else {
            // If out of range, append or set as new data
            paginationModel = model.copyWith();
            posts = paginationModel?.list ?? [];
          }
        } else {
          print("refresh==================5");
          // Append new items, avoiding duplicates
          final existingIds =
              paginationModel?.list?.map((e) => e.id).toSet() ?? {};
          final newItems =
              (model.list ?? [])
                  .where((e) => !existingIds.contains(e.id))
                  .toList();

          paginationModel = paginationModel?.copyWith(
            list: [...(paginationModel?.list ?? []), ...newItems],
          );
          posts = paginationModel?.list ?? [];
        }
        print(
          "Refreshed paginationModel-------- ${paginationModel?.list?.length}",
        );
      } else {
        _error = "Failed to refresh page $page";
      }
    } catch (e) {
      _error = e.toString();
      if (showLoader) showCatchToast(_error, null);
    } finally {
      refreshLoader = false;
      isApiCalling = false;
      _safeNotifyListeners();
    }
  }

  /// Get All Comment List
  Future<void> getAllCommentListAPI(
    String postId, {
    bool showLoader = false,
    bool resetData = false,
  }) async {
    // if (isApiCallingComments || _commentLists.containsKey(postId))
    //   return _commentLists[postId] ?? [];
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

      if (resetData || paginationCommentModel == null) {
        paginationCommentModel = model?.copyWith();
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
      }
    } catch (e) {
      _errorComments = e.toString();
      if (loaderComments) showCatchToast(_errorComments, null);
      print('Exception in getAllCommentListAPI: $e');
      if (showLoader) showCatchToast(_error, null);
    } finally {
      loaderComments = false;
      isApiCallingComments = false;
      _safeNotifyListeners();
    }
  }

  ///Refresh All Comment List For Particular post
  Future<void> refreshCommentListForPost(
    String postId, {
    int page = 1,
    int index = 0,
    bool showLoader = false,
  }) async {
    print("refresh---------------------1");
    // Check if API is already calling to avoid duplicate calls
    if (isApiCallingComments) return;

    isApiCallingComments = true;

    if (showLoader) {
      print("refresh---------------------2");

      loaderComments = true;
      _safeNotifyListeners();
    }

    try {
      print("refresh---------------------3");

      // Reset data for the specific post
      currentPageComments = page - 1; // Adjust to 0-based index if needed
      paginationCommentModel = null; // Reset pagination model for this post
      // Clear only the comments for this postId if using a map
      if (_commentLists.containsKey(postId)) {
        _commentLists[postId]?.clear();
      } else {
        _commentLists[postId] = [];
      }
      print("refresh---------------------4");

      // Fetch updated comments for the specific post
      final model = await PostAPI.getAllCommentListAPI(
        postId: postId,
        page: page,
        pageSize: pageSizeComments,
      );

      print("refresh---------------------5");

      if (model != null) {
        paginationCommentModel = model.copyWith();
        _commentLists[postId] = model.list ?? [];
      }

      print("refresh---------------------6");

      // Update the specific index if provided (optional, depending on your UI)
      if (index >= 0 && index < (_commentLists[postId]?.length ?? 0)) {
        // Notify listeners or update UI for the specific index
        _safeNotifyListeners();
      }
    } catch (e) {
      _errorComments = e.toString();
      if (showLoader) showCatchToast(_errorComments, null);
      print('Exception in refreshCommentListForPost: $e');
    } finally {
      loaderComments = false;
      isApiCallingComments = false;
      _safeNotifyListeners();
    }
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
