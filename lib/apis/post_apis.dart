import 'package:aura_real/apis/app_response_2.dart';
import 'package:aura_real/aura_real.dart';

class PostAPI {
  static Future<AppResponse2<PostListModel>?> getAllPostListAPI({
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await ApiService.getApi(url: EndPoints.getAllPostAPI);

      if (response == null) {
        showCatchToast('No response from server', null);
        return null;
      }

      final model = appResponse2FromJson<PostListModel>(
        response.body,
        converter:
            (dynamic data) =>
                PostListModel.fromJson(data as Map<String, dynamic>),
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


  static Future<AppResponse2<PostListModel>?> getPostByUserAPI({
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await ApiService.getApi(url: EndPoints.getPostByUSer);

      if (response == null) {
        showCatchToast('No response from server', null);
        return null;
      }

      final model = appResponse2FromJson<PostListModel>(
        response.body,
        converter:
            (dynamic data) =>
            PostListModel.fromJson(data as Map<String, dynamic>),
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
