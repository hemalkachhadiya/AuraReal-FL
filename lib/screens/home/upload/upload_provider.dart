// import 'package:aura_real/apis/app_response_2.dart';
// import 'package:aura_real/apis/model/post_model.dart';
// import 'package:aura_real/apis/post_apis.dart';
// import 'package:aura_real/aura_real.dart';

// class UploadProvider extends ChangeNotifier {
//   UploadProvider() {
//     init();
//   }

//   Future<void> init() async {
//     await getPostByUserAPI(showLoader: true, resetData: true);
//   }

//   AppResponse2<PostModel>? paginationModel;
//   Profile? profileData;

//   List<PostModel> get postByUserResponse => paginationModel?.list ?? [];
//   bool _disposed = false;
//   int currentPage = 0;
//   int pageSize = 20;
//   bool isApiCalling = false;
//   bool loader = false;

//   late final List<PostModel> posts = [];
//   final bool _isLoading = false;
//   String? _error;

//   bool get isLoading => _isLoading;

//   String? get error => _error;

//   // List<PostModel>? get postByUserResponse => paginationModel?.list ?? [];
//   bool get hasMoreData => paginationModel?.hasMorePages ?? false;

//   /// Get All Post List API with pagination
//   Future<void> getPostByUserAPI({
//     bool showLoader = false,
//     bool resetData = false,
//   }) async {
//     if (isApiCalling) return;
//     isApiCalling = true;

//     if (showLoader) {
//       loader = true;
//       _safeNotifyListeners();
//     }

//     if (resetData) {
//       currentPage = 0;
//       paginationModel = null;
//       posts.clear();
//     }

//     try {
//       final model = await PostAPI.getPostByUserAPI(
//         page: currentPage + 1, // API expects 1-based indexing
//         pageSize: pageSize,
//       );
//       if (kDebugMode) {
//         print("Model get by user profile ======== ${model?.profile}");
//         if (model?.profile != null) {
//           profileData = model?.profile;
//           print("Profile Rating ------- ${profileData?.ratingsAvg}");
//         }
//       }
//       if (model != null) {
//         if (resetData || paginationModel == null) {
//           paginationModel = model.copyWith();
//         } else {
//           final existingIds =
//               paginationModel?.list?.map((e) => e.id).toSet() ?? {};
//           final newItems =
//               (model.list ?? [])
//                   .where((e) => !existingIds.contains(e.id))
//                   .toList();

//           paginationModel = paginationModel?.copyWith(
//             list: [...(paginationModel?.list ?? []), ...newItems],
//           );
//         }
//         currentPage++;
//       } else {
//         _error = "Failed to fetch posts";
//       }
//       await Future.delayed(1.seconds);
//     } catch (e) {
//       _error = e.toString();
//     } finally {
//       loader = false;
//       isApiCalling = false;
//       _safeNotifyListeners();
//     }
//   }

//   ///follow and unfollow
//   Future<void> followUserProfile(
//     BuildContext context,
//     String followUserId,
//   ) async {
//     if (userData == null || userData?.id == null) return;
//     loader = true;
//     notifyListeners();
//     final result = await AuthApis.followUserProfile(
//       followUserId: followUserId,
//       userId: userData!.id!,
//     );
//     if (result) {}
//     loader = false;
//     notifyListeners();
//   }

//   /// Helper method to safely call notifyListeners
//   void _safeNotifyListeners() {
//     if (!_disposed) {
//       notifyListeners();
//     }
//   }

//   @override
//   void dispose() {
//     _disposed = true;
//     super.dispose();
//   }
// }
import 'package:aura_real/apis/chat_apis.dart';
import 'package:aura_real/apis/model/post_model.dart';
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
        print("Model get by user profile ======== ${model?.profile}");
        if (model?.profile != null) {
          profileData = model?.profile;
          isFollowing = profileData?.is_following ?? false;
          print("Profile Rating ------- ${profileData?.ratingsAvg}");
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

  Future<bool> unfollowUserProfile(BuildContext context) async {
    if (userData == null || userData?.id == null) return false;

    followLoader = true;
    notifyListeners();

    final result = await AuthApis.unfollowUserProfile(
      followUserId: postUserId,
      userId: userData!.id!,
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
    print("test==============================1");
    if (userData == null || userData?.id == null) return;

    loader = true;
    notifyListeners();

    try {
      print("test==============================2");
      print("UserId============== ${userData!.id}");
      print("postUserId============== ${postUserId}");

      final result = await ChatApis.createChatRoom(
        userId: userData!.id!,
        followUserId: postUserId, // The profile user's ID
      );

      if (result.success! && result.data != null) {
        print("Chat Room Id -- ${result.data?.chatRoomId}");
        // Navigate to MessageScreen with provider
        // Build ChatUser for MessageScreen
        final chatUser = ChatUser(
          id: postUserId,
          name: profileData?.fullName ?? "User",
          avatarUrl: profileData?.profileImage ?? "",
          isOnline: false,
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
                      chatRoomId: chatUser.id!,
                    ); // <-- preload chat data
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

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
