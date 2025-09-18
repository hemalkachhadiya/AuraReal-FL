import 'package:aura_real/apis/model/user_model.dart';

class NotificationModel {
  final String? id;
  final UserId? userId;
  final String? title;
  final String? body;
  final Data? data;
  final int? type;
  final bool? isDeleted;
  final DateTime? notificationModelCreatedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  NotificationModel({
    this.id,
    this.userId,
    this.title,
    this.body,
    this.data,
    this.type,
    this.isDeleted,
    this.notificationModelCreatedAt,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  NotificationModel copyWith({
    String? id,
    UserId? userId,
    String? title,
    String? body,
    Data? data,
    int? type,
    bool? isDeleted,
    DateTime? notificationModelCreatedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? v,
  }) =>
      NotificationModel(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        title: title ?? this.title,
        body: body ?? this.body,
        data: data ?? this.data,
        type: type ?? this.type,
        isDeleted: isDeleted ?? this.isDeleted,
        notificationModelCreatedAt: notificationModelCreatedAt ?? this.notificationModelCreatedAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        v: v ?? this.v,
      );

  /// Factory constructor for parsing JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] as String?,
      userId: json['user_id'] != null ? UserId.fromJson(json['user_id']) : null,
      title: json['title'] as String?,
      body: json['body'] as String?,
      data: json['data'] != null ? Data.fromJson(json['data']) : null,
      type: json['type'] as int?,
      isDeleted: json['is_deleted'] as bool?,
      notificationModelCreatedAt: _parseDateTime(json['notification_model_created_at']),
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
      v: json['__v'] as int?,
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user_id': userId?.toJson(),
      'title': title,
      'body': body,
      'data': data?.toJson(),
      'type': type,
      'is_deleted': isDeleted,
      'notification_model_created_at': notificationModelCreatedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      '__v': v,
    };
  }

  /// Safe DateTime parsing
  static DateTime? _parseDateTime(dynamic value) {
    try {
      if (value is String && value.isNotEmpty) {
        return DateTime.tryParse(value);
      }
    } catch (e) {
      print("Error parsing DateTime: $e");
    }
    return null;
  }
}

class Data {
  final String? postId;
  final String? raterId;
  final String? userId;
  final UserId? followUserId;
  final String? dataPostId;
  final String? commentId;
  final dynamic parentCommentId;
  final String? commenterId;
  final String? rating;

  Data({
    this.postId,
    this.raterId,
    this.userId,
    this.followUserId,
    this.dataPostId,
    this.commentId,
    this.parentCommentId,
    this.commenterId,
    this.rating,
  });

  Data copyWith({
    String? postId,
    String? raterId,
    String? userId,
    UserId? followUserId,
    String? dataPostId,
    String? commentId,
    dynamic parentCommentId,
    String? commenterId,
    String? rating,
  }) =>
      Data(
        postId: postId ?? this.postId,
        raterId: raterId ?? this.raterId,
        userId: userId ?? this.userId,
        followUserId: followUserId ?? this.followUserId,
        dataPostId: dataPostId ?? this.dataPostId,
        commentId: commentId ?? this.commentId,
        parentCommentId: parentCommentId ?? this.parentCommentId,
        commenterId: commenterId ?? this.commenterId,
        rating: rating ?? this.rating,
      );

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      postId: json['post_id'] as String?,
      raterId: json['rater_id'] as String?,
      userId: json['user_id'] as String?,
      followUserId: json['follow_user_id'] != null ? UserId.fromJson(json['follow_user_id']) : null,
      dataPostId: json['data_post_id'] as String?,
      commentId: json['comment_id'] as String?,
      parentCommentId: json['parent_comment_id'],
      commenterId: json['commenter_id'] as String?,
      rating: json['rating'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'post_id': postId,
      'rater_id': raterId,
      'user_id': userId,
      'follow_user_id': followUserId?.toJson(),
      'data_post_id': dataPostId,
      'comment_id': commentId,
      'parent_comment_id': parentCommentId,
      'commenter_id': commenterId,
      'rating': rating,
    };
  }
}
