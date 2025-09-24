class Profile {
  final String? username;
  final String? fullName;
  final String? phoneNumber;
  final String? profileImage;
  final String? email;
  final String? bio;
  int? followersCount;
  int? followingCount;
  final int? totalPosts;
  final double? ratingsAvg;
  final String? dateOfBirth;
  final int? gender;
  final String? website;
  final String? lastSeen; // Added last_seen field
  final bool? is_following;
  final bool? isOnline;

  Profile({
    this.username,
    this.fullName,
    this.profileImage,
    this.phoneNumber,
    this.email,
    this.bio,
    this.followersCount,
    this.followingCount,
    this.totalPosts,
    this.ratingsAvg,
    this.dateOfBirth,
    this.gender,
    this.website,
    this.is_following,
    this.isOnline,
    this.lastSeen, // Added last_seen field
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    username: json['username'] as String?,
    fullName: json['full_name'] as String?,
    profileImage: json['profile_image'] as String?,
    phoneNumber: json['phoneNumber'] as String?,
    email: json['email'] as String?,
    bio: json['bio'] as String?,
    followersCount: json['followers_count'] as int?,
    followingCount: json['following_count'] as int?,
    totalPosts: json['total_posts'] as int?,
    ratingsAvg:
        (json['ratings_avg'] is int
            ? (json['ratings_avg'] as int).toDouble()
            : json['ratings_avg'] as double?),
    dateOfBirth: json['date_of_birth'] as String?,
    gender: json['gender'] as int?,
    website: json['website'] as String?,
    is_following: json['is_following'] as bool?,
    isOnline: json['isOnline'] as bool? ?? json['is_online'] as bool?,
    lastSeen: json['last_seen'] as String?, // Added last_seen field
  );

  Map<String, dynamic> toJson() => {
    'username': username,
    'full_name': fullName,
    'profile_image': profileImage,
    'phoneNumber': phoneNumber,
    'email': email,
    'bio': bio,
    'followers_count': followersCount,
    'following_count': followingCount,
    'total_posts': totalPosts,
    'ratings_avg': ratingsAvg,
    'date_of_birth': dateOfBirth,
    'gender': gender,
    'website': website,
    'is_following': is_following,
    'isOnline': isOnline,
    'last_seen': lastSeen, // Added last_seen field
  };
}
