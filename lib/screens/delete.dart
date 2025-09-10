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
  // static Future<PostModel?> createPostAPI({
  //   required double latitude,
  //   required double longitude,
  //   required String content,
  //   required String locationId,
  //   required String postImg,
  // }) async {
  //     if (locationId.startsWith('"') && locationId.endsWith('"')) {
  //       locationId = locationId.substring(1, locationId.length - 1);
  //     }
  //   try {
  //     var request = http.MultipartRequest(
  //       'POST',
  //       Uri.parse(EndPoints.createPostAPI),
  //     );
  //
  //     print("API ==================== 1");
  //     // Add headers
  //     request.headers.addAll({'Content-Type': 'multipart/form-data'});
  //     if (postImg.isNotEmpty) {
  //       File file = File(postImg);
  //       if (await file.exists()) {
  //         request.files.add(
  //           await http.MultipartFile.fromPath('postImg', postImg),
  //         );
  //       } else {
  //         print("File does not exist: $postImg");
  //         showCatchToast('File not found', null);
  //         return null;
  //       }
  //     }
  //     // Add form fields
  //     request.fields['user_id'] = userData?.id.toString() ?? '';
  //     request.fields['latitude'] = latitude.toString();
  //     request.fields['longitude'] = longitude.toString();
  //     request.fields['content'] = content;
  //     request.fields['privacy_level'] = '0';
  //     request.fields['location_id'] = locationId;
  //     print("API ==================== 2");
  //
  //
  //
  //
  //     final response = await ApiService.postWithMultipartAPI(
  //       url: EndPoints.createPostAPI,
  //       body: request,
  //     );
  //
  //     if (kDebugMode) {
  //       print("Create Post BODY ====== ${request.fields}");
  //     }
  //     if (response == null) {
  //       showCatchToast('No response from server', null);
  //       return null;
  //     }
  //
  //     if (kDebugMode) {
  //       print("Create Post Status: ${response.statusCode}");
  //       print("Create Post -- ${response.body}");
  //     }
  //
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       try {
  //         final responseBody = jsonDecode(response.body);
  //         if (kDebugMode) {
  //           print("Res Body Data $responseBody");
  //         }
  //         if (responseBody['location'] != null && responseBody != null) {
  //           return PostModel.fromJson(responseBody['post']);
  //         }
  //       } catch (e) {
  //         print("JSON Parse Error: $e");
  //         showCatchToast('Invalid response format', null);
  //         return null;
  //       }
  //     } else {
  //       print("Server Error: ${response.statusCode} - ${response.body}");
  //       showCatchToast('Server error: ${response.statusCode}', null);
  //       return null;
  //     }
  //     return null;
  //   } catch (exception, stack) {
  //     print("Exception: $exception\nStack: $stack");
  //     showCatchToast(exception, stack);
  //     return null;
  //   }
  // }
  ///
  static Future<http.Response?> createPostAPI1({
    required double latitude,
    required double longitude,
    required String content,
    required String locationId,
    required String postImg,
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
        debugPrint('------> createPost api response.body----->${response.body}');
        debugPrint('------> createPost api response.body----->${jsonDecode(response.body)['post']}');
        debugPrint('------> createPost api response.statusCode----->${response.statusCode}');
        final model = appResponseFromJson2<PostModel>(
          response.body,
          converter:
              (dynamic data) => PostModel.fromJson(data as Map<String, dynamic>),
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
  ///
  // static Future<AppResponse2<PostModel>?> createPostAPI({
  //   required Map<String, String> body,
  //   File? profileImage,
  //   List<String> interestList = const [],
  // }) async {
  //   try {
  //     Response? response;
  //
  //     response = await ApiService.multipartApi(
  //       method: 'PATCH',
  //       files:
  //       profileImage != null
  //           ? [FileDataModel(keyName: "image", filePath: profileImage.path)]
  //           : [],
  //       url: EndPoints.createPostAPI,
  //       body: body,
  //       multipartList: [
  //         MultipartListModel(keyName: "interests", valueList: interestList),
  //       ],
  //     );
  //
  //     if (response == null) {
  //       showErrorMsg(
  //         'Update Profile Response failed: No response from server',
  //       );
  //       return null;
  //     }
  //
  //     final responseModel = appResponseFromJson2(
  //       response.body,
  //       converter: (data) => PostModel.fromJson(data),
  //     );
  //
  //     // if (responseModel.status ?? false) {
  //     //   final message = responseModel.message ?? "Profile Updated successfully";
  //     //   showSuccessToast(message);
  //     //   return responseModel;
  //     // } else {
  //     //   final errorMessage =
  //     //       responseModel.message ?? "Update Profile Response failed";
  //     //   showErrorMsg(errorMessage);
  //     //   return null;
  //     // }
  //   } catch (e, stack) {
  //     showCatchToast(e, stack, msg: "Exception: ${e.toString()}");
  //     return null;
  //   }
  // }
  ///
  // static Future<PostModel?> createPostAPI({
  //   required double latitude,
  //   required double longitude,
  //   required String content,
  //   required String locationId,
  //   required String postImg,
  // }) async {
  //   try {
  //     var request = http.MultipartRequest(
  //       'POST',
  //       Uri.parse(EndPoints.createPostAPI),
  //     );
  //
  //     print("API ==================== 1");
  //     // Add headers
  //     // request.headers.addAll(appHeader() ?? {});
  //
  //     // Add form fields
  //     request.fields['user_id'] = userData?.id.toString() ?? '';
  //      request.fields['latitude'] = latitude.toString();
  //      request.fields['longitude'] = longitude.toString();
  //     request.fields['content'] = content;
  //     request.fields['privacy_level'] = '0';
  //      request.fields['location_id'] = locationId.toString();
  //
  //     print("API ==================== 2");
  //
  //     // Add file if it exists and is valid
  //     if (postImg.isNotEmpty) {
  //       File file = File(postImg);
  //       if (await file.exists()) {
  //         String? mimeType = lookupMimeType(postImg);
  //         int fileSize = await file.length();
  //         print("File path: $postImg");
  //         print("File exists: ${await file.exists()}");
  //         print("File MIME type: $mimeType");
  //         print("File size: $fileSize bytes");
  //         if (mimeType != null && mimeType.startsWith('image/')) {
  //           print(
  //             "Uploading file: $postImg, MIME: $mimeType, Size: $fileSize bytes",
  //           );
  //           request.files.add(
  //             await http.MultipartFile.fromPath('postImg', postImg),
  //           );
  //         } else {
  //           print("Invalid file type: $mimeType");
  //           showCatchToast(
  //             'Please select a valid image file (e.g., JPG, PNG)',
  //             null,
  //           );
  //           return null;
  //         }
  //       } else {
  //         print("File does not exist: $postImg");
  //         showCatchToast('File not found', null);
  //         return null;
  //       }
  //     }
  //     print("API ==================== 3");
  //     String token = PrefService.getString(PrefKeys.token);
  //     if (token.startsWith('"') && token.endsWith('"')) {
  //       token = token.substring(1, token.length - 1);
  //     }
  //
  //     final headers = {"token": token};
  //     final response = await ApiService.postWithMultipartAPI(
  //       url: EndPoints.createPostAPI,
  //       body: request,
  //       header: headers,
  //     );
  //
  //     if (kDebugMode) {
  //       print("Create Post BODY ====== ${request.fields}");
  //     }
  //     if (response == null) {
  //       showCatchToast('No response from server', null);
  //       return null;
  //     }
  //
  //     if (kDebugMode) {
  //       print("Create Post Status: ${response.statusCode}");
  //       print("Create Post -- ${response.body}");
  //     }
  //
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       try {
  //         final responseBody = jsonDecode(response.body);
  //         if (kDebugMode) {
  //           print("Res Body Data $responseBody");
  //         }
  //         if (responseBody['location'] != null &&
  //             responseBody['post'] != null) {
  //           return PostModel.fromJson(responseBody['post']);
  //         } else {
  //           showCatchToast('Invalid response format', null);
  //           return null;
  //         }
  //       } catch (e) {
  //         print("JSON Parse Error: $e");
  //         showCatchToast('Failed to parse server response', null);
  //         return null;
  //       }
  //     } else {
  //       print("Server Error: ${response.statusCode} - ${response.body}");
  //       String errorMessage =
  //           response.statusCode == 500
  //               ? 'Invalid file type or server error'
  //               : 'Server error: ${response.statusCode}';
  //       showCatchToast(errorMessage, null);
  //       return null;
  //     }
  //   } catch (exception, stack) {
  //     print("Exception: $exception\nStack: $stack");
  //     showCatchToast(exception.toString(), stack);
  //     return null;
  //   }
  // }
  ///Success Work
  static Future createPostAPI({
    // required BuildContext context,
    // required ProgressLoader pl,
    required double latitude,
    required double longitude,
    required String content,
    required String locationId,
    required String postImg,
  }) async {
    debugPrint("__________________");
    if (locationId.startsWith('"') && locationId.endsWith('"')) {
      locationId = locationId.substring(1, locationId.length - 1);
    }
    http.MultipartRequest? request;

    try {
      request = http.MultipartRequest(
        'POST',
        Uri.parse(EndPoints.createPostAPI),
      );
      // var request = http.MultipartRequest(
      //   'POST',
      //   Uri.parse(EndPoints.createPostAPI),
      // );
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

      request.fields['user_id'] = userData?.id.toString() ?? '';
      request.fields['latitude'] = latitude.toString();
      request.fields['longitude'] = longitude.toString();
      request.fields['content'] = content;
      request.fields['privacy_level'] = '0';
      request.fields['location_id'] = locationId;

      debugPrint('------> createPost api request.body----->${request.fields}');
      // debugPrint('${}')

      MediaType? getMediaType(String filePath) {
        final mimeType = lookupMimeType(filePath);
        if (mimeType != null) {
          final parts = mimeType.split('/');
          return MediaType(parts[0], parts[1]);
        }
        // fallback if mime type is not recognized
        return MediaType('application', 'octet-stream');
      }

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

      // for (int i = 0; i < imagelist.length; i++) {
      //   if (imagelist[i] != null) {
      //     File imageFile = File(imagelist[i]!.path);
      //     if (await imageFile.exists()) {
      //       final mediaType = getMediaType(imageFile.path);
      //       request.files.add(await http.MultipartFile.fromPath(
      //         'images',
      //         imageFile.path,
      //         contentType: mediaType,
      //       ));
      //     }
      //   }
      // }
      var response = await request.send();

      var responseData = await http.Response.fromStream(response);
      debugPrint(responseData.body);
      var responseBody = jsonDecode(responseData.body);

      print("responseBody--------- $responseBody");
      if (responseData.headers['content-type']?.contains('application/json') ??
          false) {
      } else {
        debugPrint('JSON ');
      }
      debugPrint('------> createPost api response.body----->${response}');
      debugPrint(
        '------> createPost api response.statusCode----->${response.statusCode}',
      );
      debugPrint(
        '------> createPost api response.statusCode----->${response.stream}',
      );
      if (responseData.statusCode == 200) {}
    } catch (e) {
      // await pl.hide();
    }

    return null;
  }

  ///Get Post
  static Future<AppResponse2<PostModel>?> getAllPostListAPI({
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      String token = PrefService.getString(PrefKeys.token);
      var latitude = PrefService.getDouble(PrefKeys.latitude);
      var longitude = PrefService.getDouble(PrefKeys.longitude);
      if (token.startsWith('"') && token.endsWith('"')) {
        token = token.substring(1, token.length - 1);
      }

      final headers = {"token": token};

      final response = await ApiService.getApi(
        url: EndPoints.getAllPostAPI,
        queryParams: {"latitude": latitude, "longitude": longitude},
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

  ///Get Post By USer
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
