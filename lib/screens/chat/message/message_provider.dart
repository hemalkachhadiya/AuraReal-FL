import 'package:aura_real/aura_real.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart'; // Add dependency: flutter pub add uuid

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
  MessageProvider();

  List<Message> _messages = [];
  ChatUser? _currentUser;
  bool _isLoading = false;
  bool _isTyping = false;
  String _messageText = '';
  String? _chatRoomId;
  bool _loader = false;
  File? _selectedMedia;
  VideoPlayerController? _videoController;

  // Getters
  List<Message> get messages => _messages;
  ChatUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isTyping => _isTyping;
  String get messageText => _messageText;
  String? get chatRoomId => _chatRoomId;
  bool get loader => _loader;
  File? get selectedMedia => _selectedMedia;
  VideoPlayerController? get videoController => _videoController;

  Future<void> initializeChat({
    required ChatUser user,
    required String roomId,
  }) async {
    if (user.id == null || roomId.isEmpty) {
      debugPrint("❌ Cannot initialize chat: Invalid user ID or room ID");
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        const SnackBar(content: Text("Error: Invalid user or room ID")),
      );
      return;
    }

    _currentUser = user;
    _chatRoomId = roomId;

    // Connect socket with provider reference
    socketIoHelper.connectSocket(user.id!, roomId: roomId, provider: this);

    // Fetch profile to update online status
    await getCurrentUserProfileAPI();

    // Fetch messages
    await getAllMessageList(roomId);
  }

  Future<void> getCurrentUserProfileAPI() async {
    if (_currentUser == null || _currentUser?.id == null) {
      debugPrint("❌ No current user or user ID for profile fetch");
      return;
    }

    _loader = true;
    notifyListeners();

    debugPrint("Get Current Profile ---- ${_currentUser?.id}");

    try {
      final result = await AuthApis.getUserProfile(userId: _currentUser!.id!);
      if (result != null) {
        debugPrint("Current user online status: ${result.isOnline}");
        _currentUser = _currentUser?.copyWith(
          isOnline: result.isOnline ?? false,
          name: result.username,
          avatarUrl: result.profileImage,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint("❌ Error fetching user profile: $e");
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(content: Text("Failed to fetch user profile: $e")),
      );
    }

    _loader = false;
    notifyListeners();
  }

  Future<void> pickMedia() async {
    try {
      final File? mediaFile = await openMediaPicker(navigatorKey.currentContext!);
      if (mediaFile != null) {
        final mimeType = lookupMimeType(mediaFile.path);
        if (mimeType != null && mimeType.startsWith('video/')) {
          _selectedMedia = mediaFile;
          _videoController?.dispose();
          _videoController = VideoPlayerController.file(_selectedMedia!)
            ..initialize().then((_) {
              notifyListeners();
            });
        } else {
          _selectedMedia = mediaFile;
          _videoController?.dispose();
          _videoController = null;
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Error picking media: $e');
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(content: Text("Failed to pick media: $e")),
      );
    }
  }

  Future<void> getAllMessageList(String chatRoomId) async {
    if (chatRoomId.isEmpty) {
      debugPrint("❌ Cannot fetch messages: Invalid chat room ID");
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final response = await ChatApis.getAllMessages(chatRoomId: chatRoomId);
      if (response != null && response.data != null) {
        _messages = response.data!
            .map(
              (GetAllMessageModel msg) => Message(
            id: msg.id ?? const Uuid().v4(),
            text: msg.message ?? "",
            timestamp: msg.createdAt ?? DateTime.now(),
            isFromMe: msg.sender?.id == userData?.id,
            status: (msg.readBy?.contains(userData?.id) ?? false)
                ? MessageStatus.read
                : MessageStatus.sent,
          ),
        )
            .toList();
      } else {
        _messages = [];
      }
    } catch (e) {
      debugPrint("❌ Error fetching messages: $e");
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(content: Text("Failed to load messages: $e")),
      );
    }

    _isLoading = false;
    notifyListeners();
  }

  void sendMessage({String? receiverId}) {
    if (_messageText.trim().isEmpty ||
        _chatRoomId == null ||
        _chatRoomId!.isEmpty ||
        userData?.id == null ||
        receiverId == null ||
        receiverId.isEmpty) {
      debugPrint(
          "❌ Cannot send message: text=$_messageText, roomId=$_chatRoomId, senderId=${userData?.id}, receiverId=$receiverId");
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        const SnackBar(content: Text("Error: Invalid message or user data")),
      );
      return;
    }

    final newMessage = Message(
      id: const Uuid().v4(), // Use UUID for unique ID
      text: _messageText.trim(),
      timestamp: DateTime.now(),
      isFromMe: true,
      status: MessageStatus.sending,
    );

    _messages.add(newMessage);
    notifyListeners();

    debugPrint("📤 Sending message: ID=${newMessage.id}, text=${newMessage.text}");

    if (socketIoHelper.socketApp == null || !socketIoHelper.socketApp!.connected) {
      debugPrint("❌ Socket not connected, marking message as failed");
      _updateMessageStatus(newMessage.id, MessageStatus.failed);
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        const SnackBar(content: Text("Failed to send message: No connection")),
      );
      return;
    }

    socketIoHelper.sendMessage(
      text: newMessage.text,
      roomId: _chatRoomId!,
      messageType: "text",
      receiverId: receiverId,
      senderId: userData!.id!,
    );

    // Listen for server acknowledgment (if supported by your server)
    socketIoHelper.socketApp!.once("messageSent", (data) {
      debugPrint("✅ Server acknowledged message: $data");
      _updateMessageStatus(newMessage.id, MessageStatus.sent);
    });

    socketIoHelper.socketApp!.once("error", (error) {
      debugPrint("❌ Server error on sendMessage: $error");
      _updateMessageStatus(newMessage.id, MessageStatus.failed);
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(content: Text("Failed to send message: $error")),
      );
    });

    _messageText = '';
    notifyListeners();
  }

  void _updateMessageStatus(String messageId, MessageStatus status) {
    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      _messages[index] = _messages[index].copyWith(status: status);
      notifyListeners();
    }
  }

  void handleNewMessage(dynamic data) {
    debugPrint("📥 Handling new message in provider: $data");
    try {
      final msg = Message(
        id: data["_id"] ?? const Uuid().v4(),
        text: data["message"] ?? "",
        timestamp: DateTime.tryParse(data["createdAt"] ?? "") ?? DateTime.now(),
        isFromMe: data["senderId"] == userData?.id,
        status: MessageStatus.sent,
      );

      final exists = _messages.any((m) => m.id == msg.id);
      if (!exists) {
        _messages.add(msg);
        notifyListeners();
        debugPrint("✅ New message added to UI");
      } else {
        debugPrint("⚠️ Message already exists, skipping");
      }
    } catch (e) {
      debugPrint("❌ Error handling new message: $e");
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(content: Text("Error processing message: $e")),
      );
    }
  }

  void handleDelivered(String messageId) {
    _updateMessageStatus(messageId, MessageStatus.delivered);
  }

  void handleRead(String messageId) {
    _updateMessageStatus(messageId, MessageStatus.read);
  }

  void setTypingStatus(bool typing) {
    if (_isTyping != typing) {
      _isTyping = typing;
      notifyListeners();
      debugPrint("⌨️ Typing status updated: $typing");
    }
  }

  void updateUserOnlineStatus(String userId, bool isOnline) {
    if (_currentUser?.id == userId) {
      _currentUser = _currentUser?.copyWith(isOnline: isOnline);
      notifyListeners();
      debugPrint("🔄 User online status updated: $isOnline");
    }
  }

  void markAllAsRead() {
    if (_chatRoomId == null || userData?.id == null) return;

    bool hasChanges = false;
    for (int i = 0; i < _messages.length; i++) {
      if (!_messages[i].isFromMe && _messages[i].status != MessageStatus.read) {
        _messages[i] = _messages[i].copyWith(status: MessageStatus.read);
        hasChanges = true;
      }
    }
    if (hasChanges) {
      socketIoHelper.markMessagesAsRead(
        roomId: _chatRoomId!,
        readerId: userData!.id!,
      );
      notifyListeners();
    }
  }

  void updateMessageText(String text) {
    _messageText = text;
  }

  bool get canSendMessage => _messageText.trim().isNotEmpty;

  void clearMessages() {
    _messages.clear();
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

  @override
  void dispose() {
    _videoController?.dispose();
    socketIoHelper.disconnectSocket();
    super.dispose();
  }
}