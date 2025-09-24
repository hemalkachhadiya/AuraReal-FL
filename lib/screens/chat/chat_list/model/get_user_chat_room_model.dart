import 'package:aura_real/apis/model/profile_model.dart';

class GetUserChatRoomModel {
  final String? id;
  final List<Participant>? participants;
  final String? chatRoomId;
  final String? createdBy;
  final Map<String, int>? unreadCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;
  final DateTime? latestMessageTime; // ✅ Added missing field
  final String? latestMessage; // ✅ Added missing field
  final String? messageType; // ✅ Added missing field

  GetUserChatRoomModel({
    this.id,
    this.participants,
    this.chatRoomId,
    this.createdBy,
    this.unreadCount,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.latestMessageTime,
    this.latestMessage,
    this.messageType,
  });

  factory GetUserChatRoomModel.fromJson(Map<String, dynamic> json) {
    return GetUserChatRoomModel(
      id: json['_id'] as String?,
      participants:
          (json['participants'] as List<dynamic>?)
              ?.map((e) => Participant.fromJson(e as Map<String, dynamic>))
              .toList(),
      chatRoomId: json['chatRoomId'] as String?,
      createdBy: json['createdBy'] as String?,
      unreadCount:
          json['unreadCount'] != null
              ? Map<String, int>.from(json['unreadCount'])
              : null,
      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'])
              : null,
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.tryParse(json['updatedAt'])
              : null,
      v: json['__v'] as int?,
      latestMessageTime:
          json['latestMessageTime'] != null
              ? DateTime.tryParse(json['latestMessageTime'])
              : null,
      latestMessage: json['latestMessage'] as String?,
      messageType: json['messageType'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'participants': participants?.map((e) => e.toJson()).toList(),
      'chatRoomId': chatRoomId,
      'createdBy': createdBy,
      'unreadCount': unreadCount,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      '__v': v,
      'latestMessageTime': latestMessageTime?.toIso8601String(),
      'latestMessage': latestMessage,
      'messageType': messageType,
    };
  }

  // Helper method to get unread count for a specific user
  int getUnreadCountForUser(String userId) {
    return unreadCount?[userId] ?? 0;
  }
}

class Participant {
  final String? id;
  final String? fullName;
  final String? phoneNumber;
  final Profile? profile;
  final bool? isOnline; // ✅ Added missing field

  Participant({
    this.id,
    this.fullName,
    this.phoneNumber,
    this.profile,
    this.isOnline,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['_id'] as String?,
      fullName: json['full_name'] as String?,
      phoneNumber: json['phone_number'] as String?,
      profile:
          json['profile'] != null
              ? Profile.fromJson(json['profile'] as Map<String, dynamic>)
              : null,
      isOnline: json['isOnline'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'profile': profile?.toJson(),
      'isOnline': isOnline,
    };
  }
}
