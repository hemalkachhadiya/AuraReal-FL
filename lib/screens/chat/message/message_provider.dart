import 'package:aura_real/aura_real.dart';

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

  ChatUser copyWith({bool? isOnline, DateTime? lastSeen}) {
    return ChatUser(
      id: id,
      name: name,
      avatarUrl: avatarUrl,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}

class MessageProvider extends ChangeNotifier {
  List<Message> messages = [];
  ChatUser? currentUser;
  bool isLoading = false;
  bool isTyping = false;
  String messageText = '';
  String? chatRoomId;

  Future<void> initializeChat({
    required ChatUser user,
    required String roomId,
  }) async {
    currentUser = user;
    chatRoomId = roomId;
    await getAllMessageList(roomId);
  }

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
                  isFromMe:
                      msg.sender?.id == userData?.id, // ✅ correct comparison
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

  // Future<void> getAllMessageList(String chatRoomId) async {
  //   isLoading = true;
  //   notifyListeners();
  //
  //   final response = await ChatApis.getAllMessages(chatRoomId: chatRoomId);
  //
  //   if (response != null && response.data != null) {
  //     messages = response.data!
  //         .map((msg) => Message(
  //       id: msg.id ?? "",
  //       text: msg.message ?? "",
  //       timestamp: msg.createdAt ?? DateTime.now(),
  //       isFromMe: msg.senderId == currentUser?.id,
  //       status: MessageStatus.sent,
  //     ))
  //         .toList();
  //   } else {
  //     messages = [];
  //   }
  //
  //   isLoading = false;
  //   notifyListeners();
  // }

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

  // 🔹 Socket event handlers
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

  String formatMessageTime(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    // Today → show time (like 2:15 PM)
    if (messageDate == today) {
      final hour = timestamp.hour % 12 == 0 ? 12 : timestamp.hour % 12;
      final minute = timestamp.minute.toString().padLeft(2, '0');
      final period = timestamp.hour >= 12 ? 'PM' : 'AM';
      return "$hour:$minute $period";
    }

    // Yesterday
    if (messageDate == yesterday) {
      return "Yesterday";
    }

    // Else → dd/MM/yyyy
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

  /// ✅ Update message text when user types
  void updateMessageText(String text) {
    messageText = text;
    notifyListeners();
  }

  /// ✅ Allow UI to check if send button should be enabled
  bool get canSendMessage => messageText.trim().isNotEmpty;

  Color getStatusColor(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return Colors.grey;
      case MessageStatus.sent:
        return Colors.grey;
      case MessageStatus.delivered:
        return Colors.grey;
      case MessageStatus.read:
        return Colors.blue;
      case MessageStatus.failed:
        return Colors.red;
    }
  }

  void clearMessages() {
    messages.clear();
    notifyListeners();
  }
}
