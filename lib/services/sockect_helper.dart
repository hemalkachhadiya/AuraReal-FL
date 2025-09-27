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
        socketApp!.emit("joinRoom", {"userId": userId, "roomId": roomId});
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
        if (senderId != userId) {
          // Don't show typing indicator for self
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
      if (messageId != null) "messageId": messageId,
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
    };

    socketApp!.emit("markMessagesAsRead", data);
    debugPrint("📖 Emitted markMessagesAsRead: $data");
  }

  /// ✅ Single message seen
  void markMessageSeen({required String messageId, required String readerId}) {
    if (socketApp == null || !socketApp!.connected) {
      debugPrint("❌ Cannot mark message as seen: Socket not connected");
      return;
    }

    final data = {"messageId": messageId, "readerId": readerId};
    socketApp!.emit("messageSeen", data);
    debugPrint("👁️ Emitted messageSeen: $data");
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
          timestamp:
              DateTime.tryParse(decodedData["createdAt"] ?? "") ??
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
            final provider = Provider.of<MessageProvider>(
              context,
              listen: false,
            );
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

    print("un read commet  call");
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

///BackEndCode
//import { db } from "../models/index.js";
// import mongoose from "mongoose";
//
// function chatSocket(io) {
//   // ← Declare onlineUsers here so all sockets can access
//   const onlineUsers = new Map(); // userId → Set of socketIds
//
//   io.on("connection", (socket) => {
//     console.log("🔵 User connected:", socket.id);
//
//     // ---------------- Register user for online/offline ----------------
//     socket.on("registerUser", async (userId) => {
//       if (!onlineUsers.has(userId)) {
//         onlineUsers.set(userId, new Set());
//       }
//       onlineUsers.get(userId).add(socket.id);
//
//       // Update DB status (optional)
//       await db.User.findByIdAndUpdate(userId, { isOnline: true, lastSeen: new Date() });
//
//       // Notify all clients
//       io.emit("userOnline", { userId });
//     });
//
//     // ---------------- Check online status ----------------
//     socket.on("checkOnline", (userId, callback) => {
//       const isOnline = onlineUsers.has(userId);
//       callback({ userId, isOnline });
//     });
//
//     // ---------------- Join a room ----------------
//     socket.on("joinRoom", async ({ userId, roomId }) => {
//       try {
//         socket.join(roomId);
//
//         // Add user to participants if not already there
//         await db.chatRoom.findByIdAndUpdate(roomId, {
//           $addToSet: { participants: userId },
//         });
//
//         io.to(roomId).emit("userJoined", { userId, roomId });
//         console.log(✅ User ${userId} joined room ${roomId});
//       } catch (err) {
//         console.error("❌ Error joining room:", err);
//       }
//     });
//
//     // ---------------- Send message ----------------
//     socket.on("sendMessage", async ({ roomId, senderId, receiverId, message, messageType, mediaUrl }) => {
//       try {
//         // Fetch the chat room first
//         const room = await db.chatRoom.findById(roomId);
//         if (!room) {
//           return io.to(senderId).emit("errorMessage", { error: "Chat room not found" });
//         }
//
//         // Save the chat message
//         const chatMessage = await db.ChatMessage.create({
//           chatRoomId: roomId,
//           senderId,
//           receiverId,
//           message,
//           messageType: messageType || "text",
//           mediaUrl: mediaUrl || "",
//           readBy: [senderId], // mark sender as read
//         });
//
//         // Update lastMessage
//         await db.chatRoom.findByIdAndUpdate(roomId, {
//           lastMessage: message,
//           updatedAt: new Date(),
//         });
//
//         // Update unreadCount for other participants
//         const participants = room.participants?.filter(Boolean) || [];
//         const unreadCountArray = room.unreadCount || [];
//
//         const updatedUnreadCount = participants
//           .filter(u => u.toString() !== senderId)
//           .map(u => {
//             const existing = unreadCountArray.find(x => x.userId?.toString() === u.toString());
//             return {
//               userId: new mongoose.Types.ObjectId(u),
//               count: existing ? existing.count + 1 : 1
//             };
//           });
//
//
//         await db.chatRoom.findByIdAndUpdate(roomId, { unreadCount: updatedUnreadCount });
//
//         // Emit to socket room
//         io.to(roomId).emit("newMessage", chatMessage);
//
//         // Send notifications to all participants except sender
//         const receivers = participants.filter(u => u.toString() !== senderId);
//         for (let rId of receivers) {
//           const receiver = await db.User.findById(rId);
//           if (receiver?.device_token) {
//             await sendPushNotification(
//               receiver.device_token,
//               "AuraReal",
//               "New Message 💬",
//               message || "You received a new message",
//               { roomId, senderId, messageType: messageType || "text" },
//               1
//             );
//           }
//         }
//
//         console.log(💬 Message sent by ${senderId} in room ${roomId});
//       } catch (err) {
//         console.error("❌ Error sending message:", err);
//         io.to(senderId).emit("errorMessage", { error: "Message not sent" });
//       }
//     });
//
//
//
//
//     // ---------------- Mark single message as read ----------------
//     socket.on("messageSeen", async ({ messageId, readerId }) => {
//       try {
//         const message = await db.ChatMessage.findByIdAndUpdate(
//           messageId,
//           { $addToSet: { readBy: readerId } },
//           { new: true }
//         );
//
//         const unreadCount = await db.ChatMessage.countDocuments({
//           chatRoomId: message.chatRoomId,
//           readBy: { $ne: readerId },
//         });
//
//         socket.emit("unreadCount", {
//           roomId: message.chatRoomId,
//           count: unreadCount,
//         });
//       } catch (err) {
//         console.error("❌ Error marking message as read:", err);
//       }
//     });
//
//     // ---------------- Mark all messages in room as read ----------------
//     socket.on("markMessagesAsRead", async ({ roomId, readerId }, callback) => {
//       try {
//         const result = await db.ChatMessage.updateMany(
//           { chatRoomId: roomId, readBy: { $ne: readerId } },
//           { $addToSet: { readBy: readerId } }
//         );
//
//         const unreadCount = await db.ChatMessage.countDocuments({
//           chatRoomId: roomId,
//           readBy: { $ne: readerId },
//         });
//
//         // Emit updated unread count only to this user
//         socket.emit("unreadCount", { roomId, count: unreadCount });
//
//         // ✅ Only call callback if it's provided
//         if (typeof callback === "function") {
//           callback({ success: true, updatedCount: result.modifiedCount });
//         }
//       } catch (err) {
//         console.error("❌ Error marking messages as read:", err);
//         if (typeof callback === "function") {
//           callback({ success: false, error: err.message });
//         }
//       }
//     });
//
//
//     // ---------------- Typing indicator ----------------
//     socket.on("typing", ({ senderId, roomId }) => {
//       socket.to(roomId).emit("typing", { senderId });
//     });
//
//     // ---------------- Disconnect ----------------
//     socket.on("disconnect", async () => {
//       console.log("🔴 User disconnected:", socket.id);
//       console.log("🟡 Total connected clients:", io.engine.clientsCount);
//
//       // Remove socket from onlineUsers
//       for (let [userId, sockets] of onlineUsers.entries()) {
//         if (sockets.has(socket.id)) {
//           sockets.delete(socket.id);
//
//           if (sockets.size === 0) {
//             onlineUsers.delete(userId);
//
//             // Update DB
//             await db.User.findByIdAndUpdate(userId, { isOnline: false, lastSeen: new Date() });
//
//             // Notify all clients
//             io.emit("userOffline", { userId });
//           }
//           break;
//         }
//       }
//     });
//   });
// }
//
// export default chatSocket;
//socket.on("markMessagesAsRead", async ({ roomId, readerId }, callback) => {
//       try {
//         const result = await db.ChatMessage.updateMany(
//           { chatRoomId: roomId, readBy: { $ne: readerId } },
//           { $addToSet: { readBy: readerId } }
//         );
//
//         const unreadCount = await db.ChatMessage.countDocuments({
//           chatRoomId: roomId,
//           readBy: { $ne: readerId },
//         });
//
//         // Emit updated unread count only to this user
//         socket.emit("unreadCount", { roomId, count: unreadCount });
//
//         // ✅ Only call callback if it's provided
//         if (typeof callback === "function") {
//           callback({ success: true, updatedCount: result.modifiedCount });
//         }
//       } catch (err) {
//         console.error("❌ Error marking messages as read:", err);
//         if (typeof callback === "function") {
//           callback({ success: false, error: err.message });
//         }
//       }
//     });
// socket.on("messageSeen", async ({ messageId, readerId }) => {
//       try {
//         const message = await db.ChatMessage.findByIdAndUpdate(
//           messageId,
//           { $addToSet: { readBy: readerId } },
//           { new: true }
//         );
//
//         const unreadCount = await db.ChatMessage.countDocuments({
//           chatRoomId: message.chatRoomId,
//           readBy: { $ne: readerId },
//         });
//
//         socket.emit("unreadCount", {
//           roomId: message.chatRoomId,
//           count: unreadCount,
//         });
//       } catch (err) {
//         console.error("❌ Error marking message as read:", err);
//       }
//     });
