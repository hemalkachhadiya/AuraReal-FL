import 'package:aura_real/aura_real.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketIoHelper {
  IO.Socket? socketApp;

  webSocketData({
    required String text,
    required String roomId,
    required String messageType,
  }) async {
    final res = {};

    socketApp!.emit('sendMessage', res);
  }

  void connectSocket(String roomId, StateSetter setState) {
    socketApp = IO.io(EndPoints.WebSocketurl, <String, dynamic>{
      'autoConnect': true,
      'transports': ['websocket'],
      'forceNew': true, // Ensure fresh connection
      'reconnect': true, // Auto-reconnect
    });

    socketApp!.onConnect((_) {
      debugPrint('Connected to socket: ${socketApp!.connected}');

      final roomData = {'userId': ''};

      socketApp!.emit("joinRoom", roomData);

      socketApp!.on('joinRoom', (data) {
        debugPrint("Successfully joined room: $data");
      });

      socketApp!.on('newMessage', (data) {
        debugPrint(" Raw message received: $data");

        // try {
        //   final decodedData = jsonDecode(jsonEncode(data));
        //   debugPrint(" Decoded Message: $decodedData");

        //   final message = ChatMessages.fromJson(decodedData);

        //   setState(() {
        //     chatRoomScreenBloc.chatmessageList.insert(0, message);
        //   });

        //   debugPrint(" Message added to list: ${message.message}");
        // } catch (e) {
        //   debugPrint(" Error parsing message: $e");
        // }
      });

      // Debug: Listen for all socket events
      socketApp!.onAny((event, data) {
        debugPrint("⚡ Event received: $event ==> $data");
      });
    });

    socketApp!.onConnectError((err) {
      // debugPrint("❌ Socket connection error: $err");
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

SocketIoHelper socketIoHelper = SocketIoHelper();
