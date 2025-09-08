class GoogleLoginRes {
  String? email;
  String? googleId;
  Profile? profile;
  bool? isVerified;
  int? status;
  String? token;
  String? sId;
  String? createdAt;
  String? updatedAt;
  int? iV;

  GoogleLoginRes({
    this.email,
    this.googleId,
    this.profile,
    this.isVerified,
    this.status,
    this.token,
    this.sId,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  GoogleLoginRes.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    googleId = json['googleId'];
    profile =
        json['profile'] != null ? new Profile.fromJson(json['profile']) : null;
    isVerified = json['is_verified'];
    status = json['status'];
    token = json['token'];
    sId = json['_id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['email'] = this.email;
    data['googleId'] = this.googleId;
    if (this.profile != null) {
      data['profile'] = this.profile!.toJson();
    }
    data['is_verified'] = this.isVerified;
    data['status'] = this.status;
    data['token'] = this.token;
    data['_id'] = this.sId;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}

class Profile {
  int? followersCount;
  int? totalPosts;
  int? ratingsAvg;
  int? gender;

  Profile({this.followersCount, this.totalPosts, this.ratingsAvg, this.gender});

  Profile.fromJson(Map<String, dynamic> json) {
    followersCount = json['followers_count'];
    totalPosts = json['total_posts'];
    ratingsAvg = json['ratings_avg'];
    gender = json['gender'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['followers_count'] = this.followersCount;
    data['total_posts'] = this.totalPosts;
    data['ratings_avg'] = this.ratingsAvg;
    data['gender'] = this.gender;
    return data;
  }
}
