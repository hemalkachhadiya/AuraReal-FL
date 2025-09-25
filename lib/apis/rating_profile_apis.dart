import 'package:aura_real/aura_real.dart';
import 'package:aura_real/screens/rating/model/rating_profile_list_model.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class RatingProfileAPIS {
  ///Create User Profile
  static Future<http.Response?> createUserProfileAPI({
    required String userId,
    String? username,
    String? bio,
    String? dob,
    String? gender,
    String? website,
    String? phoneNumber,
    required String profileImagePath,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(EndPoints.createuserprofile),
      );

      print("API----> ${Uri.parse(EndPoints.createuserprofile)}");

      /// Helper to add valid fields
      void addFieldIfValid(
        Map<String, String> fields,
        String key,
        dynamic value,
      ) {
        if (value != null &&
            value.toString().trim().isNotEmpty &&
            value.toString() != 'null') {
          fields[key] = value.toString();
        }
      }

      /// Add text fields
      addFieldIfValid(request.fields, 'userId', userId);
      addFieldIfValid(request.fields, 'username', username);
      addFieldIfValid(request.fields, 'bio', bio);
      addFieldIfValid(request.fields, 'dob', dob);
      addFieldIfValid(request.fields, 'gender', gender);
      addFieldIfValid(request.fields, 'website', website);
      addFieldIfValid(request.fields, 'phoneNumber', phoneNumber);

      debugPrint('------> Fields: ${request.fields}');

      // Helper to get MIME type
      MediaType? _getMediaType(String filePath) {
        final mimeType = lookupMimeType(filePath);
        if (mimeType != null) {
          final parts = mimeType.split('/');
          return MediaType(parts[0], parts[1]);
        }
        return MediaType('application', 'octet-stream');
      }

      // Attach profile image
      if (profileImagePath.isNotEmpty) {
        File imageFile = File(profileImagePath);
        if (await imageFile.exists()) {
          final multipartFile = await http.MultipartFile.fromPath(
            'profile_image', // ⚡️ Use SAME field name as Postman
            profileImagePath,
            contentType: _getMediaType(profileImagePath),
          );
          request.files.add(multipartFile);
          debugPrint('------> Profile Image added: ${imageFile.path}');
        } else {
          debugPrint(
            '------> Profile Image file does not exist: $profileImagePath',
          );
          return null;
        }
      } else {
        debugPrint('------> Profile Image path is empty or invalid');
        return null;
      }

      debugPrint(
        '------> Files: ${request.files.map((f) => f.field).toList()}',
      );

      // Send request
      final response = await http.Response.fromStream(await request.send());

      debugPrint('------> Response Code: ${response.statusCode}');
      debugPrint('------> Response Body: ${response.body}');
      return response;
    } catch (e) {
      debugPrint('Exception in createUserProfileAPI: $e');
      return null;
    }
  }

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
