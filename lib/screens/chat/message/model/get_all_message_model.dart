import 'package:aura_real/aura_real.dart';

class GetAllMessageModel {
  final String? id;
  final String? chatRoomId;
  final String? senderId;
  final String? receiverId;
  final String? message;
  final String? messageType;
  final String? mediaUrl;
  final List<String>? readBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  GetAllMessageModel({
    this.id,
    this.chatRoomId,
    this.senderId,
    this.receiverId,
    this.message,
    this.messageType,
    this.mediaUrl,
    this.readBy,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory GetAllMessageModel.fromJson(Map<String, dynamic> json) {
    return GetAllMessageModel(
      id: json['_id'] as String?,
      chatRoomId: json['chatRoomId'] as String?,
      senderId: json['senderId'] as String?,
      receiverId: json['receiverId'] as String?,
      message: json['message'] as String?,
      messageType: json['messageType'] as String?,
      mediaUrl: json['mediaUrl'] as String?,
      readBy: (json['readBy'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
      v: json['__v'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'chatRoomId': chatRoomId,
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'messageType': messageType,
      'mediaUrl': mediaUrl,
      'readBy': readBy,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      '__v': v,
    };
  }
}
