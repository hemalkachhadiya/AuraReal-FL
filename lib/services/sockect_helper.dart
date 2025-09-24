import 'dart:async';

import 'package:aura_real/aura_real.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

SocketIoHelper socketIoHelper = SocketIoHelper();

class SocketIoHelper {
  IO.Socket? socketApp;
  MessageProvider? _messageProvider; // Reference to provider

  /// ✅ Connect and authenticate socket
  void connectSocket(
      String userId, {
        required String roomId,
        MessageProvider? provider,
      }) {
    try {
      if (socketApp?.connected == true) {
        debugPrint("🔌 Socket already connected");
        return;
      }

      socketApp = IO.io(
        EndPoints.socketUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .enableForceNew()
            .setTimeout(5000)
            .build(),
      );

      socketApp!.connect();

      // Connection events
      socketApp!.onConnect((_) {
        debugPrint("✅ Socket connected successfully");
        socketApp!.emit("joinRoom", {
          "userId": userId,
          "roomId": roomId,
        });
      });

      socketApp!.onDisconnect((_) {
        debugPrint("❌ Socket disconnected");
      });

      socketApp!.onConnectError((error) {
        debugPrint("❌ Socket connection error: $error");
      });

      // Message events
      socketApp!.on("newMessage", (data) {
        debugPrint("📥 New message received: $data");
        provider?.handleNewMessage(data);
      });

      socketApp!.on("messageSent", (data) {
        debugPrint("✅ Message sent acknowledgment: $data");
        // This will be handled by the sendMessage method
      });

      socketApp!.on("messageError", (error) {
        debugPrint("❌ Message error: $error");
        // This will be handled by the sendMessage method
      });

      // ✅ New event listeners for read receipts
      socketApp!.on("messageRead", (data) {
        debugPrint("📖 Message read event: $data");
        provider?.handleMessageRead(data);
      });

      socketApp!.on("messagesRead", (data) {
        debugPrint("📖 Multiple messages read event: $data");
        provider?.handleMessageRead(data);
      });

      socketApp!.on("messageDelivered", (data) {
        debugPrint("📨 Message delivered event: $data");
        provider?.handleMessageDelivered(data);
      });

      // Typing events
      socketApp!.on("userTyping", (data) {
        debugPrint("⌨️ User typing: $data");
        final senderId = data["senderId"];
        if (senderId != userId) { // Don't show typing indicator for self
          provider?.setTypingStatus(true);

          // Auto-hide typing after 3 seconds
          Timer(const Duration(seconds: 3), () {
            provider?.setTypingStatus(false);
          });
        }
      });

      socketApp!.on("userStoppedTyping", (data) {
        debugPrint("⌨️ User stopped typing: $data");
        final senderId = data["senderId"];
        if (senderId != userId) {
          provider?.setTypingStatus(false);
        }
      });

      // Online status events
      socketApp!.on("userOnline", (data) {
        debugPrint("🟢 User online: $data");
        final userId = data["userId"];
        provider?.updateUserOnlineStatus(userId, true);
      });

      socketApp!.on("userOffline", (data) {
        debugPrint("🔴 User offline: $data");
        final userId = data["userId"];
        provider?.updateUserOnlineStatus(userId, false);
      });

      // Error handling
      socketApp!.on("error", (error) {
        debugPrint("❌ Socket error: $error");
      });

    } catch (e) {
      debugPrint("❌ Socket connection failed: $e");
    }
  }

  /// ✅ Send message
  void sendMessage({
    required String text,
    required String roomId,
    required String messageType,
    required String receiverId,
    required String senderId,
    String? messageId, // Add messageId parameter
    File? attachment,
  }) {
    if (socketApp == null || !socketApp!.connected) {
      debugPrint("❌ Cannot send message: Socket not connected");
      return;
    }

    final messageData = {
      "message": text,
      "roomId": roomId,
      "messageType": messageType,
      "receiverId": receiverId,
      "senderId": senderId,
      if (messageId != null) "messageId": messageId, // Include messageId if provided
      "timestamp": DateTime.now().toIso8601String(),
    };

    socketApp!.emit("sendMessage", messageData);
    debugPrint("📤 Message sent via socket: $messageData");
  }

  /// ✅ Typing event
  void sendTyping({required String senderId, required String roomId}) {
    socketApp?.emit("typing", {"senderId": senderId, "roomId": roomId});
  }

  void stopTyping({required String senderId, required String roomId}) {
    socketApp?.emit("stopTyping", {"senderId": senderId, "roomId": roomId});
  }

  /// ✅ Mark all messages as read
  void markMessagesAsRead({
    required String roomId,
    required String readerId,
    List<String>? messageIds,
  }) {
    if (socketApp == null || !socketApp!.connected) {
      debugPrint("❌ Cannot mark messages as read: Socket not connected");
      return;
    }

    final data = {
      "roomId": roomId,
      "readerId": readerId,
      if (messageIds != null && messageIds.isNotEmpty) "messageIds": messageIds,
      "timestamp": DateTime.now().toIso8601String(),
    };

    socketApp!.emit("markAsRead", data);
    debugPrint("📖 Emitted markAsRead: $data");
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