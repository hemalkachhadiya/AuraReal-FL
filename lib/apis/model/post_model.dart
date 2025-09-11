import 'package:aura_real/aura_real.dart';

class PostModel {
  final Location? location;
  final GeoLocation? geoLocation;
  final String? id;
  final UserId? userId;
  final String? content;
  final String? postImage;
  final int? privacyLevel;
  final String? locationId;
  final double? postRating;
  final int? commentsCount;
  final int? sharesCount;
  final bool? isDeleted;
  final List<dynamic>? hashtags;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  PostModel({
    this.location,
    this.geoLocation,
    this.id,
    this.userId,
    this.content,
    this.postImage,
    this.privacyLevel,
    this.locationId,
    this.postRating,
    this.commentsCount,
    this.sharesCount,
    this.isDeleted,
    this.hashtags,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  PostModel copyWith({
    Location? location,
    GeoLocation? geoLocation,
    String? id,
    UserId? userId,
    String? content,
    String? postImage,
    int? privacyLevel,
    String? locationId,
    double? postRating,
    int? commentsCount,
    int? sharesCount,
    bool? isDeleted,
    List<dynamic>? hashtags,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? v,
  }) => PostModel(
    location: location ?? this.location,
    geoLocation: geoLocation ?? this.geoLocation,
    id: id ?? this.id,
    userId: userId ?? this.userId,
    content: content ?? this.content,
    postImage: postImage ?? this.postImage,
    privacyLevel: privacyLevel ?? this.privacyLevel,
    locationId: locationId ?? this.locationId,
    postRating: postRating ?? this.postRating,
    commentsCount: commentsCount ?? this.commentsCount,
    sharesCount: sharesCount ?? this.sharesCount,
    isDeleted: isDeleted ?? this.isDeleted,
    hashtags: hashtags ?? this.hashtags,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    v: v ?? this.v,
  );

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      location:
      json['location'] != null ? Location.fromJson(json['location']) : null,
      geoLocation:
      json['geo_location'] != null ? GeoLocation.fromJson(json['geo_location']) : null,
      id: json['_id'] as String?,
      userId: json['user_id'] != null ? UserId.fromJson(json['user_id']) : null,
      content: json['content'] as String?,
      postImage: json['post_image'] as String?,
      privacyLevel: json['privacy_level'] as int?,
      locationId: json['location_id'] as String?,
      postRating: (json['post_rating'] as num?)?.toDouble(),
      commentsCount: json['comments_count'] as int?,
      sharesCount: json['shares_count'] as int?,
      isDeleted: json['is_deleted'] as bool?,
      hashtags: json['hashtags'] as List<dynamic>?,
      // Safer DateTime parsing with null check
      createdAt: json['created_at'] != null
          ? _parseDateTime(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? _parseDateTime(json['updated_at'])
          : null,
      v: json['__v'] as int?,
    );
  }

  // Helper method for safe DateTime parsing
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

  Map<String, dynamic> toJson() {
    return {
      'location': location?.toJson(),
      'geo_location': geoLocation?.toJson(),
      '_id': id,
      'user_id': userId?.toJson(),
      'content': content,
      'post_image': postImage,
      'privacy_level': privacyLevel,
      'location_id': locationId,
      'post_rating': postRating,
      'comments_count': commentsCount,
      'shares_count': sharesCount,
      'is_deleted': isDeleted,
      'hashtags': hashtags,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      '__v': v,
    };
  }
}

class GeoLocation {
  final String? type;
  final List<double>? coordinates;

  GeoLocation({this.type, this.coordinates});

  GeoLocation copyWith({String? type, List<double>? coordinates}) =>
      GeoLocation(
        type: type ?? this.type,
        coordinates: coordinates ?? this.coordinates,
      );

  factory GeoLocation.fromJson(Map<String, dynamic> json) {
    return GeoLocation(
      type: json['type'] as String?,
      coordinates: (json['coordinates'] as List<dynamic>?)?.map((e) {
        if (e is num) return e.toDouble();
        return null; // Handle invalid values
      }).whereType<double>().toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'type': type, 'coordinates': coordinates};
  }
}

class Location {
  final double? latitude;
  final double? longitude;

  Location({this.latitude, this.longitude});

  Location copyWith({double? latitude, double? longitude}) => Location(
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
  );

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'latitude': latitude, 'longitude': longitude};
  }
}

class UserId {
  final Profile? profile;
  final String? id;
  final String? fullName;

  UserId({this.profile, this.id, this.fullName});

  UserId copyWith({Profile? profile, String? id, String? fullName}) => UserId(
    profile: profile ?? this.profile,
    id: id ?? this.id,
    fullName: fullName ?? this.fullName,
  );

  factory UserId.fromJson(Map<String, dynamic> json) {
    return UserId(
      profile:
      json['profile'] != null ? Profile.fromJson(json['profile']) : null,
      id: json['_id'] as String?,
      fullName: json['full_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'profile': profile?.toJson(), '_id': id, 'full_name': fullName};
  }
}