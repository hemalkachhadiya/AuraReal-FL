import 'package:aura_real/apis/model/profile_model.dart';
import 'package:aura_real/aura_real.dart';

/// ---------- Helpers to encode / decode ----------
LoginRes loginResFromJson(String str) => LoginRes.fromJson(json.decode(str));

String loginResToJson(LoginRes data) => json.encode(data.toJson());

class LoginRes {
  final String? id; // Changed to nullable
  final String fullName;
  final String email;
  final String phoneNumber;
  final int status;
  final bool isVerified;
  final Profile profile;
  final String token;

  LoginRes({
    this.id, // Nullable, no 'required'
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.status,
    required this.isVerified,
    required this.profile,
    required this.token,
  });

  factory LoginRes.fromJson(Map<String, dynamic> json) => LoginRes(
    id: json['_id'] as String?, // Handle null from API
    fullName: json['full_name'] as String,
    email: json['email'] as String,
    phoneNumber: json['phone_number'] as String,
    status: json['status'] as int,
    isVerified: json['is_verified'] as bool,
    profile: Profile.fromJson(json['profile'] as Map<String, dynamic>),
    token: json['token'] as String,
  );

  Map<String, dynamic> toJson() => {
    if (id != null) '_id': id, // Only include id if not null
    'full_name': fullName,
    'email': email,
    'phone_number': phoneNumber,
    'status': status,
    'is_verified': isVerified,
    'profile': profile.toJson(),
    'token': token,
  };

  /// Convenient copyWith
  LoginRes copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    int? status,
    bool? isVerified,
    Profile? profile,
    String? token,
  }) => LoginRes(
    id: id ?? this.id,
    fullName: fullName ?? this.fullName,
    email: email ?? this.email,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    status: status ?? this.status,
    isVerified: isVerified ?? this.isVerified,
    profile: profile ?? this.profile,
    token: token ?? this.token,
  );
}