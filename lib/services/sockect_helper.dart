import 'package:aura_real/aura_real.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

SocketIoHelper socketIoHelper = SocketIoHelper();

class SocketIoHelper {
  IO.Socket? socketApp;
  MessageProvider? _messageProvider; // Reference to provider

  /// ✅ Connect and authenticate socket
  void connectSocket(String userId, {String? roomId, MessageProvider? provider}) {
    _messageProvider = provider; // Store provider reference

    socketApp = IO.io(
      EndPoints.domain,
      <String, dynamic>{
        'autoConnect': true,
        'transports': ['websocket'],
        'forceNew': true,
        'reconnect': true,
      },
    );

    socketApp!.onConnect((_) {
      debugPrint("✅ Connected to socket: ${socketApp!.id}");

      // Register user as online
      socketApp!.emit("registerUser", userId);

      // Join specific room if provided
      if (roomId != null) {
        final roomData = {"roomId": roomId, "userId": userId};
        socketApp!.emit("joinRoom", roomData);
        debugPrint("📌 Joined room: $roomData");
      }

      _listenEvents();
    });

    socketApp!.onConnectError((err) {
      debugPrint("❌ Socket connection error: $err");
    });

    socketApp!.onDisconnect((_) {
      debugPrint("⚠️ Disconnected from socket");
    });
  }

  /// ✅ Send message
  void sendMessage({
    required String roomId,
    required String senderId,
    required String receiverId,
    required String text,
    String messageType = "text",
    String? mediaUrl,
  }) {
    final payload = {
      "roomId": roomId,
      "senderId": senderId,
      "receiverId": receiverId,
      "message": text,
      "messageType": messageType,
      "mediaUrl": mediaUrl ?? "",
    };

    debugPrint("📤 Sending message: $payload");
    socketApp?.emit("sendMessage", payload);
  }

  /// ✅ Typing event
  void sendTyping({required String senderId, required String roomId}) {
    socketApp?.emit("typing", {"senderId": senderId, "roomId": roomId});
  }

  void stopTyping({required String senderId, required String roomId}) {
    socketApp?.emit("stopTyping", {"senderId": senderId, "roomId": roomId});
  }

  /// ✅ Mark all messages as read
  void markMessagesAsRead({required String roomId, required String readerId}) {
    socketApp?.emit("markMessagesAsRead", {
      "roomId": roomId,
      "readerId": readerId,
    });
  }

  /// ✅ Listen for all events
  void _listenEvents() {
    // New message
    socketApp!.on("newMessage", (data) {
      debugPrint("💬 New message received: $data");
      try {
        final decodedData = jsonDecode(jsonEncode(data));
        final msg = Message(
          id: decodedData["_id"] ?? DateTime.now().toString(),
          text: decodedData["message"] ?? "",
          timestamp: DateTime.tryParse(decodedData["createdAt"] ?? "") ??
              DateTime.now(),
          isFromMe: decodedData["senderId"] == userData?.id,
          status: MessageStatus.sent,
        );

        // Use stored provider reference or get from context
        if (_messageProvider != null) {
          _messageProvider!.handleNewMessage(decodedData);
        } else {
          // Fallback to getting provider from context
          final context = navigatorKey.currentContext;
          if (context != null) {
            final provider = Provider.of<MessageProvider>(context, listen: false);
            provider.handleNewMessage(decodedData);
          }
        }
      } catch (e) {
        debugPrint("❌ Error parsing new message: $e");
      }
    });

    // Typing indicator
    socketApp!.on("typing", (data) {
      debugPrint("⌨️ User typing: $data");
      try {
        final senderId = data["senderId"];
        if (senderId != userData?.id) {
          _messageProvider?.setTypingStatus(true);
        }
      } catch (e) {
        debugPrint("❌ Error handling typing event: $e");
      }
    });

    socketApp!.on("stopTyping", (data) {
      debugPrint("⌨️ User stopped typing: $data");
      try {
        final senderId = data["senderId"];
        if (senderId != userData?.id) {
          _messageProvider?.setTypingStatus(false);
        }
      } catch (e) {
        debugPrint("❌ Error handling stop typing event: $e");
      }
    });

    // Online/offline users
    socketApp!.on("userOnline", (data) {
      debugPrint("🟢 User online: $data");
      try {
        final userId = data["userId"];
        _messageProvider?.updateUserOnlineStatus(userId, true);
      } catch (e) {
        debugPrint("❌ Error handling user online event: $e");
      }
    });

    socketApp!.on("userOffline", (data) {
      debugPrint("🔴 User offline: $data");
      try {
        final userId = data["userId"];
        _messageProvider?.updateUserOnlineStatus(userId, false);
      } catch (e) {
        debugPrint("❌ Error handling user offline event: $e");
      }
    });

    // Message delivered
    socketApp!.on("messageDelivered", (data) {
      debugPrint("📬 Message delivered: $data");
      try {
        final messageId = data["messageId"];
        _messageProvider?.handleDelivered(messageId);
      } catch (e) {
        debugPrint("❌ Error handling message delivered: $e");
      }
    });

    // Message read
    socketApp!.on("messageRead", (data) {
      debugPrint("👁️ Message read: $data");
      try {
        final messageId = data["messageId"];
        _messageProvider?.handleRead(messageId);
      } catch (e) {
        debugPrint("❌ Error handling message read: $e");
      }
    });

    // Unread count updates
    socketApp!.on("unreadCount", (data) {
      debugPrint("📊 Unread count: $data");
      // Handle unread count update if needed
    });

    // Debug: log all socket events
    socketApp!.onAny((event, data) {
      debugPrint("⚡ Event received: $event ==> $data");
    });
  }

  /// ✅ Disconnect
  void disconnectSocket() {
    _messageProvider = null; // Clear provider reference
    socketApp?.disconnect();
    socketApp?.dispose();
    debugPrint("🔌 Socket disconnected");
  }
}