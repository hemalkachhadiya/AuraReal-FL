import 'package:aura_real/apis/app_response_2.dart';
import 'package:aura_real/apis/post_apis.dart';
import 'package:aura_real/aura_real.dart';

class PostsProvider extends ChangeNotifier {
  PostsProvider() {
    init();
  }

  Future<void> init() async {
    await getAllPostListAPI(showLoader: true,resetData: true);
  }

  late final List<PostListModel>  posts = [];
  bool _isLoading = false;
  String? _error;

  AppResponse2<PostListModel>? paginationModel;

  List<PostListModel> get postListResponse => paginationModel?.list ?? [];

  int currentPage = 0;
  int pageSize = 20;
  bool isApiCalling = false;
  bool loader = false;
  bool _disposed = false;

  // Getters
  // List<PostListModel> get posts => _posts;

  bool get isLoading => _isLoading;

  String? get error => _error;

  // List<PostListModel>? get postListResponse => paginationModel?.list ?? [];
  bool get hasMoreData => paginationModel?.hasMorePages ?? false;

  /// Get All Post List API with pagination
  Future<void> getAllPostListAPI({
    bool showLoader = false,
    bool resetData = false,
  }) async {
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
      } else {
        _error = "Failed to fetch posts";
      }
      await Future.delayed(1.seconds);
    } catch (e) {
      _error = e.toString();
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
  PostListModel? getPostById(String? postId) {
    if (postId == null) return null;
    try {
      return posts.firstWhere((post) => post.id == postId);
    } catch (e) {
      return null;
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
