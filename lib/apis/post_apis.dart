import 'package:aura_real/apis/app_response.dart';
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
    int pageSize = 5,
  }) async {
    String token = PrefService.getString(PrefKeys.token);
    try {
      if (token.startsWith('"') && token.endsWith('"')) {
        token = token.substring(1, token.length - 1);
      }

      final headers = {"token": token};

      final response = await ApiService.getApi(
        url: EndPoints.getAllPostAPI,
        queryParams: {"page": page, "page_size": pageSize},
        header: headers,
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
        // showSuccessToast(model.message ?? "Posts fetched successfully");
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

  ///Get Post By USer
  static Future<AppResponse2<PostModel>?> getPostByUserAPI({
    int page = 1,
    int pageSize = 10,
    String? userId,
  }) async {
    String token = PrefService.getString(PrefKeys.token);
    print("userId======== ${userId}");
    try {
      if (token.startsWith('"') && token.endsWith('"')) {
        token = token.substring(1, token.length - 1);
      }
      final headers = {"token": token};
      final response = await ApiService.getApi(
        url:
            '${EndPoints.getUserProfileWithPosts}$userId&currentUserId=${userData?.id}',
        header: headers,
      );

      if (response == null) {
        showCatchToast('No response from server', null);
        return null;
      }

      print("API GET BY USER POST ${response.body}");

      final model = appResponseFromJson2<PostModel>(
        response.body,
        converter:
            (dynamic data) => PostModel.fromJson(data as Map<String, dynamic>),
        dataKey: 'posts',
      );

      if (model.isSuccess) {
        print("Profile model======== ${model.profile?.username}");
        // showSuccessToast(model.message ?? "Posts fetched successfully");
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

  ///Update Rate API
  static Future<bool> updateRatePostAPI({
    required String postId,
    required String rating,
  }) async {
    try {
      final response = await ApiService.putApi(
        url: EndPoints.updatePostRating,
        body: {"postId": postId, "newRating": rating, "userId": userData?.id},
      );
      if (response == null) {
        showCatchToast('No response from server', null);
        return false;
      }

      final model = appResponseFromJson(response.body);

      if (model.success == true) {
        showSuccessToast(model.message ?? "Message Form Register API");
        return true;
      } else {
        return false;
      }
    } catch (exception, stack) {
      showCatchToast(exception, stack);
    }
    return false;
  }

  ///New Rate API
  static Future<bool> newRatePostAPI({
    required String postId,
    required String newRating,
  }) async {
    try {
      final response = await ApiService.postApi(
        url: EndPoints.newRatePost,
        body: {"postId": postId, "rating": newRating, "userId": userData?.id},
      );
      if (response == null) {
        showCatchToast('No response from server', null);
        return false;
      }
      final model = appResponseFromJson(response.body);
      if (model.success == true) {
        showSuccessToast(model.message ?? "Message Form Register API");
        return true;
      } else {
        return false;
      }
    } catch (exception, stack) {
      showCatchToast(exception, stack);
    }
    return false;
  }

  ///Comment Post API
  static Future<Map<String, dynamic>?> commentOnPostAPI({
    required String postId,
    required String content,
  }) async {
    try {
      final response = await ApiService.postApi(
        url: EndPoints.createcomment,
        body: {"post_id": postId, "content": content, "user_id": userData?.id},
      );
      if (response == null) {
        showCatchToast('No response from server', null);
        return {'success': false, 'response': null};
      }
      final model = appResponseFromJson(response.body);
      if (model.success == true) {
        showSuccessToast(model.message ?? "Message from Comment API");
        return {'success': true, 'response': response};
      } else if (response.statusCode == 400) {
        // Handle specific 400 error case
        final errorModel = appResponseFromJson(response.body);
        if (errorModel.message == "You have already commented on this post") {
          showErrorMsg(errorModel.message ?? "Error");
          return {'success': false, 'response': response, 'isDuplicate': true};
        }
      }
      // Handle other failure cases
      showCatchToast(model.message ?? "Failed to comment", null);
      return {'success': false, 'response': response};
    } catch (exception, stack) {
      print("Catch Stack ======== $stack");
      showCatchToast(exception, stack);
      return {'success': false, 'response': null};
    }
  }
  // static Future<bool> commentOnPostAPI({
  //   required String postId,
  //   required String content,
  // }) async {
  //   try {
  //     final response = await ApiService.postApi(
  //       url: EndPoints.createcomment,
  //       body: {"post_id": postId, "content": content, "user_id": userData?.id},
  //     );
  //     if (response == null) {
  //       showCatchToast('No response from server', null);
  //       return false;
  //     }
  //     final model = appResponseFromJson(response.body);
  //     if (model.success == true) {
  //       showSuccessToast(model.message ?? "Message Form Comment API");
  //       return true;
  //     }
  //   } catch (exception, stack) {
  //     print("Catch Starck=========");
  //     showCatchToast(exception, stack);
  //   }
  //   return false;
  // }

  ///Get All Comment List
  static Future<AppResponse2<CommentModel>?> getAllCommentListAPI({
    required String postId,
    int page = 1,
    int pageSize = 10,
  }) async {
    String token = PrefService.getString(PrefKeys.token);
    try {
      if (token.startsWith('"') && token.endsWith('"')) {
        token = token.substring(1, token.length - 1);
      }

      final headers = {"token": token};
      final queryParams = {
        'post_id': postId,
        'page': page.toString(),
        'page_size': pageSize.toString(),
      };

      final response = await ApiService.getApi(
        url: EndPoints.getcomments,
        header: headers,
        queryParams: queryParams,
      );

      if (response == null) {
        showCatchToast('No response from server', null);
        return null;
      }

      // Debug the raw response
      print('Raw response body: ${response.body}');

      // Decode the response body
      final decodedBody = jsonDecode(response.body) as Map<String, dynamic>;
      print('Decoded response: $decodedBody');

      final model = appResponseFromJson2<CommentModel>(
        response.body, // Ensure consistent string input
        converter:
            (dynamic data) =>
                CommentModel.fromJson(data as Map<String, dynamic>),

        dataKey: 'comments',
      );

      if (model.isSuccess) {
        // showSuccessToast(model.message ?? "Comments fetched successfully");
        return model;
      } else {
        showCatchToast(model.message ?? "Failed to fetch comments", null);
        return null;
      }
    } catch (exception, stack) {
      print('Exception in getAllCommentListAPI: $exception\nStack: $stack');
      showCatchToast(exception, stack);
      return null;
    }
  }
  // static Future<AppResponse2<CommentModel>?> getAllCommentListAPI({
  //   int page = 1,
  //   int pageSize = 10,
  //   String? postId
  // }) async {
  //   try {
  //     String token = PrefService.getString(PrefKeys.token);
  //       if (token.startsWith('"') && token.endsWith('"')) {
  //         token = token.substring(1, token.length - 1);
  //       }
  //
  //     //   final headers = {"token": token};
  //
  //     // final response = await ApiService.getApi(url: EndPoints.getcomments);
  //     final headers = {"token": token};
  //     final queryParams = {
  //       'post_id': postId,
  //       'page': page.toString(),
  //       'page_size': pageSize.toString(),
  //     };
  //
  //     final uri = Uri.parse(EndPoints.getcomments).replace(queryParameters: queryParams);
  //     final response = await ApiService.getApi(url: uri.toString(), header: headers);
  //     if (response == null) {
  //       showCatchToast('No response from server', null);
  //       return null;
  //     }
  //
  //     final model = appResponseFromJson2<CommentModel>(
  //       response.body,
  //       converter:
  //           (dynamic data) =>
  //               CommentModel.fromJson(data as Map<String, dynamic>),
  //       dataKey: 'comments',
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
}
