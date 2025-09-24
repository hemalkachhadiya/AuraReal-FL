import 'package:aura_real/aura_real.dart';

/// ---------- Helpers to encode / decode AppResponse2 ----------
AppResponse2<T> appResponseFromJson2<T>(
    String str, {
      T Function(dynamic)? converter,
      String? dataKey, // Made optional to auto-detect
    }) => AppResponse2.fromJson(
  json.decode(str),
  converter: converter,
  dataKey: dataKey,
);

String appResponseToJson2<T>(
    AppResponse2<T> response, {
      Map<String, dynamic> Function(T)? converter,
      String? dataKey, // Made optional to auto-detect
    }) => json.encode(response.toJson(converter: converter, dataKey: dataKey));

/// ---------- Universal AppResponse2 for Multiple API Structures ----------
class AppResponse2<T> {
  bool? success;
  String? message;

  // Posts API fields
  int? currentPage;
  int? totalPages;
  int? totalPosts;

  // Users API fields
  int? page;
  int? limit;
  int? totalUsers;
  double? radius;
  String? searchQuery;

  // Common data field
  List<T>? list;
  Profile? profile;

  AppResponse2({
    this.success,
    this.message,
    this.currentPage,
    this.totalPages,
    this.totalPosts,
    this.page,
    this.limit,
    this.totalUsers,
    this.radius,
    this.searchQuery,
    this.list,
    this.profile,
  });

  factory AppResponse2.fromJson(
      Map<String, dynamic> json, {
        T Function(dynamic)? converter,
        String? dataKey,
      }) {
    List<T>? parsedList;

    // Helper function to safely convert dynamic to int
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    // Helper function to safely convert dynamic to double
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    // Auto-detect dataKey if not provided
    String detectedDataKey = dataKey ?? _detectDataKey(json);

    // Handle data array parsing
    if (json[detectedDataKey] != null) {
      if (json[detectedDataKey] is List) {
        if (converter != null) {
          parsedList = (json[detectedDataKey] as List)
              .map((item) => converter(item))
              .toList();
        } else {
          try {
            parsedList = json[detectedDataKey] as List<T>;
          } catch (e) {
            parsedList = null;
          }
        }
      } else if (json[detectedDataKey] is Map<String, dynamic> &&
          json[detectedDataKey]['list'] is List) {
        final data = json[detectedDataKey] as Map<String, dynamic>;
        if (converter != null) {
          parsedList = (data['list'] as List)
              .map((item) => converter(item))
              .toList();
        } else {
          try {
            parsedList = data['list'] as List<T>;
          } catch (e) {
            parsedList = null;
          }
        }
      }
    }

    // Parse profile if it exists
    Profile? parsedProfile;
    if (json['profile'] != null && json['profile'] is Map<String, dynamic>) {
      parsedProfile = Profile.fromJson(json['profile']);
    }

    return AppResponse2<T>(
      success: json['success'] as bool?,
      message: json['message'] as String?,

      // Posts API fields
      currentPage: parseInt(json['currentPage']),
      totalPages: parseInt(json['totalPages']),
      totalPosts: parseInt(json['totalPosts']),

      // Users API fields
      page: parseInt(json['page']),
      limit: parseInt(json['limit']),
      totalUsers: parseInt(json['totalUsers']),
      radius: parseDouble(json['radius']),
      searchQuery: json['searchQuery'] as String?,

      list: parsedList,
      profile: parsedProfile,
    );
  }

  // Helper method to detect the data key automatically
  static String _detectDataKey(Map<String, dynamic> json) {
    if (json.containsKey('posts')) return 'posts';
    if (json.containsKey('users')) return 'users';
    if (json.containsKey('data')) return 'data';
    if (json.containsKey('items')) return 'items';
    if (json.containsKey('results')) return 'results';
    return 'posts'; // Default fallback
  }

  Map<String, dynamic> toJson({
    Map<String, dynamic> Function(T)? converter,
    String? dataKey,
  }) {
    List<dynamic>? serializedList;

    if (list != null) {
      if (converter != null) {
        serializedList = list!.map((item) => converter(item)).toList();
      } else {
        serializedList = list as List<dynamic>?;
      }
    }

    // Auto-detect dataKey for serialization if not provided
    String detectedDataKey = dataKey ?? _getDataKeyForSerialization();

    Map<String, dynamic> result = {
      'success': success,
      'message': message,

      // Posts API fields (only include if they exist)
      if (currentPage != null) 'currentPage': currentPage,
      if (totalPages != null) 'totalPages': totalPages,
      if (totalPosts != null) 'totalPosts': totalPosts,

      // Users API fields (only include if they exist)
      if (page != null) 'page': page,
      if (limit != null) 'limit': limit,
      if (totalUsers != null) 'totalUsers': totalUsers,
      if (radius != null) 'radius': radius,
      if (searchQuery != null) 'searchQuery': searchQuery,

      // Data array
      if (serializedList != null) detectedDataKey: serializedList,

      // Profile
      if (profile != null) 'profile': profile!.toJson(),
    };

    return result;
  }

  // Helper method to determine data key for serialization
  String _getDataKeyForSerialization() {
    // If we have posts-specific fields, use 'posts'
    if (currentPage != null || totalPosts != null) return 'posts';

    // If we have users-specific fields, use 'users'
    if (page != null || totalUsers != null || radius != null) return 'users';

    // Default fallback
    return 'posts';
  }

  AppResponse2<T> copyWith({
    bool? success,
    String? message,
    int? currentPage,
    int? totalPages,
    int? totalPosts,
    int? page,
    int? limit,
    int? totalUsers,
    double? radius,
    String? searchQuery,
    List<T>? list,
    Profile? profile,
  }) => AppResponse2<T>(
    success: success ?? this.success,
    message: message ?? this.message,
    currentPage: currentPage ?? this.currentPage,
    totalPages: totalPages ?? this.totalPages,
    totalPosts: totalPosts ?? this.totalPosts,
    page: page ?? this.page,
    limit: limit ?? this.limit,
    totalUsers: totalUsers ?? this.totalUsers,
    radius: radius ?? this.radius,
    searchQuery: searchQuery ?? this.searchQuery,
    list: list ?? this.list,
    profile: profile ?? this.profile,
  );

  // Computed properties that work with both API structures
  bool get isSuccess => success == true;

  bool get hasData => list != null && list!.isNotEmpty;

  bool get hasMorePages {
    // Handle both API structures
    if (currentPage != null && totalPages != null) {
      return currentPage! < totalPages!;
    }
    if (page != null && totalPages != null) {
      return page! < totalPages!;
    }
    return false;
  }

  int get pageNumber {
    if (currentPage != null) return currentPage!;
    if (page != null) return page!;
    return 1;
  }

  int get itemsCount {
    if (totalPosts != null) return totalPosts!;
    if (totalUsers != null) return totalUsers!;
    return list?.length ?? 0;
  }

  int get totalPagesCount => totalPages ?? 1;

  // Additional helper getters for users API
  int get limitPerPage => limit ?? 10;
  double get searchRadius => radius ?? 0.0;
  String get query => searchQuery ?? '';

  // Helper method to check which API structure this response represents
  bool get isPostsResponse => currentPage != null || totalPosts != null;
  bool get isUsersResponse => page != null || totalUsers != null || radius != null;
}

// /// ---------- Helpers to encode / decode AppResponse2 ----------
// AppResponse2<T> appResponseFromJson2<T>(
//   String str, {
//   T Function(dynamic)? converter,
//   String dataKey = 'posts',
// }) => AppResponse2.fromJson(
//   json.decode(str),
//   converter: converter,
//   dataKey: dataKey,
// );
//
// String appResponseToJson2<T>(
//   AppResponse2<T> response, {
//   Map<String, dynamic> Function(T)? converter,
//   String dataKey = 'posts',
// }) => json.encode(response.toJson(converter: converter, dataKey: dataKey));
//
// /// ---------- AppResponse2 for API Structure ----------
// class AppResponse2<T> {
//   bool? success;
//   String? message;
//   int? currentPage;
//   int? totalPages;
//   int? totalPosts;
//   List<T>? list;
//   Profile? profile;
//
//   AppResponse2({
//     this.success,
//     this.message,
//     this.currentPage,
//     this.totalPages,
//     this.totalPosts,
//     this.list,
//     this.profile,
//   });
//
//   factory AppResponse2.fromJson(
//     Map<String, dynamic> json, {
//     T Function(dynamic)? converter,
//     String dataKey = 'posts',
//   }) {
//     List<T>? parsedList;
//
//     // Helper function to safely convert dynamic to int
//     int? parseInt(dynamic value) {
//       if (value == null) return null;
//       if (value is int) return value;
//       if (value is String) return int.tryParse(value);
//       return null;
//     }
//
//     // Handle posts as either a direct list or a map with a 'list' key
//     if (json[dataKey] != null) {
//       if (json[dataKey] is List) {
//         if (converter != null) {
//           parsedList =
//               (json[dataKey] as List).map((item) => converter(item)).toList();
//         } else {
//           try {
//             parsedList = json[dataKey] as List<T>;
//           } catch (e) {
//             parsedList = null;
//           }
//         }
//       } else if (json[dataKey] is Map<String, dynamic> &&
//           json[dataKey]['posts'] is List) {
//         final postsData = json[dataKey] as Map<String, dynamic>;
//         if (converter != null) {
//           parsedList =
//               (postsData['posts'] as List)
//                   .map((item) => converter(item))
//                   .toList();
//         } else {
//           try {
//             parsedList = postsData['posts'] as List<T>;
//           } catch (e) {
//             parsedList = null;
//           }
//         }
//       }
//     }
//
//     // Parse profile if it exists
//     Profile? parsedProfile;
//     if (json['profile'] != null && json['profile'] is Map<String, dynamic>) {
//       parsedProfile = Profile.fromJson(json['profile']);
//     }
//
//     return AppResponse2<T>(
//       success: json['success'] as bool?,
//       message: json['message'] as String?,
//       currentPage: parseInt(json['currentPage']),
//       totalPages: parseInt(json['totalPages']),
//       totalPosts: parseInt(json['totalPosts']),
//       list: parsedList,
//       profile: parsedProfile,
//     );
//   }
//
//   Map<String, dynamic> toJson({
//     Map<String, dynamic> Function(T)? converter,
//     String dataKey = 'posts',
//   }) {
//     List<dynamic>? serializedList;
//
//     if (list != null) {
//       if (converter != null) {
//         serializedList = list!.map((item) => converter!(item)).toList();
//       } else {
//         serializedList = list as List<dynamic>?;
//       }
//     }
//
//     return {
//       'success': success,
//       'message': message,
//       'currentPage': currentPage,
//       'totalPages': totalPages,
//       'totalPosts': totalPosts,
//       dataKey: serializedList != null ? {'list': serializedList} : null,
//       'profile': profile?.toJson(),
//     };
//   }
//
//   AppResponse2<T> copyWith({
//     bool? success,
//     String? message,
//     int? currentPage,
//     int? totalPages,
//     int? totalPosts,
//     List<T>? list,
//     Profile? profile,
//   }) => AppResponse2<T>(
//     success: success ?? this.success,
//     message: message ?? this.message,
//     currentPage: currentPage ?? this.currentPage,
//     totalPages: totalPages ?? this.totalPages,
//     totalPosts: totalPosts ?? this.totalPosts,
//     list: list ?? this.list,
//     profile: profile ?? this.profile,
//   );
//
//   bool get isSuccess => success == true;
//
//   bool get hasData => list != null && list!.isNotEmpty;
//
//   bool get hasMorePages =>
//       currentPage != null && totalPages != null && currentPage! < totalPages!;
//
//   int get pageNumber => currentPage ?? 1;
//
//   int get itemsCount => totalPosts ?? (list?.length ?? 0);
// }
