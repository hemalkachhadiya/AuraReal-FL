import 'dart:convert';

/// ----------  Helpers to encode / decode AppResponse2  ----------
AppResponse2<T> appResponse2FromJson<T>(
    String str, {
      T Function(dynamic)? converter,
      String dataKey = 'posts', // Default key for data
    }) => AppResponse2.fromJson(
  json.decode(str),
  converter: converter,
  dataKey: dataKey,
);

String appResponse2ToJson<T>(
    AppResponse2<T> response, {
      Map<String, dynamic> Function(T)? converter,
      String dataKey = 'posts',
    }) => json.encode(response.toJson(converter: converter, dataKey: dataKey));

/// ----------  AppResponse2 for API Structure  ----------
class AppResponse2<T> {
  bool? success;
  String? message;
  int? currentPage;
  int? totalPages;
  int? totalPosts;
  List<T>? list;

  AppResponse2({
    this.success,
    this.message,
    this.currentPage,
    this.totalPages,
    this.totalPosts,
    this.list,
  });

  factory AppResponse2.fromJson(
      Map<String, dynamic> json, {
        T Function(dynamic)? converter,
        String dataKey = 'posts',
      }) {
    // Handle list parsing correctly
    List<T>? parsedList;

    if (json[dataKey] != null && json[dataKey] is List) {
      if (converter != null) {
        // Use the converter if provided
        parsedList = (json[dataKey] as List).map((item) => converter(item)).toList();
      } else {
        // If no converter provided, try to cast directly (works for primitive types)
        try {
          parsedList = json[dataKey] as List<T>;
        } catch (e) {
          parsedList = null;
        }
      }
    }

    return AppResponse2<T>(
      success: json['success'],
      message: json['message'],
      currentPage: json['currentPage'],
      totalPages: json['totalPages'],
      totalPosts: json['totalPosts'],
      list: parsedList,
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
      dataKey: serializedList,
    };
  }

  AppResponse2<T> copyWith({
    bool? success,
    String? message,
    int? currentPage,
    int? totalPages,
    int? totalPosts,
    List<T>? list,
  }) => AppResponse2<T>(
    success: success ?? this.success,
    message: message ?? this.message,
    currentPage: currentPage ?? this.currentPage,
    totalPages: totalPages ?? this.totalPages,
    totalPosts: totalPosts ?? this.totalPosts,
    list: list ?? this.list,
  );
  // /// Convenient copyWith
  // AppResponse2<T> copyWith({
  //   bool? success,
  //   String? message,
  //   int? currentPage,
  //   int? totalPages,
  //   int? totalPosts,
  //   List<T>? list,
  // }) => AppResponse2<T>(
  //   success: success ?? this.success,
  //   message: message ?? this.message,
  //   currentPage: currentPage ?? this.currentPage,
  //   totalPages: totalPages ?? this.totalPages,
  //   totalPosts: totalPosts ?? this.totalPosts,
  //   list: list ?? this.list,
  // );

  /// Check if response is successful
  bool get isSuccess => success == true;

  /// Check if response has data
  bool get hasData => list != null && list!.isNotEmpty;

  /// Check if there are more pages
  bool get hasMorePages =>
      currentPage != null && totalPages != null && currentPage! < totalPages!;

  /// Get current page (default to 1 if null)
  int get pageNumber => currentPage ?? 1;

  /// Get total items count
  int get itemsCount => totalPosts ?? (list?.length ?? 0);
}