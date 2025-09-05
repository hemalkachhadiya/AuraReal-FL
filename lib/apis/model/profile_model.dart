class Profile {
  final String username;
  final String profileImage;
  final String? bio;
  final int followersCount;
  final int totalPosts;
  final int ratingsAvg;
  final String dateOfBirth;
  final int gender;
  final String website;

  Profile({
    required this.username,
    required this.profileImage,
    this.bio,
    required this.followersCount,
    required this.totalPosts,
    required this.ratingsAvg,
    required this.dateOfBirth,
    required this.gender,
    required this.website,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    username: json['username'],
    profileImage: json['profile_image'],
    bio: json['bio'],
    followersCount: json['followers_count'],
    totalPosts: json['total_posts'],
    ratingsAvg: json['ratings_avg'],
    dateOfBirth: json['date_of_birth'],
    gender: json['gender'],
    website: json['website'],
  );

  Map<String, dynamic> toJson() => {
    'username': username,
    'profile_image': profileImage,
    'bio': bio,
    'followers_count': followersCount,
    'total_posts': totalPosts,
    'ratings_avg': ratingsAvg,
    'date_of_birth': dateOfBirth,
    'gender': gender,
    'website': website,
  };

  /// Convenient copyWith
  Profile copyWith({
    String? username,
    String? profileImage,
    String? bio,
    int? followersCount,
    int? totalPosts,
    int? ratingsAvg,
    String? dateOfBirth,
    int? gender,
    String? website,
  }) => Profile(
    username: username ?? this.username,
    profileImage: profileImage ?? this.profileImage,
    bio: bio ?? this.bio,
    followersCount: followersCount ?? this.followersCount,
    totalPosts: totalPosts ?? this.totalPosts,
    ratingsAvg: ratingsAvg ?? this.ratingsAvg,
    dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    gender: gender ?? this.gender,
    website: website ?? this.website,
  );
}
