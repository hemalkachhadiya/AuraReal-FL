import 'package:aura_real/aura_real.dart';

/// ----------  Helpers to encode / decode  ----------
AppResponse<T> appResponseFromJson<T>(
    String str, {
      T Function(Map<String, dynamic>)? converter,
    }) => AppResponse.fromJson(json.decode(str), converter: converter);

String appResponseToJson<T>(
    AppResponse<T> response, {
      Map<String, dynamic> Function(T)? converter,
    }) => json.encode(response.toJson(converter: converter));

/// ----------  Generic Response Wrapper  ----------
class AppResponse<T> {
  bool? success;
  String? message;
  T? data;

  AppResponse({this.success, this.message, this.data});

  factory AppResponse.fromJson(
      Map<String, dynamic> json, {
        T Function(Map<String, dynamic>)? converter,
      }) => AppResponse(
    success: json['success'],
    message: json['message'],
    data:
    json['data'] is T
        ? json['data'] // Already the right type
        : (converter != null &&
        json['data'] != null // Needs conversion
        ? converter(json['data'])
        : null),
  );

  Map<String, dynamic> toJson({
    Map<String, dynamic> Function(T)? converter,
  }) => {
    'success': success,
    'message': message,
    'data':
    data is Map
        ? data
        : (converter != null && data != null ? converter(data as T) : null),
  };

  /// Convenient copyWith
  AppResponse<T> copyWith({bool? success, String? message, T? data}) =>
      AppResponse(
        success: success ?? this.success,
        message: message ?? this.message,
        data: data ?? this.data,
      );
}

class PaginationModel {
  int? page;
  int? limit;
  int? total;

  PaginationModel({this.page, this.limit, this.total});

  factory PaginationModel.fromJson(Map<String, dynamic> json) =>
      PaginationModel(
        page: json['page'],
        limit: json['limit'],
        total: json['total'],
      );

  Map<String, dynamic> toJson() => {
    'page': page,
    'limit': limit,
    'total': total,
  };

  /// Convenient copyWith
  PaginationModel copyWith({int? page, int? limit, int? total}) =>
      PaginationModel(
        page: page ?? this.page,
        limit: limit ?? this.limit,
        total: total ?? this.total,
      );
}