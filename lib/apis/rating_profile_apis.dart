import 'package:aura_real/aura_real.dart';
import 'package:aura_real/screens/rating/model/rating_profile_list_model.dart';

class RatingProfileAPIS {
  ///Get All Rating Profile List

  static Future<AppResponse2<RatingProfileUserModel>?>
  getAllRatingProfileUSerListAPI({
    int page = 1,
    int pageSize = 1000,
    String? latitude,
    String? longitude,
  }) async {
    String token = PrefService.getString(PrefKeys.token);
    try {
      // Clean up token if it has extra quotes
      if (token.startsWith('"') && token.endsWith('"')) {
        token = token.substring(1, token.length - 1);
      }

      final headers = {"token": token};

      final response = await ApiService.getApi(
        url: EndPoints.getAllUsers,
        queryParams: {
          "page": page,
          "page_size": pageSize,
          "latitude": latitude,
          "longitude": longitude,
          "radius": 10,
        },
        header: headers,
      );

      if (response == null) {
        showCatchToast('No response from server', null);
        return null;
      }

      print("Response Get all user === ${response.body}");
      // Explicitly specify 'users' since this is the users API
      final model = appResponseFromJson2<RatingProfileUserModel>(
        response.body,
        converter:
            (dynamic data) =>
                RatingProfileUserModel.fromJson(data as Map<String, dynamic>),
        dataKey: 'users',
      );

      if (model.isSuccess) {

        return model;
      } else {
        showCatchToast(model.message ?? "Failed to fetch users", null);
        return null;
      }
    } catch (exception, stack) {
      showCatchToast(exception, stack);
      return null;
    }
  }
}
