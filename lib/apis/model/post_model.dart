import 'package:aura_real/aura_real.dart';

class PostModel {
  final String? id;
  final UserId? userId;
  final String? content;
  final String? postImage;
  final int? privacyLevel;
  final String? locationId;
  final Location? location;
  final Coordinates? coordinates;
  final int? commentsCount;
  final int? sharesCount;
  final bool? isDeleted;
  final List<String>? hashtags;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  PostModel({
    this.id,
    this.userId,
    this.content,
    this.postImage,
    this.privacyLevel,
    this.locationId,
    this.location,
    this.coordinates,
    this.commentsCount,
    this.sharesCount,
    this.isDeleted,
    this.hashtags,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    // Handle both cases for user_id: string or object
    UserId? userId;
    final userData = json['user_id'];

    if (userData != null) {
      if (userData is String) {
        // If user_id is a string, create a UserId with just the id
        userId = UserId(id: userData);
      } else if (userData is Map<String, dynamic>) {
        // If user_id is an object, parse it normally
        userId = UserId.fromJson(userData);
      }
    }

    return PostModel(
      id: json['_id'] as String?,
      userId: userId,
      content: json['content'] as String?,
      postImage: json['post_image'] as String?,
      privacyLevel: json['privacy_level'] as int?,
      locationId: json['location_id'] as String?,
      location: json['location'] != null ? Location.fromJson(json['location']) : null,
      coordinates: json['coordinates'] != null ? Coordinates.fromJson(json['coordinates']) : null,
      commentsCount: json['comments_count'] as int?,
      sharesCount: json['shares_count'] as int?,
      isDeleted: json['is_deleted'] as bool?,
      hashtags: json['hashtags'] != null ? List<String>.from(json['hashtags']) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
      v: json['__v'] as int?,
    );
  }

  PostModel copyWith({
    String? id,
    UserId? userId,
    String? content,
    String? postImage,
    int? privacyLevel,
    String? locationId,
    Location? location,
    Coordinates? coordinates,
    int? commentsCount,
    int? sharesCount,
    bool? isDeleted,
    List<String>? hashtags,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? v,
  }) =>
      PostModel(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        content: content ?? this.content,
        postImage: postImage ?? this.postImage,
        privacyLevel: privacyLevel ?? this.privacyLevel,
        locationId: locationId ?? this.locationId,
        location: location ?? this.location,
        coordinates: coordinates ?? this.coordinates,
        commentsCount: commentsCount ?? this.commentsCount,
        sharesCount: sharesCount ?? this.sharesCount,
        isDeleted: isDeleted ?? this.isDeleted,
        hashtags: hashtags ?? this.hashtags,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        v: v ?? this.v,
      );
}

class UserId {
  final Profile? profile;
  final String? id;
  final String? fullName;

  UserId({
    this.profile,
    this.id,
    this.fullName,
  });

  factory UserId.fromJson(Map<String, dynamic> json) {
    return UserId(
      profile: json['profile'] != null ? Profile.fromJson(json['profile']) : null,
      id: json['_id'] as String?,
      fullName: json['full_name'] as String?,
    );
  }

  // Additional constructor for when user_id is just a string
  UserId.fromString(String userIdString) : this(id: userIdString);

  UserId copyWith({
    Profile? profile,
    String? id,
    String? fullName,
  }) =>
      UserId(
        profile: profile ?? this.profile,
        id: id ?? this.id,
        fullName: fullName ?? this.fullName,
      );

  // Helper methods to safely access values
  String get safeId => id ?? '';
  String get safeFullName => fullName ?? 'Unknown User';
}


class Location {
  final double? latitude;
  final double? longitude;

  Location({
    this.latitude,
    this.longitude,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  Location copyWith({
    double? latitude,
    double? longitude,
  }) =>
      Location(
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
      );
}

class Coordinates {
  final String? type;
  final List<double>? coordinates;

  Coordinates({
    this.type,
    this.coordinates,
  });

  factory Coordinates.fromJson(Map<String, dynamic> json) {
    return Coordinates(
      type: json['type'] as String?,
      coordinates: json['coordinates'] != null ? List<double>.from(json['coordinates'].map((x) => (x as num).toDouble())) : null,
    );
  }

  Coordinates copyWith({
    String? type,
    List<double>? coordinates,
  }) =>
      Coordinates(
        type: type ?? this.type,
        coordinates: coordinates ?? this.coordinates,
      );
}