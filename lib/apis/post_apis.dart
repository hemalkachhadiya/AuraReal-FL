import 'package:aura_real/apis/app_response_2.dart';
import 'package:aura_real/apis/model/file_data_model.dart';
import 'package:aura_real/apis/model/multipart_list_model.dart';
import 'package:aura_real/aura_real.dart';
import 'package:aura_real/apis/model/post_model.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart' show Response;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class PostAPI {
  ///Create Post

  static Future<http.Response?> createPostAPI({
    required double latitude,
    required double longitude,
    required String content,
    required String locationId,
    required String postImg,
    List<String>? selectedHashtags, // Added parameter for hashtags
  }) async {
    try {
      // Clean up locationId if it starts and ends with quotes
      if (locationId.startsWith('"') && locationId.endsWith('"')) {
        locationId = locationId.substring(1, locationId.length - 1);
      }

      // Create a MultipartRequest
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(EndPoints.createPostAPI),
      );

      // Helper function to add fields if valid
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

      // Add fields to the request
      addFieldIfValid(request.fields, 'user_id', userData?.id);
      addFieldIfValid(request.fields, 'latitude', latitude);
      addFieldIfValid(request.fields, 'longitude', longitude);
      addFieldIfValid(request.fields, 'content', content);
      addFieldIfValid(request.fields, 'privacy_level', '0');
      addFieldIfValid(request.fields, 'location_id', locationId);
      // Convert selectedHashtags list to a comma-separated string and add to fields
      if (selectedHashtags != null && selectedHashtags.isNotEmpty) {
        addFieldIfValid(request.fields, 'hashtags', selectedHashtags.join(','));
      }

      debugPrint('------> createPost api request.body----->${request.fields}');

      // Helper function to get media type
      MediaType? getMediaType(String filePath) {
        final mimeType = lookupMimeType(filePath);
        if (mimeType != null) {
          final parts = mimeType.split('/');
          return MediaType(parts[0], parts[1]);
        }
        return MediaType('application', 'octet-stream');
      }

      // Add image file if it exists
      File imageFile = File(postImg);
      if (await imageFile.exists()) {
        final mediaType = getMediaType(postImg);
        request.files.add(
          await http.MultipartFile.fromPath(
            'postImg',
            postImg,
            contentType: mediaType,
          ),
        );
      } else {
        debugPrint('Image file not found at: $postImg');
      }

      // Call the postWithMultipartAPI service
      final response = await ApiService.postWithMultipartAPI(
        url: EndPoints.createPostAPI,
        body: request,
      );

      if (response != null) {
        debugPrint(
          '------> createPost api response.body----->${response.body}',
        );
        debugPrint(
          '------> createPost api response.body----->${jsonDecode(response.body)['post']}',
        );
        debugPrint(
          '------> createPost api response.statusCode----->${response.statusCode}',
        );
        final model = appResponseFromJson2<PostModel>(
          response.body,
          converter:
              (dynamic data) =>
                  PostModel.fromJson(data as Map<String, dynamic>),
          dataKey: 'posts',
        );
        return response;
      } else {
        debugPrint('Failed to create post: No response received');
        return null;
      }
    } catch (e) {
      debugPrint('Exception in createPostAPI1: $e');
      return null;
    }
  }

  ///Get Post
  static Future<AppResponse2<PostModel>?> getAllPostListAPI({
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      String token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY4YmU4OGI5NWIzMmU0Y2MxYzA3OWM3NSIsImlhdCI6MTc1NzMzNDM1NSwiZXhwIjoxNzU3OTM5MTU1fQ.lxyp1jx-A_id1aSYWw8DHjLoR169ofFG8T9Ox6eNYHE";
      final headers = {"token": token};

      final response = await ApiService.getApi(
        url: EndPoints.getAllPostAPI,
        header: headers,
      );

      if (response == null) {
        showCatchToast('No response from server', null);
        return null;
      }


      final model = appResponseFromJson2<PostModel>(
        response.body,
        converter: (dynamic data) => PostModel.fromJson(data as Map<String, dynamic>),
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
  // static Future<AppResponse2<PostModel>?> getAllPostListAPI({
  //   int page = 1,
  //   int pageSize = 10,
  // }) async {
  //   try {
  //     String token = PrefService.getString(PrefKeys.token);
  //     var latitude = PrefService.getDouble(PrefKeys.latitude);
  //     var longitude = PrefService.getDouble(PrefKeys.longitude);
  //     if (token.startsWith('"') && token.endsWith('"')) {
  //       token = token.substring(1, token.length - 1);
  //     }
  //
  //     // final headers = {"token": token};
  //     final headers = {"token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY4YmU4OGI5NWIzMmU0Y2MxYzA3OWM3NSIsImlhdCI6MTc1NzMzNDM1NSwiZXhwIjoxNzU3OTM5MTU1fQ.lxyp1jx-A_id1aSYWw8DHjLoR169ofFG8T9Ox6eNYHE"};
  //
  //     final response = await ApiService.getApi(
  //       url: EndPoints.getAllPostAPI,
  //       // queryParams: {"latitude": latitude, "longitude": longitude},
  //       header: headers,
  //     );
  //
  //     if (response == null) {
  //       showCatchToast('No response from server', null);
  //       return null;
  //     }
  //
  //     final model = appResponseFromJson2<PostModel>(
  //       response.body,
  //       converter:
  //           (dynamic data) => PostModel.fromJson(data as Map<String, dynamic>),
  //       dataKey: 'posts',
  //     );
  //
  //     if (model.isSuccess) {
  //       showSuccessToast(model.message ?? "Posts fetched successfully");
  //       return model;
  //     } else {
  //       showCatchToast(model.message ?? "Failed to fetch posts", null);
  //       return null;
  //     }
  //   } catch (exception, stack) {
  //     showCatchToast(exception, stack);
  //     return null;
  //   }
  // }

  ///Get Post By USer
  static Future<AppResponse2<PostModel>?> getPostByUserAPI({
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await ApiService.getApi(
        url: EndPoints.getUserProfileWithPosts,
      );

      if (response == null) {
        showCatchToast('No response from server', null);
        return null;
      }

      final model = appResponseFromJson2<PostModel>(
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
