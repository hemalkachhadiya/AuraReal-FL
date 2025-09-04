import 'package:aura_real/aura_real.dart';
class PostModel {
  final String id;
  final String userName;
  final String userProfileImage;
  final String postImage;
  final double rating;
  final int totalRatings;
  final String imageSize;
  final DateTime createdAt;
  int userRating; // User's personal rating (0-5)

  PostModel({
    required this.id,
    required this.userName,
    required this.userProfileImage,
    required this.postImage,
    required this.rating,
    required this.totalRatings,
    required this.imageSize,
    required this.createdAt,
    this.userRating = 0,
  });

  // Create a copy with updated values
  PostModel copyWith({
    String? id,
    String? userName,
    String? userProfileImage,
    String? postImage,
    double? rating,
    int? totalRatings,
    String? imageSize,
    DateTime? createdAt,
    int? userRating,
  }) {
    return PostModel(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      userProfileImage: userProfileImage ?? this.userProfileImage,
      postImage: postImage ?? this.postImage,
      rating: rating ?? this.rating,
      totalRatings: totalRatings ?? this.totalRatings,
      imageSize: imageSize ?? this.imageSize,
      createdAt: createdAt ?? this.createdAt,
      userRating: userRating ?? this.userRating,
    );
  }
}