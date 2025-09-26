import 'package:aura_real/apis/model/user_model.dart';

class GetRatingProfileRatingModel {
  final String? id;
  final UserId? userId;
  final UserId? raterId;
  final int? rating;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  GetRatingProfileRatingModel({
    this.id,
    this.userId,
    this.raterId,
    this.rating,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  GetRatingProfileRatingModel copyWith({
    String? id,
    UserId? userId,
    UserId? raterId,
    int? rating,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? v,
  }) {
    return GetRatingProfileRatingModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      raterId: raterId ?? this.raterId,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      v: v ?? this.v,
    );
  }

  factory GetRatingProfileRatingModel.fromJson(Map<String, dynamic> json) {
    return GetRatingProfileRatingModel(
      id: json['_id'] as String?,

      userId:
      json['user_id'] != null ? UserId.fromJson(json['user_id']) : null,
      raterId:
      json['rater_id'] != null ? UserId.fromJson(json['rater_id']) : null,
      rating: json['rating'] as int?,
      createdAt: json['created_at'] != null
          ? _parseDateTime(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? _parseDateTime(json['updated_at'])
          : null,
      v: json['__v'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user_id': userId?.toJson(),
      'rater_id': raterId?.toJson(),
      'rating': rating,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      '__v': v,
    };
  }

  // Safe DateTime parser
  static DateTime? _parseDateTime(dynamic value) {
    try {
      if (value is String && value.isNotEmpty) {
        return DateTime.tryParse(value);
      }
    } catch (e) {
      print('Error parsing DateTime: $e');
    }
    return null;
  }
}


