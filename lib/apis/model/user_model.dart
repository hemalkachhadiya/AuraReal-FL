import 'package:aura_real/aura_real.dart';
class UserId {
  final Profile? profile;
  final String? id;
  final String? fullName;
  final String? email;
  final String? phoneNumber; // Renamed for consistency

  UserId({this.profile, this.id, this.fullName, this.email, this.phoneNumber});

  UserId copyWith({
    Profile? profile,
    String? id,
    String? fullName,
    String? email,
    String? phoneNumber,
  }) => UserId(
    profile: profile ?? this.profile,
    id: id ?? this.id,
    fullName: fullName ?? this.fullName,
    email: email ?? this.email,
    phoneNumber: phoneNumber ?? this.phoneNumber, // Fixed to use phoneNumber
  );

  factory UserId.fromJson(Map<String, dynamic> json) {
    return UserId(
      profile: json['profile'] != null ? Profile.fromJson(json['profile']) : null,
      id: json['_id'] as String?,
      fullName: json['full_name'] as String?,
      email: json['email'] as String?,
      phoneNumber: json['phone_number'] as String?, // Renamed for consistency
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profile': profile?.toJson(),
      '_id': id,
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber, // Renamed for consistency
    };
  }
}