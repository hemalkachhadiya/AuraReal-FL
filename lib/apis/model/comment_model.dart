// Comment model
class Comment {
  final String id;
  final String username;
  final String content;
  final String timeAgo;
  final String? avatarUrl;
  final bool isAuthor;

  Comment({
    required this.id,
    required this.username,
    required this.content,
    required this.timeAgo,
    this.avatarUrl,
    this.isAuthor = false,
  });
}
//
// class CommentModel {
//   final String? id;
//   final String? postId;
//   final UserId? userId;
//   final dynamic parentCommentId;
//   final String? content;
//   final int? likesCount;
//   final bool? isDeleted;
//   final DateTime? createdAt;
//   final DateTime? updatedAt;
//   final int? v;
//
//   CommentModel({
//     this.id,
//     this.postId,
//     this.userId,
//     this.parentCommentId,
//     this.content,
//     this.likesCount,
//     this.isDeleted,
//     this.createdAt,
//     this.updatedAt,
//     this.v,
//   });
//
//   CommentModel copyWith({
//     String? id,
//     String? postId,
//     UserId? userId,
//     dynamic parentCommentId,
//     String? content,
//     int? likesCount,
//     bool? isDeleted,
//     DateTime? createdAt,
//     DateTime? updatedAt,
//     int? v,
//   }) => CommentModel(
//     id: id ?? this.id,
//     postId: postId ?? this.postId,
//     userId: userId ?? this.userId,
//     parentCommentId: parentCommentId ?? this.parentCommentId,
//     content: content ?? this.content,
//     likesCount: likesCount ?? this.likesCount,
//     isDeleted: isDeleted ?? this.isDeleted,
//     createdAt: createdAt ?? this.createdAt,
//     updatedAt: updatedAt ?? this.updatedAt,
//     v: v ?? this.v,
//   );
//
//   factory CommentModel.fromJson(Map<String, dynamic> json) {
//     return CommentModel(
//       id: json['_id'] as String?,
//       postId: json['post_id'] as String?,
//       userId: json['user_id'] != null ? UserId.fromJson(json['user_id']) : null,
//       parentCommentId: json['parent_comment_id'],
//       content: json['content'] as String?,
//       likesCount: json['likes_count'] as int?,
//       isDeleted: json['is_deleted'] as bool?,
//       createdAt: json['created_at'] != null
//           ? PostModel._parseDateTime(json['created_at'])
//           : null,
//       updatedAt: json['updated_at'] != null
//           ? PostModel._parseDateTime(json['updated_at'])
//           : null,
//       v: json['__v'] as int?,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       '_id': id,
//       'post_id': postId,
//       'user_id': userId?.toJson(),
//       'parent_comment_id': parentCommentId,
//       'content': content,
//       'likes_count': likesCount,
//       'is_deleted': isDeleted,
//       'created_at': createdAt?.toIso8601String(),
//       'updated_at': updatedAt?.toIso8601String(),
//       '__v': v,
//     };
//   }
// }