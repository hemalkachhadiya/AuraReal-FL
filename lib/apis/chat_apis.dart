import 'package:aura_real/apis/app_response.dart';
import 'package:aura_real/aura_real.dart';
import 'package:aura_real/screens/chat/model/chat_room_model.dart';

class ChatApis {
  ///Create Chat Room

  static Future<AppResponse<ChatRoomModel>> createChatRoom({
    required String userId,
    required String followUserId,
  }) async {
    try {
      final response = await ApiService.postApi(
        url: EndPoints.createChatRoom,
        body: {
          "participants": [userId, followUserId],
        },
      );

      if (response == null) {
        showCatchToast("No response from server", null);
        return AppResponse(success: false, message: "No response from server");
      }

      final responseBody = appResponseFromJson<ChatRoomModel>(
        response.body,
        converter: (json) => ChatRoomModel.fromJson(json),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return responseBody;
      } else {
        showCatchToast(
          responseBody.message ?? 'Failed to create chat room',
          null,
        );
        return AppResponse(
          success: false,
          message: responseBody.message ?? 'Failed',
        );
      }
    } catch (e, s) {
      showCatchToast(e.toString(), s);
      return AppResponse(success: false, message: e.toString());
    }
  }
}
