import 'package:aura_real/aura_real.dart';
import 'package:flutter/material.dart';

class Message {
  final String id;
  final String text;
  final DateTime timestamp;
  final bool isFromMe;
  final MessageStatus status;

  Message({
    required this.id,
    required this.text,
    required this.timestamp,
    required this.isFromMe,
    this.status = MessageStatus.sent,
  });

  Message copyWith({MessageStatus? status}) {
    return Message(
      id: id,
      text: text,
      timestamp: timestamp,
      isFromMe: isFromMe,
      status: status ?? this.status,
    );
  }
}

enum MessageStatus { sending, sent, delivered, read, failed }

class ChatUser {
  final String? id;
  final String? name;
  final String? avatarUrl;
  final bool isOnline;
  final DateTime? lastSeen;

  ChatUser({
    this.id,
    this.name,
    this.avatarUrl,
    this.isOnline = false,
    this.lastSeen,
  });

  ChatUser copyWith({
    String? name,
    String? avatarUrl,
    bool? isOnline,
    DateTime? lastSeen,
  }) {
    return ChatUser(
      id: id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}

class MessageProvider extends ChangeNotifier {
  MessageProvider() {
    // init(); // Don't call init here; call explicitly in the screen
  }

  List<Message> messages = [];
  ChatUser? currentUser;
  bool isLoading = false;
  bool isTyping = false;
  String messageText = '';
  String? chatRoomId;
  bool loader = false;

  /// Call this when screen opens
  Future<void> initializeChat({
    required ChatUser user,
    required String roomId,
  }) async {
    currentUser = user;
    chatRoomId = roomId;

    // ✅ Fetch profile to update online status
    await getCurrentUserProfileAPI();

    // ✅ Fetch messages
    await getAllMessageList(roomId);
  }

  /// Fetch the latest profile for the current user
  Future<void> getCurrentUserProfileAPI() async {
    if (currentUser == null || currentUser?.id == null) return;

    loader = true;
    notifyListeners();

    print("Get Current Profile ---- ${currentUser?.id}");

    final result = await AuthApis.getUserProfile(userId: currentUser!.id!);

    if (result != null) {
      print("Current user online status: ${result.isOnline}");
      currentUser = currentUser?.copyWith(
        isOnline: result.isOnline ?? false,
        name: result.username,
        avatarUrl: result.profileImage,
        // lastSeen: result.lastSeen,
      );
      notifyListeners();
    }

    loader = false;
    notifyListeners();
  }

  /// Get all messages for the chat room
  Future<void> getAllMessageList(String chatRoomId) async {
    isLoading = true;
    notifyListeners();

    final response = await ChatApis.getAllMessages(chatRoomId: chatRoomId);

    if (response != null && response.data != null) {
      messages =
          response.data!
              .map(
                (GetAllMessageModel msg) => Message(
                  id: msg.id ?? "",
                  text: msg.message ?? "",
                  timestamp: msg.createdAt ?? DateTime.now(),
                  isFromMe: msg.sender?.id == userData?.id,
                  status:
                      (msg.readBy?.contains(userData?.id) ?? false)
                          ? MessageStatus.read
                          : MessageStatus.sent,
                ),
              )
              .toList();
    } else {
      messages = [];
    }

    isLoading = false;
    notifyListeners();
  }

  void sendMessage({String? receiverId}) {
    if (messageText.trim().isEmpty) return;

    final newMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: messageText.trim(),
      timestamp: DateTime.now(),
      isFromMe: true,
      status: MessageStatus.sending,
    );

    messages.add(newMessage);
    notifyListeners();

    socketIoHelper.sendMessage(
      text: newMessage.text,
      roomId: chatRoomId ?? "",
      messageType: "text",
      receiverId: currentUser?.id ?? "",
      senderId: userData?.id.toString() ?? "",
    );

    _updateMessageStatus(newMessage.id, MessageStatus.sent);
    messageText = '';
    notifyListeners();
  }

  void _updateMessageStatus(String messageId, MessageStatus status) {
    final index = messages.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      messages[index] = messages[index].copyWith(status: status);
      notifyListeners();
    }
  }

  void handleNewMessage(dynamic data) {
    final msg = Message(
      id: data["_id"] ?? DateTime.now().toString(),
      text: data["message"] ?? "",
      timestamp: DateTime.tryParse(data["createdAt"] ?? "") ?? DateTime.now(),
      isFromMe: data["senderId"] == userData?.id,
      status: MessageStatus.sent,
    );
    messages.add(msg);
    notifyListeners();
  }

  void handleDelivered(String messageId) {
    _updateMessageStatus(messageId, MessageStatus.delivered);
  }

  void handleRead(String messageId) {
    _updateMessageStatus(messageId, MessageStatus.read);
  }

  void markAllAsRead() {
    for (int i = 0; i < messages.length; i++) {
      if (!messages[i].isFromMe && messages[i].status != MessageStatus.read) {
        messages[i] = messages[i].copyWith(status: MessageStatus.read);
      }
    }
    notifyListeners();
  }

  void updateMessageText(String text) {
    messageText = text;
    notifyListeners();
  }

  bool get canSendMessage => messageText.trim().isNotEmpty;

  void clearMessages() {
    messages.clear();
    notifyListeners();
  }

  String formatMessageTime(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(
      timestamp.year,
      timestamp.month,
      timestamp.day,
    );

    if (messageDate == today) {
      final hour = timestamp.hour % 12 == 0 ? 12 : timestamp.hour % 12;
      final minute = timestamp.minute.toString().padLeft(2, '0');
      final period = timestamp.hour >= 12 ? 'PM' : 'AM';
      return "$hour:$minute $period";
    }

    if (messageDate == yesterday) {
      return "Yesterday";
    }

    return "${timestamp.day.toString().padLeft(2, '0')}/"
        "${timestamp.month.toString().padLeft(2, '0')}/"
        "${timestamp.year}";
  }

  IconData getStatusIcon(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return Icons.access_time;
      case MessageStatus.sent:
        return Icons.check;
      case MessageStatus.delivered:
        return Icons.done_all;
      case MessageStatus.read:
        return Icons.done_all;
      case MessageStatus.failed:
        return Icons.error_outline;
    }
  }

  Color getStatusColor(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
      case MessageStatus.sent:
      case MessageStatus.delivered:
        return Colors.grey;
      case MessageStatus.read:
        return Colors.blue;
      case MessageStatus.failed:
        return Colors.red;
    }
  }
}
