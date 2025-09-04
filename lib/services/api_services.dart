// import 'package:http/http.dart' as http;
// import 'package:aura_real/aura_real.dart';
//
//
// class ApiService {
//   static Future<http.Response?> getApi({
//     required String url,
//     Map<String, String>? header,
//     Map<String, dynamic>? queryParams,
//     bool addMD5 = false,
//     bool isToken = false,
//   }) async {
//     try {
//       queryParams ??= {};
//       String updatedUrl = url;
//       queryParams.removeWhere(
//             (key, value) => value == null || value.toString().isEmpty,
//       );
//       queryParams = queryParams.map(
//             (key, value) => MapEntry(key, value.toString()),
//       );
//       if (queryParams.isNotEmpty) {
//         updatedUrl = "$url?${Uri(queryParameters: queryParams).query}";
//       }
//       header = header ?? {};
//
//       debugPrint("Header = $header");
//       debugPrint("queryParams = $queryParams");
//       if (addMD5) {
//         final now = DateTime.now();
//         header["Content-MD5"] = generateTokenHash(
//           dateTime: now.millisecondsSinceEpoch.toString(),
//         );
//         header["timestamp"] = now.millisecondsSinceEpoch.toString();
//       }
//       if (isToken) {
//         header["token"] = userData?.token?.token ?? "";
//       }
//       debugPrint("updatedUrl = ${Uri.parse(updatedUrl)}");
//
//       final response = await http.get(Uri.parse(updatedUrl), headers: header);
//       bool isExpired = await isTokenExpire(response);
//       handleError(response);
//       if (!isExpired) {
//         return response;
//       }
//     } catch (e) {
//       debugPrint(e.toString());
//     }
//     return null;
//   }
//
//   static Future<http.Response?> postApi({
//     required String url,
//     Map<String, String>? header,
//     dynamic body,
//     bool addMD5 = false,
//     bool isFormData = false,
//   }) async {
//     try {
//       header = header ?? {};
//       if (!isFormData) {
//         header.addAll({"Content-Type": "application/x-www-form-urlencoded"});
//       }
//
//       if (addMD5) {
//         final now = DateTime.now();
//         header["Content-MD5"] = generateCustomString(now);
//         header["timestamp"] = now.millisecondsSinceEpoch.toString();
//       }
//
//       final response = await http.post(
//         Uri.parse(url),
//         headers: header,
//         body: body,
//         encoding: isFormData ? null : Encoding.getByName('utf-8'),
//       );
//
//       bool isExpired = await isTokenExpire(response);
//       handleError(response);
//       if (!isExpired) {
//         return response;
//       }
//     } catch (e) {
//       debugPrint(e.toString());
//     }
//     return null;
//   }
//
//   static Future<http.Response?> putApi({
//     required String url,
//     Map<String, String>? header,
//     dynamic body,
//     bool addMD5 = false,
//   }) async {
//     try {
//       header = header ?? {};
//       header.addAll({"Content-Type": "application/x-www-form-urlencoded"});
//
//       if (addMD5) {
//         final now = DateTime.now();
//         header["Content-MD5"] = generateCustomString(now);
//         header["timestamp"] = now.millisecondsSinceEpoch.toString();
//       }
//
//       debugPrint("Url = $url");
//       debugPrint("Header = $header");
//       debugPrint("Body = $body");
//
//       if (body is Map) {
//         body = jsonEncode(body);
//       }
//       final response = await http.put(
//         Uri.parse(url),
//         headers: header,
//         body: body,
//         encoding: Encoding.getByName('utf-8'),
//       );
//       bool isExpired = await isTokenExpire(response);
//       handleError(response);
//       if (!isExpired) {
//         return response;
//       }
//     } catch (e) {
//       debugPrint(e.toString());
//     }
//     return null;
//   }
//
//   static Future<http.Response?> deleteApi({
//     required String url,
//     Map<String, String>? header,
//     dynamic body,
//     bool addMD5 = false,
//   }) async {
//     try {
//       header = header ?? {};
//       header.addAll({"Content-Type": "application/x-www-form-urlencoded"});
//
//       if (addMD5) {
//         final now = DateTime.now();
//         header["Content-MD5"] = generateCustomString(now);
//         header["timestamp"] = now.millisecondsSinceEpoch.toString();
//       }
//
//       debugPrint("Url = $url");
//       debugPrint("Header = $header");
//       debugPrint("Body = $body");
//
//       final response = await http.delete(
//         Uri.parse(url),
//         headers: header,
//         body: body,
//         encoding: Encoding.getByName('utf-8'),
//       );
//       bool isExpired = await isTokenExpire(response);
//       handleError(response);
//       if (!isExpired) {
//         return response;
//       }
//     } catch (e) {
//       debugPrint(e.toString());
//     }
//     return null;
//   }
//
//   static bool handleError(http.Response response) {
//     try {
//       final model = appResponseFromJson(response.body);
//       if (model == null) {
//         return false;
//       }
//       if (model.code == 0) {
//         return true;
//       } else if (model.code == -1) {
//         showErrorMsg(model.msg ?? "Error");
//       }
//     } catch (e) {
//       debugPrint(e.toString());
//     }
//     return false;
//   }
//
//   static Future<bool> isTokenExpire(http.Response response) async {
//     final model = appResponseFromJson(response.body);
//     bool isModelExpire = false;
//     if (model != null && model.code == -100) {
//       isModelExpire = true;
//     }
//     if (isModelExpire || response.statusCode >= 500) {
//       if (navigatorKey.currentContext != null) {
//         showErrorMsg("Session expired. Please login again.");
//         navigatorKey.currentState?.pushNamedAndRemoveUntil(
//           SignInScreen.routeName,
//               (value) => true,
//         );
//       }
//       return true;
//     } else {
//       return false;
//     }
//   }
// }
