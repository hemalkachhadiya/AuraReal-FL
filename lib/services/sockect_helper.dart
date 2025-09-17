import 'package:aura_real/aura_real.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

SocketIoHelper socketIoHelper = SocketIoHelper();

class SocketIoHelper {
  IO.Socket? socketApp;

  webSocketData({
    required String text,
    required String roomId,
    required String messageType,
  }) async {
    final res = {
      "roomId": roomId,
      "senderId": "${userData?.id}",
      "message": text,
      "senderType": 0,
      "messageType": messageType,
    };


    print("res web socket data ====================== ${res}");
    socketApp!.emit('sendMessage', res);
  }

  void connectSocket(String roomId, StateSetter setState) {
    print("connect socket===========================1");
    socketApp = IO.io(EndPoints.domain, <String, dynamic>{
      'autoConnect': true,
      'transports': ['websocket'],
      'forceNew': true, // Ensure fresh connection
      'reconnect': true, // Auto-reconnect
    });

    socketApp!.onConnect((_) {
      debugPrint('Connected to socket: ${socketApp!.connected}');

      final roomData = {'roomId': roomId, 'userId': userData?.id};

      socketApp!.emit("joinRoom", roomData);

      socketApp!.on('joinRoom', (data) {
        debugPrint("Successfully joined room: $data");
      });

      socketApp!.on('newMessage', (data) {
        debugPrint(" Raw message received: $data");

        try {
          final decodedData = jsonDecode(jsonEncode(data));

          // Convert to provider message
          final msg = Message(
            id: decodedData["_id"] ?? DateTime.now().toString(),
            text: decodedData["message"] ?? "",
            timestamp:
                DateTime.tryParse(decodedData["createdAt"] ?? "") ??
                DateTime.now(),
            isFromMe: decodedData["senderId"] == userData?.id,
            status: MessageStatus.sent,
          );

          // 👇 Add to provider list
          final provider = Provider.of<MessageProvider>(
            navigatorKey.currentContext!,
            listen: false,
          );
          provider.messages.add(msg);
          // provider.notifyListeners();
        } catch (e) {
          debugPrint("❌ Error parsing new message: $e");
        }
      });

      // socketApp!.on('newMessage', (data) {
      //   debugPrint(" Raw message received: $data");
      //
      //   try {
      //     final decodedData = jsonDecode(jsonEncode(data));
      //     debugPrint(" Decoded Message: $decodedData");
      //
      //     final message = ChatRoomModel.fromJson(decodedData);
      //
      //     print("Message length============== ${message.participants?.length}");
      //     print("Message first============== ${message.participants?.first}");
      //     // setState(() {
      //     //   chatRoomScreenBloc.chatmessageList.insert(0, message);
      //     // });
      //     //
      //     // debugPrint(" Message added to list: ${message.message}");
      //   } catch (e) {
      //     debugPrint(" Error parsing message: $e");
      //   }
      // });

      // Debug: Listen for all socket events
      socketApp!.onAny((event, data) {
        debugPrint("⚡ Event received: $event ==> $data");
      });
    });

    socketApp!.onConnectError((err) {
      debugPrint("❌ Socket connection error: $err");
    });

    socketApp!.onDisconnect((_) {
      debugPrint("⚠️ Disconnected from socket");
    });
  }

  disconnectSocket() {
    socketApp!.disconnect();
    socketApp!.dispose();
    debugPrint('~~~~~~~Socket disconnect');
  }
}
