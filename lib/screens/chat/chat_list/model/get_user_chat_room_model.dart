import 'package:aura_real/apis/model/profile_model.dart';

class GetUserChatRoomModel {
  final String? id;
  final List<Participant>? participants;
  final String? chatRoomId;
  final String? createdBy;
  final int? unreadCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  GetUserChatRoomModel({
    this.id,
    this.participants,
    this.chatRoomId,
    this.createdBy,
    this.unreadCount,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory GetUserChatRoomModel.fromJson(Map<String, dynamic> json) {
    return GetUserChatRoomModel(
      id: json['_id'] as String?,
      participants: (json['participants'] as List<dynamic>?)
          ?.map((e) => Participant.fromJson(e as Map<String, dynamic>))
          .toList(),
      chatRoomId: json['chatRoomId'] as String?,
      createdBy: json['createdBy'] as String?,
      unreadCount: json['unreadCount'] as int?,
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
      'participants': participants?.map((e) => e.toJson()).toList(),
      'chatRoomId': chatRoomId,
      'createdBy': createdBy,
      'unreadCount': unreadCount,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      '__v': v,
    };
  }
}

class Participant {
  final Profile? profile;
  final String? id;
  final String? fullName;
  final String? phoneNumber;

  Participant({this.profile, this.id, this.fullName, this.phoneNumber});

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      profile: json['profile'] != null
          ? Profile.fromJson(json['profile'] as Map<String, dynamic>)
          : null,
      id: json['_id'] as String?,
      fullName: json['full_name'] as String?,
      phoneNumber: json['phone_number'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profile': profile?.toJson(),
      '_id': id,
      'full_name': fullName,
      'phone_number': phoneNumber,
    };
  }
}
