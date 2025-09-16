class ChatRoomModel {
  final String? id;
  final List<String>? participants;
  final String? chatRoomId;
  final String? createdBy;
  final int? unreadCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  ChatRoomModel({
    this.id,
    this.participants,
    this.chatRoomId,
    this.createdBy,
    this.unreadCount,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    return ChatRoomModel(
      id: json['_id'] as String?,
      participants: (json['participants'] as List<dynamic>?)?.cast<String>(),
      chatRoomId: json['chatRoomId'] as String?,
      createdBy: json['createdBy'] as String?,
      unreadCount: json['unreadCount'] as int?,
      createdAt: json['createdAt'] != null
          ? _parseDateTime(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? _parseDateTime(json['updatedAt'])
          : null,
      v: json['__v'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'participants': participants,
      'chatRoomId': chatRoomId,
      'createdBy': createdBy,
      'unreadCount': unreadCount,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      '__v': v,
    };
  }

  ChatRoomModel copyWith({
    String? id,
    List<String>? participants,
    String? chatRoomId,
    String? createdBy,
    int? unreadCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? v,
  }) {
    return ChatRoomModel(
      id: id ?? this.id,
      participants: participants ?? this.participants,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      createdBy: createdBy ?? this.createdBy,
      unreadCount: unreadCount ?? this.unreadCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      v: v ?? this.v,
    );
  }

  // Helper method for safe DateTime parsing
  static DateTime? _parseDateTime(dynamic value) {
    try {
      if (value is String && value.isNotEmpty) {
        return DateTime.tryParse(value);
      }
    } catch (e) {
      print('Error parsing DateTime: $e');
    }
    return null;
  }
}