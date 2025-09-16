import 'package:aura_real/aura_real.dart';

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
      print("Body =============== ${responseBody}");
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

  /// Get All Messages
  static Future<AppResponse3<GetAllMessageModel>?> getAllMessages({
    required String chatRoomId,
  }) async {
    print("chat room id======== ${chatRoomId}");
    try {
      final response = await ApiService.getApi(
        url: "${EndPoints.getAllMessages}",
        queryParams: {"chatRoomId": chatRoomId},
      );

      if (response == null) {
        showCatchToast('No response from server', null);
        return null;
      }

      final responseBody = jsonDecode(response.body);

      print("get ALl Message response------------ ${responseBody}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        final appResponse = AppResponse3<GetAllMessageModel>.fromJson(
          responseBody,
          (item) => GetAllMessageModel.fromJson(item),
        );

        showSuccessToast(appResponse.message ?? "Messages fetched");

        return appResponse;
      } else {
        showCatchToast(responseBody['message'] ?? "Something went wrong", null);
      }
    } catch (exception, stack) {
      showCatchToast(exception, stack);
      return null;
    }
    return null;
  }

  ///Get User Chat Room
  static Future<AppResponse3<GetUserChatRoomModel>?> getUserChatRoom({
    required String userId,
  }) async {
    try {
      print("Get User Chat Room");

      final response = await ApiService.getApi(
        url: "${EndPoints.getUserChatRooms}",
        queryParams: {"userId": userId},
      );

      if (response == null) {
        showCatchToast('No response from server', null);
        return null;
      }

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final appResponse = AppResponse3<GetUserChatRoomModel>.fromJson(
          responseBody,
          (item) => GetUserChatRoomModel.fromJson(item),
        );

        showSuccessToast(appResponse.message ?? "Chat rooms fetched");

        return appResponse;
      } else {
        showCatchToast(responseBody['message'] ?? "Something went wrong", null);
      }
    } catch (exception, stack) {
      showCatchToast(exception, stack);
      return null;
    }
    return null;
  }
}
