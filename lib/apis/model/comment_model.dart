import 'package:aura_real/apis/model/user_model.dart';

class CommentModel {
  final String? id;
  final String? postId;
  final UserId? userId;
  final String? parentCommentId;
  final String? content;
  final int? likesCount;
  final bool? isDeleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;
  final bool? isOptimistic; // Flag for optimistic comments
  final List<CommentModel>? replies; // 👈 nested replies

  CommentModel({
    this.id,
    this.postId,
    this.userId,
    this.parentCommentId,
    this.content,
    this.likesCount,
    this.isDeleted,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.isOptimistic = false,
    this.replies, // 👈 include in constructor
  });

  CommentModel copyWith({
    String? id,
    String? postId,
    UserId? userId,
    String? parentCommentId,
    String? content,
    int? likesCount,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? v,
    bool? isOptimistic,
    List<CommentModel>? replies,
  }) {
    return CommentModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      content: content ?? this.content,
      likesCount: likesCount ?? this.likesCount,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      v: v ?? this.v,
      isOptimistic: isOptimistic ?? this.isOptimistic,
      replies: replies ?? this.replies, // 👈 copy replies
    );
  }

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['_id'] as String?,
      postId: json['post_id'] as String?,
      userId: json['user_id'] != null
          ? UserId.fromJson(json['user_id'] as Map<String, dynamic>)
          : null,
      parentCommentId: json['parent_comment_id'] as String?,
      content: json['content'] as String?,
      likesCount: json['likes_count'] as int?,
      isDeleted: json['is_deleted'] as bool?,
      createdAt: json['created_at'] != null ? _parseDateTime(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? _parseDateTime(json['updated_at']) : null,
      v: json['__v'] as int?,
      isOptimistic: json['isOptimistic'] as bool? ?? false,
      replies: (json['replies'] as List<dynamic>?)
          ?.map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
          .toList(), // 👈 parse nested replies
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    try {
      if (value is String && value.isNotEmpty) {
        return DateTime.tryParse(value) ?? DateTime.parse(value);
      }
    } catch (e) {
      print('Error parsing DateTime: $e');
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'post_id': postId,
      'user_id': userId?.toJson(),
      'parent_comment_id': parentCommentId,
      'content': content,
      'likes_count': likesCount,
      'is_deleted': isDeleted,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      '__v': v,
      'isOptimistic': isOptimistic,
      'replies': replies?.map((e) => e.toJson()).toList(), // 👈 export nested replies
    };
  }
}
