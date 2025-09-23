import 'package:aura_real/apis/model/user_model.dart';
import 'package:aura_real/aura_real.dart';

class GetAllMessageModel {
  final String? id;
  final String? chatRoomId;
  final UserId? sender;
  final UserId? receiver;
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
    this.sender,
    this.receiver,
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
      sender: _parseUserId(json['senderId']),
      receiver: _parseUserId(json['receiverId']),
      message: json['message'] as String?,
      messageType: json['messageType'] as String?,
      mediaUrl: json['mediaUrl'] as String?,
      readBy:
          (json['readBy'] as List<dynamic>?)?.map((e) => e as String).toList(),
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'])
              : null,
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.tryParse(json['updatedAt'])
              : null,
      v: json['__v'] as int?,
    );
  }

  // Helper method to parse UserId from dynamic value
  static UserId? _parseUserId(dynamic value) {
    if (value == null) {
      return null;
    } else if (value is Map<String, dynamic>) {
      return UserId.fromJson(value);
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'chatRoomId': chatRoomId,
      'senderId': sender?.toJson(),
      'receiverId': receiver?.toJson(),
      'message': message,
      'messageType': messageType,
      'mediaUrl': mediaUrl,
      'readBy': readBy,
      'created_at': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      '__v': v,
    };
  }

  // Convenience getters to get just the IDs (for backward compatibility)
  String? get senderId => sender?.id;

  String? get receiverId => receiver?.id;
}
