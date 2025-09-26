import 'package:aura_real/aura_real.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class PostAPI {
  /// Create Post
  static Future<http.Response?> createPostAPI({
    required double latitude,
    required double longitude,
    required String content,
    required String locationId,
    required String postImg,
    String? postVideo,
    List<String>? selectedHashtags,
  }) async {
    try {
      if (locationId.startsWith('"') && locationId.endsWith('"')) {
        locationId = locationId.substring(1, locationId.length - 1);
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(EndPoints.createPostAPI),
      );

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
      addFieldIfValid(request.fields, 'user_id', userData?.id);
      addFieldIfValid(request.fields, 'content', content);
      addFieldIfValid(request.fields, 'privacy_level', '0');
      addFieldIfValid(request.fields, 'location_id', locationId);
      if (selectedHashtags != null && selectedHashtags.isNotEmpty) {
        addFieldIfValid(request.fields, 'hashtags', selectedHashtags.join(','));
      }

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

      // Attach **only one file** at a time (backend usually expects this)
      if (postImg.isNotEmpty && (postVideo == null || postVideo.isEmpty)) {
        File imageFile = File(postImg);
        if (await imageFile.exists()) {
          final multipartFile = await http.MultipartFile.fromPath(
            'postImg',
            // ⚡️ use SAME field name as Postman (change if backend expects `postImg`)
            postImg,
            contentType: _getMediaType(postImg),
          );
          request.files.add(multipartFile);
          debugPrint('------> Image added: ${imageFile.path}');
        }
      } else if (postVideo != null && postVideo.isNotEmpty) {
        File videoFile = File(postVideo);
        if (await videoFile.exists()) {
          final multipartFile = await http.MultipartFile.fromPath(
            'postVideo',
            // ⚡️ use SAME field name as Postman (change if backend expects `postVideo`)
            postVideo,
            contentType: _getMediaType(postVideo),
          );
          request.files.add(multipartFile);
          debugPrint('------> postVideo: ${postVideo}');
          debugPrint('------> Video added: ${videoFile.path}');
        }
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
      debugPrint('Exception in createPostAPI: $e');
      return null;
    }
  }

  ///Get Post
  static Future<AppResponse2<PostModel>?> getAllPostListAPI({
    int page = 1,
    int pageSize = 5,
    String? search,
  }) async {
    String token = PrefService.getString(PrefKeys.token);
    try {
      if (token.startsWith('"') && token.endsWith('"')) {
        token = token.substring(1, token.length - 1);
      }

      final headers = {"token": token};
      // Build query params
      final queryParams = {
        "page": page,
        "page_size": pageSize,
        "user_id": userData?.id,
        if (search != null && search.isNotEmpty) "search": search,
        // Add search if provided
      };
      final response = await ApiService.getApi(
        url: EndPoints.getAllPostAPI,
        queryParams: queryParams,
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
        showSuccessToast(model.message ?? "Message Form Register API");
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
    String? parentCommentId, // <-- for reply
  }) async {
    try {
      final body = {
        "post_id": postId,
        "content": content,
        "user_id": userData?.id,
      };

      // Add only if it's a reply
      if (parentCommentId != null && parentCommentId.isNotEmpty) {
        body["parent_comment_id"] = parentCommentId;
      }

      final response = await ApiService.postApi(
        url: EndPoints.createcomment,
        body: body,
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
}
