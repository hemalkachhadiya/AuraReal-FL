import 'package:aura_real/aura_real.dart';


class RatingProfileUserModel {
  final String? id;
  final String? fullName;
  final String? email;
  final String? phoneNumber;
  final Profile? profile;
  final bool? isVerified;
  final int? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;
  final String? isOtpType;
  final bool? isOnline;
  final dynamic deviceToken;
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final bool? isCurrent;
  final double? distance;

  RatingProfileUserModel({
    this.id,
    this.fullName,
    this.email,
    this.phoneNumber,
    this.profile,
    this.isVerified,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.isOtpType,
    this.isOnline,
    this.deviceToken,
    this.latitude,
    this.longitude,
    this.address,
    this.city,
    this.state,
    this.country,
    this.isCurrent,
    this.distance,
  });

  RatingProfileUserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    Profile? profile,
    bool? isVerified,
    int? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? v,
    String? isOtpType,
    bool? isOnline,
    dynamic deviceToken,
    double? latitude,
    double? longitude,
    String? address,
    String? city,
    String? state,
    String? country,
    bool? isCurrent,
    double? distance,
  }) =>
      RatingProfileUserModel(
        id: id ?? this.id,
        fullName: fullName ?? this.fullName,
        email: email ?? this.email,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        profile: profile ?? this.profile,
        isVerified: isVerified ?? this.isVerified,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        v: v ?? this.v,
        isOtpType: isOtpType ?? this.isOtpType,
        isOnline: isOnline ?? this.isOnline,
        deviceToken: deviceToken ?? this.deviceToken,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        address: address ?? this.address,
        city: city ?? this.city,
        state: state ?? this.state,
        country: country ?? this.country,
        isCurrent: isCurrent ?? this.isCurrent,
        distance: distance ?? this.distance,
      );

  factory RatingProfileUserModel.fromJson(Map<String, dynamic> json) {
    return RatingProfileUserModel(
      id: json['_id'] as String?,
      fullName: json['full_name'] as String?,
      email: json['email'] as String?,
      phoneNumber: json['phone_number'] as String?,
      profile: json['profile'] != null ? Profile.fromJson(json['profile']) : null,
      isVerified: json['is_verified'] as bool?,
      status: json['status'] as int?,
      // Safer DateTime parsing with null check
      createdAt: json['createdAt'] != null
          ? _parseDateTime(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? _parseDateTime(json['updatedAt'])
          : null,
      v: json['__v'] as int?,
      isOtpType: json['is_otp_type'] as String?,
      isOnline: json['isOnline'] as bool?,
      deviceToken: json['device_token'], // Can be null or any type
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      address: json['address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
      isCurrent: json['is_current'] as bool?,
      distance: json['distance'] != null ? (json['distance'] as num).toDouble() : null,
    );
  }


  // Helper method for safe DateTime parsing (same as PostModel)
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
      '_id': id,
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'profile': profile?.toJson(),
      'is_verified': isVerified,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      '__v': v,
      'is_otp_type': isOtpType,
      'isOnline': isOnline,
      'device_token': deviceToken,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'is_current': isCurrent,
      'distance': distance,
    };
  }

  // Helper getters for common use cases
  String get displayName => fullName ?? email ?? phoneNumber ?? 'Unknown User';

  String get userLocation {
    if (address?.isNotEmpty == true) return address!;
    if (city?.isNotEmpty == true && state?.isNotEmpty == true) {
      return '$city, $state';
    }
    if (city?.isNotEmpty == true) return city!;
    if (state?.isNotEmpty == true) return state!;
    return country ?? 'Unknown Location';
  }

  bool get hasLocation => latitude != null && longitude != null;

  bool get isActiveUser => status == 1 && isVerified == true;

  String get profileImageUrl => profile?.profileImage ?? '';

  String get username => profile?.username ?? '';

  double get ratingsAverage => profile?.ratingsAvg ?? 0.0;

  // int get followersCount => profile?.followersCount ?? 0;

  int get followingCount => profile?.followingCount ?? 0;

  int get totalPosts => profile?.totalPosts ?? 0;
}