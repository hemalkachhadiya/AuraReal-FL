import 'package:aura_real/aura_real.dart';

/// ---------- Helpers to encode / decode AppResponse2 ----------
AppResponse2<T> appResponseFromJson2<T>(
  String str, {
  T Function(dynamic)? converter,
  String dataKey = 'posts',
}) => AppResponse2.fromJson(
  json.decode(str),
  converter: converter,
  dataKey: dataKey,
);

String appResponseToJson2<T>(
  AppResponse2<T> response, {
  Map<String, dynamic> Function(T)? converter,
  String dataKey = 'posts',
}) => json.encode(response.toJson(converter: converter, dataKey: dataKey));

/// ---------- AppResponse2 for API Structure ----------
class AppResponse2<T> {
  bool? success;
  String? message;
  int? currentPage;
  int? totalPages;
  int? totalPosts;
  List<T>? list;
  Profile? profile;

  AppResponse2({
    this.success,
    this.message,
    this.currentPage,
    this.totalPages,
    this.totalPosts,
    this.list,
    this.profile,
  });

  factory AppResponse2.fromJson(
    Map<String, dynamic> json, {
    T Function(dynamic)? converter,
    String dataKey = 'posts',
  }) {
    List<T>? parsedList;

    // Helper function to safely convert dynamic to int
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    // Handle posts as either a direct list or a map with a 'list' key
    if (json[dataKey] != null) {
      if (json[dataKey] is List) {
        if (converter != null) {
          parsedList =
              (json[dataKey] as List).map((item) => converter(item)).toList();
        } else {
          try {
            parsedList = json[dataKey] as List<T>;
          } catch (e) {
            parsedList = null;
          }
        }
      } else if (json[dataKey] is Map<String, dynamic> &&
          json[dataKey]['posts'] is List) {
        final postsData = json[dataKey] as Map<String, dynamic>;
        if (converter != null) {
          parsedList =
              (postsData['posts'] as List)
                  .map((item) => converter(item))
                  .toList();
        } else {
          try {
            parsedList = postsData['posts'] as List<T>;
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
      currentPage: parseInt(json['currentPage']),
      totalPages: parseInt(json['totalPages']),
      totalPosts: parseInt(json['totalPosts']),
      list: parsedList,
      profile: parsedProfile,
    );
  }

  Map<String, dynamic> toJson({
    Map<String, dynamic> Function(T)? converter,
    String dataKey = 'posts',
  }) {
    List<dynamic>? serializedList;

    if (list != null) {
      if (converter != null) {
        serializedList = list!.map((item) => converter!(item)).toList();
      } else {
        serializedList = list as List<dynamic>?;
      }
    }

    return {
      'success': success,
      'message': message,
      'currentPage': currentPage,
      'totalPages': totalPages,
      'totalPosts': totalPosts,
      dataKey: serializedList != null ? {'list': serializedList} : null,
      'profile': profile?.toJson(),
    };
  }

  AppResponse2<T> copyWith({
    bool? success,
    String? message,
    int? currentPage,
    int? totalPages,
    int? totalPosts,
    List<T>? list,
    Profile? profile,
  }) => AppResponse2<T>(
    success: success ?? this.success,
    message: message ?? this.message,
    currentPage: currentPage ?? this.currentPage,
    totalPages: totalPages ?? this.totalPages,
    totalPosts: totalPosts ?? this.totalPosts,
    list: list ?? this.list,
    profile: profile ?? this.profile,
  );

  bool get isSuccess => success == true;

  bool get hasData => list != null && list!.isNotEmpty;

  bool get hasMorePages =>
      currentPage != null && totalPages != null && currentPage! < totalPages!;

  int get pageNumber => currentPage ?? 1;

  int get itemsCount => totalPosts ?? (list?.length ?? 0);
}

//
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
//     // Check if posts is a map with a 'list' key or a direct list
//     if (json[dataKey] != null) {
//       if (json[dataKey] is Map<String, dynamic> &&
//           json[dataKey]['list'] is List) {
//         final postsData = json[dataKey] as Map<String, dynamic>;
//         if (converter != null) {
//           parsedList =
//               (postsData['list'] as List)
//                   .map((item) => converter(item))
//                   .toList();
//         } else {
//           try {
//             parsedList = postsData['list'] as List<T>;
//           } catch (e) {
//             parsedList = null;
//           }
//         }
//       } else if (json[dataKey] is List) {
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
