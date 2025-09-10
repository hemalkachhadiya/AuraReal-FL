
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
  bool _isLoading = false;
  String? _error;

  AppResponse2<PostModel>? paginationModel;

  List<PostModel> get postListResponse => paginationModel?.list ?? [];

  int currentPage = 0;
  int pageSize = 20;
  bool isApiCalling = false;
  bool loader = false;
  bool _disposed = false;


  bool get isLoading => _isLoading;

  String? get error => _error;

  // List<PostModel>? get postListResponse => paginationModel?.list ?? [];
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
          final existingIds = paginationModel?.list?.map((e) => e.id).toSet() ?? {};
          final newItems = (model.list ?? [])
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
    print("Get Profile ---- ${userData?.id}");
    print("Get latitude ---- ${latitude} ${longitude}");
    print("Get location ---- ${location}");
    print("Get city ---- ${city}");
    print("Get country ---- ${country}");
    print("Get state ---- ${state}");

    print("PrefKeys.latitude ---- ${PrefKeys.latitude}");
    final result = await AuthApis.postLocationAPI(
      longitude: double.parse(longitude.toString()),
      latitude: double.parse(latitude.toString()),
      address: location,
      city: city,
      country: country,
      state: state,
    );
    if (result != null) {
      print("Location Id    ${result.id}");
      print("Location address    ${result.address}");
      print("Location userId    ${result.userId}");

      notifyListeners();
    }
    loader = false;
    notifyListeners();
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
