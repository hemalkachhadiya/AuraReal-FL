import 'package:aura_real/aura_real.dart';
import 'package:aura_real/screens/home/notification/model/notification_model.dart';

class NotificationApis {
  static Future<AppResponse2<NotificationModel>?> getNotificationsAPI({
    int page = 1,
    int pageSize = 10,
  }) async {
    String token = PrefService.getString(PrefKeys.token);
    try {
      if (token.startsWith('"') && token.endsWith('"')) {
        token = token.substring(1, token.length - 1);
      }

      final headers = {"token": token};

      final response = await ApiService.getApi(
        url: EndPoints.getAllnotification, // <-- replace with your endpoint
        queryParams: {"page": page, "page_size": pageSize},
        header: headers,
      );

      if (response == null) {
        showCatchToast('No response from server', null);
        return null;
      }

      final model = appResponseFromJson2<NotificationModel>(
        response.body,
        converter: (dynamic data) =>
            NotificationModel.fromJson(data as Map<String, dynamic>),
        dataKey: 'notifications', // 👈 depends on your API response key
      );

      if (model.isSuccess) {
        // showSuccessToast(model.message ?? "Notifications fetched successfully");
        return model;
      } else {
        showCatchToast(model.message ?? "Failed to fetch notifications", null);
        return null;
      }
    } catch (exception, stack) {
      showCatchToast(exception, stack);
      return null;
    }
  }
}
