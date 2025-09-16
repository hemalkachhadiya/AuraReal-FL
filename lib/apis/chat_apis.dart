import 'package:aura_real/aura_real.dart';

class ChatApis{
  ///Create Chat Room
  static Future<bool> createChatRoom({
    required String followUserId,
    required String userId,
  }) async {
    try {
      final response = await ApiService.postApi(
        url: EndPoints.follow,
        body: {"followUserId": followUserId, "userId": userId},
      );

      if (response == null) {
        showCatchToast("No response from server", null);
        return false;
      }

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // showSuccessToast(responseBody['message'] ?? 'Follow successful');
        return true;
      } else {
        showCatchToast(responseBody['message'] ?? 'Failed', null);
        return false;
      }
    } catch (e, s) {
      showCatchToast(e, s);
      return false;
    }
  }
}