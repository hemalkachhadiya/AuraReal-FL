import 'package:aura_real/apis/app_response.dart';
import 'package:aura_real/apis/app_response_2.dart';
import 'package:aura_real/apis/model/file_data_model.dart';
import 'package:aura_real/apis/model/multipart_list_model.dart';
import 'package:aura_real/aura_real.dart';
import 'package:aura_real/apis/model/post_model.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart' show Response;
import 'package:http_parser/http_parser.dart';
import 'package:http_parser/http_parser.dart' as http;
import 'package:mime/mime.dart';
import 'package:mime/mime.dart' as mime;

class PostAPI {
  /// Create Post

  // static Future<http.Response?> createPostAPI({
  //   required double latitude,
  //   required double longitude,
  //   required String content,
  //   required String locationId,
  //   required String mediaPath,
  //   List<String>? selectedHashtags,
  // }) async {
  //   print("create post =================== ");
  //   try {
  //     // Clean up locationId if it starts and ends with quotes
  //     if (locationId.startsWith('"') && locationId.endsWith('"')) {
  //       locationId = locationId.substring(1, locationId.length - 1);
  //     }
  //
  //     // Create a MultipartRequest
  //     var request = http.MultipartRequest(
  //       'POST',
  //       Uri.parse(EndPoints.createPostAPI),
  //     );
  //
  //     // Helper function to add fields if valid
  //     void addFieldIfValid(
  //       Map<String, String> fields,
  //       String key,
  //       dynamic value,
  //     ) {
  //       if (value != null &&
  //           value.toString().trim().isNotEmpty &&
  //           value.toString() != 'null') {
  //         fields[key] = value.toString();
  //       }
  //     }
  //
  //     // Add fields to the request
  //     addFieldIfValid(request.fields, 'user_id', userData?.id);
  //     addFieldIfValid(request.fields, 'latitude', latitude.toString());
  //     addFieldIfValid(request.fields, 'longitude', longitude.toString());
  //     addFieldIfValid(request.fields, 'content', content);
  //     addFieldIfValid(request.fields, 'privacy_level', '0');
  //     addFieldIfValid(request.fields, 'location_id', locationId);
  //     if (selectedHashtags != null && selectedHashtags.isNotEmpty) {
  //       addFieldIfValid(request.fields, 'hashtags', selectedHashtags.join(','));
  //     }
  //
  //     debugPrint(
  //       '------> createPost api request.fields----->${request.fields}',
  //     );
  //
  //     // Helper function to get media type
  //     MediaType? getMediaType(String filePath) {
  //       try {
  //         final mimeType = mime.lookupMimeType(filePath);
  //         debugPrint('------> Detected MIME type for $filePath: $mimeType');
  //         if (mimeType != null) {
  //           final parts = mimeType.split('/');
  //           return http.MediaType(parts[0], parts[1]);
  //         }
  //         debugPrint('------> No MIME type detected, using fallback');
  //         return http.MediaType('application', 'octet-stream');
  //       } catch (e) {
  //         debugPrint('------> Error getting media type: $e');
  //         return http.MediaType('application', 'octet-stream');
  //       }
  //     }
  //
  //     // Add media file if it exists
  //     File mediaFile = File(mediaPath);
  //     if (await mediaFile.exists()) {
  //       final mediaType = getMediaType(mediaPath);
  //       final fieldName =
  //           mediaType?.type == 'image'
  //               ? 'postImg'
  //               : 'postVideo'; // Dynamic field name
  //       try {
  //         final multipartFile = await http.MultipartFile.fromPath(
  //           fieldName,
  //           mediaPath,
  //           contentType: mediaType,
  //         );
  //         request.files.add(multipartFile);
  //         debugPrint(
  //           '------> File added: ${mediaFile.path} as $fieldName with type $mediaType',
  //         );
  //         debugPrint(
  //           '------> Request files: ${request.files.map((f) => f.field).toList()}',
  //         ); // Log all field names
  //         // Attempt to log the raw multipart data (approximation)
  //         final requestBody =
  //             await request
  //                 .finalize()
  //                 .join(); // Join the stream to see raw data
  //         debugPrint(
  //           '------> Raw request body (partial): ${utf8.decode(requestBody.runes.take(1000).toList())}',
  //         ); // Limit to 1000 chars
  //       } catch (e) {
  //         debugPrint('------> Error adding file to request: $e');
  //         return null;
  //       }
  //     } else {
  //       debugPrint('Media file not found at: $mediaPath');
  //       return null;
  //     }
  //
  //     // Add authorization header
  //     // request.headers['token'] =
  //     //     "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY4YzM5ZWE3NzZmYmE4NDEzYzNmZWIyMyIsImlhdCI6MTc1ODAxNjQ5MiwiZXhwIjoxNzU4NjIxMjkyfQ.Y8NpWHX-fpKDuCjDUyR-T9CD9RBgs5tZ-gNhoK2Cdtk";
  //
  //     // Log the full request before sending
  //     debugPrint('------> Full request: ${request.toString()}');
  //
  //     // Call the postWithMultipartAPI service
  //     final response = await ApiService.postWithMultipartAPI(
  //       url: EndPoints.createPostAPI,
  //       body: request,
  //     );
  //
  //     if (response != null) {
  //       debugPrint(
  //         '------> createPost api response.body----->${response.body}',
  //       );
  //       debugPrint(
  //         '------> createPost api response.statusCode----->${response.statusCode}',
  //       );
  //       final model = appResponseFromJson2<PostModel>(
  //         response.body,
  //         converter:
  //             (dynamic data) =>
  //                 PostModel.fromJson(data as Map<String, dynamic>),
  //         dataKey: 'posts',
  //       );
  //       return response;
  //     } else {
  //       debugPrint('Failed to create post: No response received');
  //       return null;
  //     }
  //   } catch (e) {
  //     debugPrint('Exception in createPostAPI1: $e');
  //     return null;
  //   }
  // }
  ///
  // static Future<http.Response?> createPostAPI({
  //   required double latitude,
  //   required double longitude,
  //   required String content,
  //   required String locationId,
  //   required String postImg,
  //   List<String>? selectedHashtags, // Added parameter for hashtags
  // }) async {
  //   try {
  //     // Clean up locationId if it starts and ends with quotes
  //     if (locationId.startsWith('"') && locationId.endsWith('"')) {
  //       locationId = locationId.substring(1, locationId.length - 1);
  //     }
  //
  //     // Create a MultipartRequest
  //     var request = http.MultipartRequest(
  //       'POST',
  //       Uri.parse(EndPoints.createPostAPI),
  //     );
  //
  //     // Helper function to add fields if valid
  //     void addFieldIfValid(
  //       Map<String, String> fields,
  //       String key,
  //       dynamic value,
  //     ) {
  //       if (value != null &&
  //           value.toString().trim().isNotEmpty &&
  //           value.toString() != 'null') {
  //         fields[key] = value.toString();
  //       }
  //     }
  //
  //     // Add fields to the request
  //     addFieldIfValid(request.fields, 'user_id', userData?.id);
  //     addFieldIfValid(request.fields, 'latitude', latitude);
  //     addFieldIfValid(request.fields, 'longitude', longitude);
  //     addFieldIfValid(request.fields, 'content', content);
  //     addFieldIfValid(request.fields, 'privacy_level', '0');
  //     addFieldIfValid(request.fields, 'location_id', locationId);
  //     // Convert selectedHashtags list to a comma-separated string and add to fields
  //     if (selectedHashtags != null && selectedHashtags.isNotEmpty) {
  //       addFieldIfValid(request.fields, 'hashtags', selectedHashtags.join(','));
  //     }
  //
  //     debugPrint('------> createPost api request.body----->${request.fields}');
  //
  //     // Helper function to get media type
  //     MediaType? getMediaType(String filePath) {
  //       final mimeType = lookupMimeType(filePath);
  //       if (mimeType != null) {
  //         final parts = mimeType.split('/');
  //         return MediaType(parts[0], parts[1]);
  //       }
  //       return MediaType('application', 'octet-stream');
  //     }
  //
  //     // Add image file if it exists
  //     File imageFile = File(postImg);
  //     if (await imageFile.exists()) {
  //       final mediaType = getMediaType(postImg);
  //       request.files.add(
  //         await http.MultipartFile.fromPath(
  //           'postImg',
  //           postImg,
  //           contentType: mediaType,
  //         ),
  //       );
  //     } else {
  //       debugPrint('Image file not found at: $postImg');
  //     }
  //
  //     // Call the postWithMultipartAPI service
  //     final response = await ApiService.postWithMultipartAPI(
  //       url: EndPoints.createPostAPI,
  //       body: request,
  //     );
  //
  //     if (response != null) {
  //       debugPrint(
  //         '------> createPost api response.body----->${response.body}',
  //       );
  //       debugPrint(
  //         '------> createPost api response.body----->${jsonDecode(response.body)['post']}',
  //       );
  //       debugPrint(
  //         '------> createPost api response.statusCode----->${response.statusCode}',
  //       );
  //       final model = appResponseFromJson2<PostModel>(
  //         response.body,
  //         converter:
  //             (dynamic data) =>
  //                 PostModel.fromJson(data as Map<String, dynamic>),
  //         dataKey: 'posts',
  //       );
  //       return response;
  //     } else {
  //       debugPrint('Failed to create post: No response received');
  //       return null;
  //     }
  //   } catch (e) {
  //     debugPrint('Exception in createPostAPI1: $e');
  //     return null;
  //   }
  // }
  ///
  // static Future<http.Response?> createPostAPI({
  //   required double latitude,
  //   required double longitude,
  //   required String content,
  //   required String locationId,
  //   required String postImg,
  //   String? postVideo, // Added parameter for video
  //   List<String>? selectedHashtags, // Existing parameter for hashtags
  // }) async {
  //   try {
  //     // Clean up locationId if it starts and ends with quotes
  //     if (locationId.startsWith('"') && locationId.endsWith('"')) {
  //       locationId = locationId.substring(1, locationId.length - 1);
  //     }
  //
  //     // Create a MultipartRequest
  //     var request = http.MultipartRequest(
  //       'POST',
  //       Uri.parse(EndPoints.createPostAPI),
  //     );
  //
  //     // Helper function to add fields if valid
  //     void addFieldIfValid(
  //       Map<String, String> fields,
  //       String key,
  //       dynamic value,
  //     ) {
  //       if (value != null &&
  //           value.toString().trim().isNotEmpty &&
  //           value.toString() != 'null') {
  //         fields[key] = value.toString();
  //       }
  //     }
  //
  //     // Add fields to the request
  //     addFieldIfValid(request.fields, 'user_id', userData?.id);
  //     addFieldIfValid(request.fields, 'latitude', latitude);
  //     addFieldIfValid(request.fields, 'longitude', longitude);
  //     addFieldIfValid(request.fields, 'content', content);
  //     addFieldIfValid(request.fields, 'privacy_level', '0');
  //     addFieldIfValid(request.fields, 'location_id', locationId);
  //     // Convert selectedHashtags list to a comma-separated string and add to fields
  //     if (selectedHashtags != null && selectedHashtags.isNotEmpty) {
  //       addFieldIfValid(request.fields, 'hashtags', selectedHashtags.join(','));
  //     }
  //
  //     debugPrint('------> createPost api request.body----->${request.fields}');
  //
  //     // Helper function to get media type
  //     MediaType? getMediaType(String filePath) {
  //       final mimeType = lookupMimeType(filePath);
  //       if (mimeType != null) {
  //         final parts = mimeType.split('/');
  //         return MediaType(parts[0], parts[1]);
  //       }
  //       return MediaType('application', 'octet-stream');
  //     }
  //
  //     // Add image file if it exists
  //     File imageFile = File(postImg);
  //     if (await imageFile.exists()) {
  //       final mediaType = getMediaType(postImg);
  //       try {
  //         final multipartFile = await http.MultipartFile.fromPath(
  //           'postImg',
  //           postImg,
  //           contentType: mediaType,
  //         );
  //         request.files.add(multipartFile);
  //         debugPrint(
  //           '------> Image added: ${imageFile.path} with type $mediaType',
  //         );
  //       } catch (e) {
  //         debugPrint('------> Error adding image file: $e');
  //       }
  //     } else {
  //       debugPrint('------> Image file not found at: $postImg');
  //     }
  //
  //     // Add video file if it exists
  //     if (postVideo != null && postVideo.isNotEmpty) {
  //       File videoFile = File(postVideo);
  //       if (await videoFile.exists()) {
  //         final mediaType = getMediaType(postVideo);
  //         try {
  //           final multipartFile = await http.MultipartFile.fromPath(
  //             'postVideo',
  //             postVideo,
  //             contentType: mediaType,
  //           );
  //           request.files.add(multipartFile);
  //           print("Video File ======== ${videoFile}");
  //           debugPrint(
  //             '------> Video added: ${videoFile.path} with type $mediaType',
  //           );
  //         } catch (e) {
  //           debugPrint('------> Error adding video file: $e');
  //         }
  //       } else {
  //         debugPrint('------> Video file not found at: $postVideo');
  //       }
  //     }
  //
  //     print("Image file============= ${imageFile}");
  //
  //     // Call the postWithMultipartAPI service
  //     final response = await ApiService.postWithMultipartAPI(
  //       url: EndPoints.createPostAPI,
  //       body: request,
  //     );
  //
  //     if (response != null) {
  //       debugPrint(
  //         '------> createPost api response.body----->${response.body}',
  //       );
  //       debugPrint(
  //         '------> createPost api response.body----->${jsonDecode(response.body)['post']}',
  //       );
  //       debugPrint(
  //         '------> createPost api response.statusCode----->${response.statusCode}',
  //       );
  //       final model = appResponseFromJson2<PostModel>(
  //         response.body,
  //         converter:
  //             (dynamic data) =>
  //                 PostModel.fromJson(data as Map<String, dynamic>),
  //         dataKey: 'posts',
  //       );
  //       return response;
  //     } else {
  //       debugPrint('Failed to create post: No response received');
  //       return null;
  //     }
  //   } catch (e) {
  //     debugPrint('Exception in createPostAPI1: $e');
  //     return null;
  //   }
  // }
  /// FIXED VERSION - Try different field names
  // static Future<http.Response?> createPostAPI({
  //   required double latitude,
  //   required double longitude,
  //   required String content,
  //   required String locationId,
  //   required String postImg,
  //   String? postVideo,
  //   List<String>? selectedHashtags,
  // }) async {
  //   try {
  //     // Clean up locationId if it starts and ends with quotes
  //     if (locationId.startsWith('"') && locationId.endsWith('"')) {
  //       locationId = locationId.substring(1, locationId.length - 1);
  //     }
  //
  //     // Create a MultipartRequest
  //     var request = http.MultipartRequest(
  //       'POST',
  //       Uri.parse(EndPoints.createPostAPI),
  //     );
  //
  //     // Helper function to add fields if valid
  //     void addFieldIfValid(
  //         Map<String, String> fields,
  //         String key,
  //         dynamic value,
  //         ) {
  //       if (value != null &&
  //           value.toString().trim().isNotEmpty &&
  //           value.toString() != 'null') {
  //         fields[key] = value.toString();
  //       }
  //     }
  //
  //     // Add fields to the request
  //     addFieldIfValid(request.fields, 'user_id', userData?.id);
  //     addFieldIfValid(request.fields, 'content', content);
  //     addFieldIfValid(request.fields, 'privacy_level', '0');
  //     addFieldIfValid(request.fields, 'location_id', locationId);
  //     if (selectedHashtags != null && selectedHashtags.isNotEmpty) {
  //       addFieldIfValid(request.fields, 'hashtags', selectedHashtags.join(','));
  //     }
  //
  //     debugPrint('------> createPost api request.fields----->${request.fields}');
  //
  //     // Helper function to get media type
  //     MediaType? getMediaType(String filePath) {
  //       final mimeType = lookupMimeType(filePath);
  //       if (mimeType != null) {
  //         final parts = mimeType.split('/');
  //         print("mime ====================== 1");
  //         print(mimeType);
  //         return MediaType(parts[0], parts[1]);
  //       }
  //       print("mime ====================== 2");
  //       return MediaType('application', 'octet-stream');
  //     }
  //
  //     // SOLUTION 1: Only send ONE media type at a time
  //     bool hasMedia = false;
  //
  //     // Add image file if it exists AND no video
  //     if (postImg.isNotEmpty && (postVideo == null || postVideo.isEmpty)) {
  //       print("Media============================Image===========================");
  //       File imageFile = File(postImg);
  //       if (await imageFile.exists()) {
  //         final mediaType = getMediaType(postImg);
  //         try {
  //           final multipartFile = await http.MultipartFile.fromPath(
  //             'postImg', // Keep this for images
  //             postImg,
  //             contentType: mediaType,
  //           );
  //           request.files.add(multipartFile);
  //           hasMedia = true;
  //           debugPrint('------> Image added: ${imageFile.path} with type $mediaType');
  //         } catch (e) {
  //           debugPrint('------> Error adding image file: $e');
  //         }
  //       } else {
  //         debugPrint('------> Image file not found at: $postImg');
  //       }
  //     }
  //
  //     // Add video file if it exists AND no image
  //     if (postVideo != null && postVideo.isNotEmpty && !hasMedia) {
  //       print("Media=========================video==============================");
  //       File videoFile = File(postVideo);
  //       if (await videoFile.exists()) {
  //         final mediaType = getMediaType(postVideo);
  //         try {
  //           // SOLUTION 2: Try different field names - uncomment one at a time to test
  //           final multipartFile = await http.MultipartFile.fromPath(
  //             'postVideo', // Try this first (current)
  //             // 'video',     // Try this if above fails
  //             // 'file',      // Try this if above fails
  //             // 'media',     // Try this if above fails
  //             postVideo,
  //
  //           );
  //           request.files.add(multipartFile);
  //           debugPrint('------> Video added: ${videoFile.path} with type $mediaType');
  //         } catch (e) {
  //           debugPrint('------> Error adding video file: $e');
  //         }
  //       } else {
  //         debugPrint('------> Video file not found at: $postVideo');
  //       }
  //     }
  //
  //     debugPrint('------> Files being sent: ${request.files.map((f) => f.field).toList()}');
  //
  //     // Call the postWithMultipartAPI service
  //     final response = await ApiService.postWithMultipartAPI(
  //       url: EndPoints.createPostAPI,
  //       body: request,
  //     );
  //
  //     if (response != null) {
  //       debugPrint('------> createPost api response.body----->${response.body}');
  //       debugPrint('------> createPost api response.statusCode----->${response.statusCode}');
  //       final model = appResponseFromJson2<PostModel>(
  //         response.body,
  //         converter: (dynamic data) => PostModel.fromJson(data as Map<String, dynamic>),
  //         dataKey: 'posts',
  //       );
  //       return response;
  //     } else {
  //       debugPrint('Failed to create post: No response received');
  //       return null;
  //     }
  //   } catch (e) {
  //     debugPrint('Exception in createPostAPI: $e');
  //     return null;
  //   }
  // }
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

      // Helper to add valid fields
      void addFieldIfValid(Map<String, String> fields, String key, dynamic value) {
        if (value != null &&
            value.toString().trim().isNotEmpty &&
            value.toString() != 'null') {
          fields[key] = value.toString();
        }
      }

      // Add text fields
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
            'postImg', // ⚡️ use SAME field name as Postman (change if backend expects `postImg`)
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
            'postVideo', // ⚡️ use SAME field name as Postman (change if backend expects `postVideo`)
            postVideo,
            contentType: _getMediaType(postVideo),
          );
          request.files.add(multipartFile);
          debugPrint('------> postVideo: ${postVideo}');
          debugPrint('------> Video added: ${videoFile.path}');
        }
      }


      debugPrint('------> Files: ${request.files.map((f) => f.field).toList()}');

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

  /// OLD / postVideo / postImg
  // static Future<http.Response?> createPostAPI({
  //   required double latitude,
  //   required double longitude,
  //   required String content,
  //   required String locationId,
  //   required String postImg,
  //   String? postVideo,
  //   List<String>? selectedHashtags,
  // }) async {
  //   try {
  //     // Clean up locationId if it starts and ends with quotes
  //     if (locationId.startsWith('"') && locationId.endsWith('"')) {
  //       locationId = locationId.substring(1, locationId.length - 1);
  //     }
  //
  //     // Create a MultipartRequest
  //     var request = http.MultipartRequest(
  //       'POST',
  //       Uri.parse(EndPoints.createPostAPI),
  //     );
  //
  //     // Helper function to add fields if valid
  //     void addFieldIfValid(
  //       Map<String, String> fields,
  //       String key,
  //       dynamic value,
  //     ) {
  //       if (value != null &&
  //           value.toString().trim().isNotEmpty &&
  //           value.toString() != 'null') {
  //         fields[key] = value.toString();
  //       }
  //     }
  //
  //     // Add fields to the request
  //     addFieldIfValid(request.fields, 'user_id', userData?.id);
  //     addFieldIfValid(request.fields, 'content', content);
  //     addFieldIfValid(request.fields, 'privacy_level', '0');
  //     addFieldIfValid(request.fields, 'location_id', locationId);
  //     if (selectedHashtags != null && selectedHashtags.isNotEmpty) {
  //       addFieldIfValid(request.fields, 'hashtags', selectedHashtags.join(','));
  //     }
  //
  //     debugPrint(
  //       '------> createPost api request.fields----->${request.fields}',
  //     );
  //
  //     // Helper function to get media type
  //     MediaType? getMediaType(String filePath) {
  //       final mimeType = lookupMimeType(filePath);
  //       if (mimeType != null) {
  //         final parts = mimeType.split('/');
  //         print("mime ====================== 1");
  //         return MediaType(parts[0], parts[1]);
  //       }
  //       print("mime ====================== 2");
  //
  //       return MediaType('application', 'octet-stream');
  //     }
  //
  //     // Add image file if it exists
  //     if (postImg.isNotEmpty) {
  //       print(
  //         "Media============================Image===========================",
  //       );
  //       File imageFile = File(postImg);
  //       if (await imageFile.exists()) {
  //         final mediaType = getMediaType(postImg);
  //         try {
  //           final multipartFile = await http.MultipartFile.fromPath(
  //             'postImg', // Adjusted to lowercase, confirm with backend
  //             postImg,
  //             contentType: mediaType,
  //           );
  //           request.files.add(multipartFile);
  //           debugPrint(
  //             '------> Image added: ${imageFile.path} with type $mediaType',
  //           );
  //         } catch (e) {
  //           debugPrint('------> Error adding image file: $e');
  //         }
  //       } else {
  //         debugPrint('------> Image file not found at: $postImg');
  //       }
  //     }
  //
  //     // Add video file if it exists
  //     if (postVideo != null && postVideo.isNotEmpty) {
  //       print(
  //         "Media=========================video==============================",
  //       );
  //
  //       File videoFile = File(postVideo);
  //       if (await videoFile.exists()) {
  //         final mediaType = getMediaType(postVideo);
  //         try {
  //           final multipartFile = await http.MultipartFile.fromPath(
  //             'postVideo',
  //             // Adjusted to common video field name, confirm with backend
  //             postVideo,
  //             contentType: mediaType,
  //           );
  //           request.files.add(multipartFile);
  //           debugPrint(
  //             '------> Video added: ${videoFile.path} with type $mediaType',
  //           );
  //         } catch (e) {
  //           debugPrint('------> Error adding video file: $e');
  //         }
  //       } else {
  //         debugPrint('------> Video file not found at: $postVideo');
  //       }
  //     }
  //
  //     debugPrint(
  //       '------> Files being sent: ${request.files.map((f) => f.field).toList()}',
  //     );
  //
  //     // Call the postWithMultipartAPI service
  //     final response = await ApiService.postWithMultipartAPI(
  //       url: EndPoints.createPostAPI,
  //       body: request,
  //     );
  //
  //     if (response != null) {
  //       debugPrint(
  //         '------> createPost api response.body----->${response.body}',
  //       );
  //       debugPrint(
  //         '------> createPost api response.statusCode----->${response.statusCode}',
  //       );
  //       final model = appResponseFromJson2<PostModel>(
  //         response.body,
  //         converter:
  //             (dynamic data) =>
  //                 PostModel.fromJson(data as Map<String, dynamic>),
  //         dataKey: 'posts',
  //       );
  //       return response;
  //     } else {
  //       debugPrint('Failed to create post: No response received');
  //       return null;
  //     }
  //   } catch (e) {
  //     debugPrint('Exception in createPostAPI: $e');
  //     return null;
  //   }
  // }

  // static Future<http.Response?> createPostAPI({
  //   required double latitude,
  //   required double longitude,
  //   required String content,
  //   required String locationId,
  //   required String postImg,
  //   required String postVideo,
  //   List<String>? selectedHashtags, // Added parameter for hashtags
  // }) async {
  //   try {
  //     // Clean up locationId if it starts and ends with quotes
  //     if (locationId.startsWith('"') && locationId.endsWith('"')) {
  //       locationId = locationId.substring(1, locationId.length - 1);
  //     }
  //
  //     // Create a MultipartRequest
  //     var request = http.MultipartRequest(
  //       'POST',
  //       Uri.parse(EndPoints.createPostAPI),
  //     );
  //
  //     // Helper function to add fields if valid
  //     void addFieldIfValid(
  //         Map<String, String> fields,
  //         String key,
  //         dynamic value,
  //         ) {
  //       if (value != null &&
  //           value.toString().trim().isNotEmpty &&
  //           value.toString() != 'null') {
  //         fields[key] = value.toString();
  //       }
  //     }
  //
  //     // Add fields to the request
  //     addFieldIfValid(request.fields, 'user_id', userData?.id);
  //     addFieldIfValid(request.fields, 'latitude', latitude);
  //     addFieldIfValid(request.fields, 'longitude', longitude);
  //     addFieldIfValid(request.fields, 'content', content);
  //     addFieldIfValid(request.fields, 'privacy_level', '0');
  //     addFieldIfValid(request.fields, 'location_id', locationId);
  //     // Convert selectedHashtags list to a comma-separated string and add to fields
  //     if (selectedHashtags != null && selectedHashtags.isNotEmpty) {
  //       addFieldIfValid(request.fields, 'hashtags', selectedHashtags.join(','));
  //     }
  //
  //     debugPrint('------> createPost api request.body----->${request.fields}');
  //
  //     // Helper function to get media type
  //     MediaType? getMediaType(String filePath) {
  //       final mimeType = lookupMimeType(filePath);
  //       if (mimeType != null) {
  //         final parts = mimeType.split('/');
  //         return MediaType(parts[0], parts[1]);
  //       }
  //       return MediaType('application', 'octet-stream');
  //     }
  //
  //     // Add image file if it exists
  //     File imageFile = File(postImg);
  //     if (await imageFile.exists()) {
  //       final mediaType = getMediaType(postImg);
  //       request.files.add(
  //         await http.MultipartFile.fromPath(
  //           'postImg',
  //           postImg,
  //           contentType: mediaType,
  //         ),
  //       );
  //     } else {
  //       debugPrint('Image file not found at: $postImg');
  //     }
  //     // Add video file if it exists
  //     File videoFile = File(postVideo);
  //     if (await videoFile.exists()) {
  //       final mediaType = getMediaType(postVideo);
  //       request.files.add(await http.MultipartFile.fromPath(
  //         'postVideo',
  //         postVideo,
  //         contentType: mediaType,
  //       ));
  //     } else {
  //       debugPrint('Video file not found at: $postVideo');
  //     }
  //
  //     // Call the postWithMultipartAPI service
  //     final response = await ApiService.postWithMultipartAPI(
  //       url: EndPoints.createPostAPI,
  //       body: request,
  //     );
  //
  //     if (response != null) {
  //       debugPrint(
  //         '------> createPost api response.body----->${response.body}',
  //       );
  //       debugPrint(
  //         '------> createPost api response.body----->${jsonDecode(response.body)['post']}',
  //       );
  //       debugPrint(
  //         '------> createPost api response.statusCode----->${response.statusCode}',
  //       );
  //       final model = appResponseFromJson2<PostModel>(
  //         response.body,
  //         converter:
  //             (dynamic data) =>
  //             PostModel.fromJson(data as Map<String, dynamic>),
  //         dataKey: 'posts',
  //       );
  //       return response;
  //     } else {
  //       debugPrint('Failed to create post: No response received');
  //       return null;
  //     }
  //   } catch (e) {
  //     debugPrint('Exception in createPostAPI1: $e');
  //     return null;
  //   }
  // }

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
