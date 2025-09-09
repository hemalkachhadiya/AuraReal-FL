import 'package:aura_real/apis/app_response_2.dart';
import 'package:aura_real/aura_real.dart';
import 'package:aura_real/apis/model/post_model.dart';

class PostAPI {
  static Future<AppResponse2<PostModel>?> getAllPostListAPI({
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      String token = PrefService.getString(PrefKeys.token);
      var latitude = PrefService.getDouble(PrefKeys.latitude);
      var longitude = PrefService.getDouble(PrefKeys.longitude);

      print("Location ------ ${PrefKeys.location}");
      print("Lat ------ ${latitude}");
      print("Long ------ ${longitude}");
      print("Used Token ------ $token"); // Debug the token
      // Add both Authorization and token headers
      // Use the token directly without jsonEncode
      final headers = {
        "token": token.toString(), // Correct: Use raw string
      };

      final response = await ApiService.getApi(
        url: EndPoints.getAllPostAPI,
        queryParams: {"latitude": latitude, "longitude": longitude},
        header: headers,
      );

      if (response == null) {
        showCatchToast('No response from server', null);
        return null;
      }
      print("response status code==== ${response.statusCode}");
      final model = appResponse2FromJson<PostModel>(
        response.body,
        converter:
            (dynamic data) => PostModel.fromJson(data as Map<String, dynamic>),
        dataKey: 'posts',
      );

      if (model.isSuccess) {
        showSuccessToast(model.message ?? "Posts fetched successfully");
        return model;
      } else {
        showCatchToast(model.message ?? "Failed to fetch posts", null);
        return null;
      }
    } catch (exception, stack) {
      showCatchToast(exception, stack);
      return null;
    }
  }

  static Future<AppResponse2<PostModel>?> getPostByUserAPI({
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await ApiService.getApi(url: EndPoints.getPostByUSer);

      if (response == null) {
        showCatchToast('No response from server', null);
        return null;
      }

      final model = appResponse2FromJson<PostModel>(
        response.body,
        converter:
            (dynamic data) => PostModel.fromJson(data as Map<String, dynamic>),
        dataKey: 'posts',
      );

      if (model.isSuccess) {
        showSuccessToast(model.message ?? "Posts fetched successfully");
        return model;
      } else {
        showCatchToast(model.message ?? "Failed to fetch posts", null);
        return null;
      }
    } catch (exception, stack) {
      showCatchToast(exception, stack);
      return null;
    }
  }
}
