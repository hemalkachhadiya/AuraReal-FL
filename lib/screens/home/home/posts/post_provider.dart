import 'package:aura_real/apis/model/post_model.dart';
import 'package:aura_real/aura_real.dart';

class PostsProvider extends ChangeNotifier {
  PostsProvider() {
    init();
  }

  Future<void> init() async {
    await postLocationAPI();
    await getAllPostListAPI(showLoader: true, resetData: true);
  }

  late final List<PostModel> posts = [];
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
  bool _disposed = false;

  bool get isLoading => _isLoading;

  String? get error => _error;

  bool get hasMoreData => paginationModel?.hasMorePages ?? false;

  /// Get All Post List API with pagination
  Future<void> getAllPostListAPI({
    bool showLoader = false,
    bool resetData = false,
  }) async {
    // Avoid calling API if the list is empty and no reset is requested
    if (posts.isEmpty && !resetData) return;

    if (isApiCalling) return;
    isApiCalling = true;

    if (showLoader) {
      loader = true;
      _safeNotifyListeners();
    }

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
        currentPage++;
        print("paginationModel-------- ${paginationModel?.list?.length}");
      } else {
        _error = "Failed to fetch posts";
      }
      await Future.delayed(1.seconds);
    } catch (e) {
      _error = e.toString();
      // Optionally show a toast or update UI
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
    final result = await PostAPI.commentOnPostAPI(
      postId: postId.toString(),
      content: content.toString(),
    );
    print("RESULT ===== ${result}");
    if (result) {
      await getAllCommentListAPI(
        postId!,
        showLoader: true,
        resetData: true,
      ); // Refresh comments
    }
    loaderComments = false;
    notifyListeners();
  }

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
