class AppResponse3<T> {
  final bool success;
  final String? message;
  final List<T>? data;
  final Pagination? pagination;

  AppResponse3({
    required this.success,
    this.message,
    this.data,
    this.pagination,
  });

  factory AppResponse3.fromJson(
      Map<String, dynamic> json,
      T Function(Map<String, dynamic>) fromJsonT,
      ) {
    return AppResponse3<T>(
      success: json['success'] ?? false,
      message: json['message'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => fromJsonT(e as Map<String, dynamic>))
          .toList(),
      pagination: json['pagination'] != null
          ? Pagination.fromJson(json['pagination'])
          : null,
    );
  }

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonT) {
    return {
      'success': success,
      'message': message,
      'data': data?.map((e) => toJsonT(e)).toList(),
      'pagination': pagination?.toJson(),
    };
  }
}

class Pagination {
  final int? total;
  final int? page;
  final int? limit;
  final int? totalPages;

  Pagination({this.total, this.page, this.limit, this.totalPages});

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      total: json['total'] as int?,
      page: json['page'] as int?,
      limit: json['limit'] as int?,
      totalPages: json['totalPages'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'page': page,
      'limit': limit,
      'totalPages': totalPages,
    };
  }
}
