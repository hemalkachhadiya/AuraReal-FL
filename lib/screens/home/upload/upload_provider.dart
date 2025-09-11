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

import 'package:aura_real/apis/app_response_2.dart';
import 'package:aura_real/apis/model/post_model.dart';
import 'package:aura_real/apis/post_apis.dart';
import 'package:aura_real/aura_real.dart';

class UploadProvider extends ChangeNotifier {
  final String userId;

  UploadProvider(this.userId) {
    init();
  }

  Future<void> init() async {
    await getPostByUserAPI(showLoader: true, resetData: true);
  }

  AppResponse2<PostModel>? paginationModel;
  Profile? profileData;

  List<PostModel> get postByUserResponse => paginationModel?.list ?? [];
  bool _disposed = false;
  int currentPage = 0;
  int pageSize = 20;
  bool isApiCalling = false;
  bool loader = false;

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
        userId: userId,
      );
      if (kDebugMode) {
        print("Model get by user profile ======== ${model?.profile}");
        if (model?.profile != null) {
          profileData = model?.profile;
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

  bool isFollowing = false;

  Future<void> followUserProfile(BuildContext context) async {
    if (userData == null || userData?.id == null) return;

    loader = true;
    // notifyListeners();

    final result = await AuthApis.followUserProfile(
      followUserId: userId,
      userId: userData!.id!,
    );

    if (result) {
      isFollowing = true;
    }

    loader = false;
    // notifyListeners();
  }

  Future<void> unfollowUserProfile(BuildContext context) async {
    if (userData == null || userData?.id == null) return;

    loader = true;
    // notifyListeners();

    final result = await AuthApis.unfollowUserProfile(
      followUserId: userId,
      userId: userData!.id!,
    );

    if (result) {
      isFollowing = false;
    }

    loader = false;
    // notifyListeners();
  }

  // Future<void> followUserProfile(BuildContext context) async {
  //   if (userData == null || userData?.id == null) return;

  //   loader = true;

  //   final result = await AuthApis.followUserProfile(
  //     followUserId: userId,
  //     userId: userData!.id!,
  //   );

  //   loader = false;
  // }

  // Future<void> unfollowUserProfile(BuildContext context) async {
  //   if (userData == null || userData?.id == null) return;

  //   loader = true;

  //   final result = await AuthApis.unfollowUserProfile(
  //     followUserId: userId,
  //     userId: userData!.id!,
  //   );

  //   loader = false;
  // }

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
