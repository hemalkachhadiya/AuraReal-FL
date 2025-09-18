import 'package:aura_real/apis/chat_apis.dart';
import 'package:aura_real/aura_real.dart';

import 'package:flutter/material.dart';

// Message Model
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
}

enum MessageStatus { sending, sent, delivered, read, failed }

// Chat User Model
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
}

class MessageProvider extends ChangeNotifier {
  List<Message> _messages = [];
  ChatUser? _currentUser;
  bool _isLoading = false;
  bool _isTyping = false;
  String _messageText = '';

  // Getters
  List<Message> get messages => _messages;

  ChatUser? get currentUser => _currentUser;

  bool get isLoading => _isLoading;

  bool get isTyping => _isTyping;

  String get messageText => _messageText;

  bool get canSendMessage => _messageText.trim().isNotEmpty;

  String? _chatRoomId; // ✅ only internal use

  // Initialize chat data
  // Initialize chat with user + fetch API messages
  Future<void> initializeChat({
    required ChatUser user,
    required String chatRoomId,
  }) async {
    _currentUser = user;
    _chatRoomId = chatRoomId; // ✅ save it internally

    await getAllMessageList(chatRoomId);
  }

  // Inside MessageProvider
  Future<void> getAllMessageList(String chatRoomId) async {
    print("message====================== 1");
    _isLoading = true;
    notifyListeners();

    final response = await ChatApis.getAllMessages(chatRoomId: chatRoomId);

    if (response != null && response.data != null) {
      // Convert API model (GetAllMessageModel) into provider's Message model
      _messages =
          response.data!.map((msg) {
            return Message(
              id: msg.id ?? "",
              // from API
              text: msg.message ?? "",
              // from API
              timestamp: msg.createdAt ?? DateTime.now(),
              // from API
              isFromMe: msg.senderId == _currentUser?.id,
              // check if sent by me
              status: MessageStatus.sent, // map API status if available
            );
          }).toList();
    } else {
      _messages = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  void updateMessageText(String text) {
    _messageText = text;
    notifyListeners();
  }

  /// Send message
  void sendMessage({String? receiverId}) {
    if (!canSendMessage) return;

    final newMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: _messageText.trim(),
      timestamp: DateTime.now(),
      isFromMe: true,
      status: MessageStatus.sending,
    );

    _messages.add(newMessage);
    notifyListeners();

    print("Send Message=============================called");
    print("Chat Room Id=============================${_chatRoomId}");
    print("currentUser Id=============================${currentUser?.id}");

    // 🚀 Send to server via socket
    socketIoHelper.sendMessage(
      text: newMessage.text,
      roomId: _chatRoomId ?? "",
      messageType: "text",
      // could be text/image/file,
      receiverId: currentUser?.id ?? "",
      senderId: userData?.id.toString() ?? "",
    );

    // ✅ Mark as "sent"
    _updateMessageStatus(newMessage.id, MessageStatus.sent);

    // Clear input
    _messageText = '';
    notifyListeners();
  }

  void _simulateMessageSending(String messageId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Update to sent
    _updateMessageStatus(messageId, MessageStatus.sent);

    await Future.delayed(const Duration(seconds: 1));

    // Update to delivered
    _updateMessageStatus(messageId, MessageStatus.delivered);

    // Simulate auto-reply (optional)
    _simulateAutoReply();
  }

  // Update message status
  void _updateMessageStatus(String messageId, MessageStatus status) {
    final messageIndex = _messages.indexWhere((m) => m.id == messageId);
    if (messageIndex != -1) {
      _messages[messageIndex] = Message(
        id: _messages[messageIndex].id,
        text: _messages[messageIndex].text,
        timestamp: _messages[messageIndex].timestamp,
        isFromMe: _messages[messageIndex].isFromMe,
        status: status,
      );
      notifyListeners();
    }
  }

  // Simulate auto-reply (for demo purposes)
  void _simulateAutoReply() async {
    await Future.delayed(const Duration(seconds: 2));

    _isTyping = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    final replies = [
      'Thanks for your message! 👍',
      'Got it!',
      'On my way! 🚗',
      'See you soon!',
      'Perfect! 😊',
    ];

    final reply = replies[DateTime.now().millisecond % replies.length];

    final autoReply = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: reply,
      timestamp: DateTime.now(),
      isFromMe: false,
    );

    _messages.add(autoReply);
    _isTyping = false;
    notifyListeners();
  }

  // Mark messages as read
  void markMessagesAsRead() {
    bool hasChanges = false;
    for (int i = 0; i < _messages.length; i++) {
      if (!_messages[i].isFromMe && _messages[i].status != MessageStatus.read) {
        _messages[i] = Message(
          id: _messages[i].id,
          text: _messages[i].text,
          timestamp: _messages[i].timestamp,
          isFromMe: _messages[i].isFromMe,
          status: MessageStatus.read,
        );
        hasChanges = true;
      }
    }
    if (hasChanges) {
      notifyListeners();
    }
  }

  // Format timestamp for display
  String formatMessageTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }

  // Get status icon for sent messages
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

  // Get status color
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

  // Clear messages
  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}



///Web Back End Code
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