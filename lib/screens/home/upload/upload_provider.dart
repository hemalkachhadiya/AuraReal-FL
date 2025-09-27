import 'package:aura_real/aura_real.dart';

class UploadProvider extends ChangeNotifier {
  final String postUserId;

  UploadProvider(this.postUserId) {
    init();
  }

  Future<void> init() async {
    await getPostByUserAPI(showLoader: true, resetData: true);
  }

  AppResponse2<PostModel>? paginationModel;
  Profile? profileData;
  bool isFollowing = false;

  List<PostModel> get postByUserResponse => paginationModel?.list ?? [];
  bool _disposed = false;
  int currentPage = 0;
  int pageSize = 20;
  bool isApiCalling = false;
  bool loader = false;
  bool rateLoader = false;
  bool followLoader = false;

  late final List<PostModel> posts = [];
  final bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;

  String? get error => _error;

  // List<PostModel>? get postByUserResponse => paginationModel?.list ?? [];
  bool get hasMoreData => paginationModel?.hasMorePages ?? false;

  /// Get All Post List API with pagination
  Future<void> getPostByUserAPI({
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
      final model = await PostAPI.getPostByUserAPI(
        page: currentPage + 1, // API expects 1-based indexing
        pageSize: pageSize,
        userId: postUserId,
      );
      if (kDebugMode) {
        if (model?.profile != null) {
          profileData = model?.profile;
          isFollowing = profileData?.is_following ?? false;
        }
      }
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

  ///userid ===> je person ni profile hoy te id
  /// followUserId ===> login person ni userid
  Future<bool> followUserProfile(BuildContext context) async {
    if (userData == null || userData?.id == null) return false;

    followLoader = true;
    notifyListeners();

    final result = await AuthApis.followUserProfile(
      followUserId: userData!.id!,
      userId: postUserId,
    );

    followLoader = false;

    if (result) {
      isFollowing = true;

      if (profileData != null) {
        profileData!.followingCount = (profileData!.followingCount ?? 0) + 1;
      }
      followLoader = false;
      notifyListeners();
      return true;
    }
    followLoader = false;
    notifyListeners();
    return false;
  }

  /// ===> je person ni profile hoy te id
  /// followUserId ===> login person ni userid
  Future<bool> unfollowUserProfile(BuildContext context) async {
    if (userData == null || userData?.id == null) return false;

    followLoader = true;
    notifyListeners();

    final result = await AuthApis.unfollowUserProfile(
      followUserId: userData!.id!,
      userId: postUserId,
    );

    followLoader = false;

    if (result) {
      isFollowing = false;

      if (profileData != null && (profileData!.followingCount ?? 0) > 0) {
        profileData!.followingCount = (profileData!.followingCount ?? 0) - 1;
      }

      notifyListeners();
      return true;
    }
    followLoader = false;
    notifyListeners();
    return false;
  }

  ///Create Chat Room For Send Message
  Future<void> createChatRoom(BuildContext context) async {
    if (userData == null || userData?.id == null) return;

    loader = true;
    notifyListeners();

    try {
      final result = await ChatApis.createChatRoom(
        userId: userData!.id!,
        followUserId: postUserId, // The profile user's ID
      );

      if (result.success! && result.data != null) {
        final chatUser = ChatUser(
          id: postUserId,
          name: profileData?.fullName ?? "User",
          avatarUrl: profileData?.profileImage ?? "",
          isOnline: true,
          // lastSeen: DateTime.now().toString(),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => ChangeNotifierProvider(
                  create: (_) {
                    final provider = MessageProvider();
                    provider.initializeChat(
                      user: chatUser,
                      roomId: result.data?.id ?? "",
                    );
                    return provider;
                  },
                  child: MessageScreen(chatUser: chatUser),
                ),
          ),
        );
        // Navigate to chat screen or handle success

        // Navigator.push(context, MaterialPageRoute(
        //   builder: (context) => MessageScreen(chatUser: ),
        // ));
      } else {
        showCatchToast(result.message ?? "Failed to create chat room", null);
      }
    } catch (e) {
      showCatchToast(e.toString(), null);
    } finally {
      loader = false;
      notifyListeners();
    }
  }

  /// Helper method to safely call notifyListeners
  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
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
            isRated: true,
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
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
