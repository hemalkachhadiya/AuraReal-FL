import 'package:aura_real/aura_real.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

SocketIoHelper socketIoHelper = SocketIoHelper();

class SocketIoHelper {
  IO.Socket? socketApp;

  /// ✅ Connect and authenticate socket
  void connectSocket(String userId, {String? roomId}) {
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
      debugPrint("💬 New message: $data");
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

        final provider = Provider.of<MessageProvider>(
          navigatorKey.currentContext!,
          listen: false,
        );
        provider.messages.add(msg);
        provider.notifyListeners();
      } catch (e) {
        debugPrint("❌ Error parsing new message: $e");
      }
    });

    // Typing indicator
    socketApp!.on("typing", (data) {
      debugPrint("⌨️ Typing: $data");
    });

    // Online/offline users
    socketApp!.on("userOnline", (data) {
      debugPrint("🟢 User online: $data");
    });

    socketApp!.on("userOffline", (data) {
      debugPrint("🔴 User offline: $data");
    });

    // Unread count updates
    socketApp!.on("unreadCount", (data) {
      debugPrint("📊 Unread count: $data");
    });

    // Debug: log all socket events
    socketApp!.onAny((event, data) {
      debugPrint("⚡ Event received: $event ==> $data");
    });
  }

  /// ✅ Disconnect
  void disconnectSocket() {
    socketApp?.disconnect();
    socketApp?.dispose();
    debugPrint("🔌 Socket disconnected");
  }
}
