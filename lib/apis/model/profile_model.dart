class Profile {
  final String? username;
  final String? profileImage;
  final String? email;
  final String? bio;
  final int? followersCount;
  final int? totalPosts;
  final double? ratingsAvg;
  final String? dateOfBirth;
  final int? gender;
  final String? website;
  final String? lastSeen; // Added last_seen field

  Profile({
    this.username,
    this.profileImage,
    this.email,
    this.bio,
    this.followersCount,
    this.totalPosts,
    this.ratingsAvg,
    this.dateOfBirth,
    this.gender,
    this.website,
    this.lastSeen, // Added last_seen field
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    username: json['username'] as String?,
    profileImage: json['profile_image'] as String?,
    email: json['email'] as String?,
    bio: json['bio'] as String?,
    followersCount: json['followers_count'] as int?,
    totalPosts: json['total_posts'] as int?,
    ratingsAvg: (json['ratings_avg'] is int
        ? (json['ratings_avg'] as int).toDouble()
        : json['ratings_avg'] as double?),
    dateOfBirth: json['date_of_birth'] as String?,
    gender: json['gender'] as int?,
    website: json['website'] as String?,
    lastSeen: json['last_seen'] as String?, // Added last_seen field
  );

  Map<String, dynamic> toJson() => {
    'username': username,
    'profile_image': profileImage,
    'email': email,
    'bio': bio,
    'followers_count': followersCount,
    'total_posts': totalPosts,
    'ratings_avg': ratingsAvg,
    'date_of_birth': dateOfBirth,
    'gender': gender,
    'website': website,
    'last_seen': lastSeen, // Added last_seen field
  };

  /// Convenient copyWith
  Profile copyWith({
    String? username,
    String? profileImage,
    String? email,
    String? bio,
    int? followersCount,
    int? totalPosts,
    double? ratingsAvg,
    String? dateOfBirth,
    int? gender,
    String? website,
    String? lastSeen, // Added last_seen field
  }) => Profile(
    username: username ?? this.username,
    profileImage: profileImage ?? this.profileImage,
    email: email ?? this.email,
    bio: bio ?? this.bio,
    followersCount: followersCount ?? this.followersCount,
    totalPosts: totalPosts ?? this.totalPosts,
    ratingsAvg: ratingsAvg ?? this.ratingsAvg,
    dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    gender: gender ?? this.gender,
    website: website ?? this.website,
    lastSeen: lastSeen ?? this.lastSeen, // Added last_seen field
  );


  // Helper getters for safe access with default values
  String get safeUsername => username ?? 'Unknown';
  String get safeProfileImage => profileImage ?? '';
  String get safeEmail => email ?? '';
  String get safeBio => bio ?? '';
  int get safeFollowersCount => followersCount ?? 0;
  int get safeTotalPosts => totalPosts ?? 0;
  double get safeRatingsAvg => ratingsAvg ?? 0.0;
  String get safeDateOfBirth => dateOfBirth ?? '';
  int get safeGender => gender ?? 0;
  String get safeWebsite => website ?? '';
  String get safeLastSeen => lastSeen ?? ''; // Added last_seen field
}