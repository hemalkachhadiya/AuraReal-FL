import 'package:aura_real/apis/model/user_model.dart';

class NotificationModel {
  String? sId;
  UserId? userId;
  String? title;
  String? body;
  Data? data;
  int? type;
  bool? isDeleted;
  String? createdAt;
  String? updatedAt;
  int? iV;

  NotificationModel({
    this.sId,
    this.userId,
    this.title,
    this.body,
    this.data,
    this.type,
    this.isDeleted,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  NotificationModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userId =
        json['user_id'] != null ? new UserId.fromJson(json['user_id']) : null;
    title = json['title'];
    body = json['body'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    type = json['type'];
    isDeleted = json['is_deleted'];
    createdAt = json['created_at'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    if (this.userId != null) {
      data['user_id'] = this.userId!.toJson();
    }
    data['title'] = this.title;
    data['body'] = this.body;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['type'] = this.type;
    data['is_deleted'] = this.isDeleted;
    data['created_at'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}

class Data {
  String? postId;
  String? raterId;

  Data({this.postId, this.raterId});

  Data.fromJson(Map<String, dynamic> json) {
    postId = json['postId'];
    raterId = json['raterId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['postId'] = this.postId;
    data['raterId'] = this.raterId;
    return data;
  }
}
