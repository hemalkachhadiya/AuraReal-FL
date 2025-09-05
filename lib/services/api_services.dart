import 'package:aura_real/apis/app_response.dart';
import 'package:http/http.dart' as http;

import 'package:aura_real/aura_real.dart';

class ApiService {
  static Future<http.Response?> getApi({
    required String url,
    Map<String, String>? header,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      queryParams ??= {};
      String updatedUrl = url;
      queryParams.removeWhere(
        (key, value) => value == null || value.toString().isEmpty,
      );
      queryParams = queryParams.map(
        (key, value) => MapEntry(key, value.toString()),
      );
      if (queryParams.isNotEmpty) {
        updatedUrl = "$url?${Uri(queryParameters: queryParams).query}";
      }
      header = header ?? appHeader();
      debugPrint("Url = $url");
      debugPrint("Header = $header");
      debugPrint("Query = $queryParams");
      final response = await http.get(Uri.parse(updatedUrl), headers: header);
      bool isExpired = await isTokenExpire(response);
      handleError(response);
      if (!isExpired) {
        return response;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  static Future<http.Response?> postApi({
    required String url,
    Map<String, String>? header,
    dynamic body,
  }) async {
    try {
      header = header ?? appHeader();
      header.addAll({"Content-Type": "application/json"});
      debugPrint("Url = $url");
      debugPrint("Header = $header");
      debugPrint("Body = $body");

      if (body is Map) {
        body = jsonEncode(body);
      }
      final response = await http.post(
        Uri.parse(url),
        headers: header,
        body: body,
      );
      bool isExpired = await isTokenExpire(response);
      handleError(response);
      if (!isExpired) {
        return response;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  static Future<http.Response?> putApi({
    required String url,
    Map<String, String>? header,
    dynamic body,
  }) async {
    try {
      header = header ?? appHeader();
      header.addAll({"Content-Type": "application/json"});
      debugPrint("Url = $url");
      debugPrint("Header = $header");
      debugPrint("Body = $body");

      if (body is Map) {
        body = jsonEncode(body);
      }
      final response = await http.put(
        Uri.parse(url),
        headers: header,
        body: body,
      );
      bool isExpired = await isTokenExpire(response);
      handleError(response);
      if (!isExpired) {
        return response;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  static Future<http.Response?> patchApi({
    required String url,
    Map<String, String>? header,
    dynamic body,
  }) async {
    try {
      header = header ?? appHeader();
      header.addAll({"Content-Type": "application/json"});
      debugPrint("Url = $url");
      debugPrint("Header = $header");
      debugPrint("Body = $body");

      if (body is Map) {
        body = jsonEncode(body);
      }
      final response = await http.patch(
        Uri.parse(url),
        headers: header,
        body: body,
      );
      bool isExpired = await isTokenExpire(response);
      handleError(response);
      if (!isExpired) {
        return response;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  static Future<http.Response?> deleteApi({
    required String url,
    Map<String, String>? header,
    dynamic body,
  }) async {
    try {
      header = header ?? appHeader();
      header.addAll({"Content-Type": "application/json"});
      debugPrint("Url = $url");
      debugPrint("Header = $header");
      debugPrint("Body = $body");

      if (body is Map) {
        body = jsonEncode(body);
      }
      final response = await http.delete(
        Uri.parse(url),
        headers: header,
        body: body,
      );
      bool isExpired = await isTokenExpire(response);
      handleError(response);
      if (!isExpired) {
        return response;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  // static Future<http.Response?> multipartApi({
  //   required String url,
  //   required String method,
  //   Map<String, String>? header,
  //   Map<String, String> body = const {},
  //   List<FileDataModel> files = const [],
  //   List<MultipartListModel> multipartList = const [],
  // }) async {
  //   try {
  //     header = header ?? appHeader();
  //     header.addAll({"Content-Type": "application/json"});
  //     debugPrint("Url = $url");
  //     debugPrint("Header = $header");
  //     debugPrint("Body = $body");
  //
  //     var request = http.MultipartRequest(method, Uri.parse(url));
  //     request.fields.addAll(body);
  //     request.headers.addAll(header);
  //
  //     if (multipartList.isNotEmpty) {
  //       for (MultipartListModel element in multipartList) {
  //         for (String value in element.valueList) {
  //           request.files.add(
  //             http.MultipartFile.fromString(element.keyName, value),
  //           );
  //         }
  //       }
  //     }
  //     for (FileDataModel element in files) {
  //       if (element.filePath == null || element.keyName == null) {
  //         continue;
  //       }
  //       request.files.add(
  //         http.MultipartFile(
  //           element.keyName ?? '',
  //           File(element.filePath!).readAsBytes().asStream(),
  //           File(element.filePath!).lengthSync(),
  //           filename: File(element.filePath!).getFileName,
  //         ),
  //       );
  //     }
  //
  //     final http.StreamedResponse streamedResponse = await request.send();
  //     final response = await http.Response.fromStream(
  //       streamedResponse,
  //     ).timeout(const Duration(seconds: 120));
  //     bool isExpired = await isTokenExpire(response);
  //     handleError(response);
  //     if (!isExpired) {
  //       return response;
  //     }
  //   } catch (e) {
  //     debugPrint(e.toString());
  //   }
  //   return null;
  // }

  static Map<String, String> appHeader() {
    /*if (kDebugMode) {
      return {
        'Authorization':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI2ODc4ZTAzMTk3ZDYzZTUzZWY5ZjU5OGEiLCJuYW1lIjoiRW1wbG95ZWUgMDAxIiwidXNlck5hbWUiOiJAZW1wbG95ZWUwMDEiLCJnZW5kZXIiOiJNYWxlIiwiYWdlIjoyOCwiZG9iIjoiMTk5Ny0wNC0xMiIsImltYWdlIjoiIiwiZW1haWwiOiJlbXBsb3llZTAwMUBnbWFpbC5jb20iLCJ1bmlxdWVJZCI6IjIzNzYwNyIsImlzQmxvY2siOmZhbHNlLCJpc0hhbmRpY2FwcGVkIjpmYWxzZSwicm9sZSI6MSwiaWF0IjoxNzUyNzUyMTc3LCJleHAiOjE3NTUzNDQxNzd9.dtWwwUmv5JjQINy2l8UDpYPNdJnnWroKW7GNslfu-es',
      };
    }*/

    if (PrefService.getString(PrefKeys.token).isEmpty) {
      return {};
    } else {
      final str = PrefService.getString(PrefKeys.token);
      return {"Authorization": str};
    }
  }

  static Future<bool> isTokenExpire(http.Response response) async {
    if (response.statusCode == 401 || response.statusCode == 403) {
      logoutUser();
      return true;
    } else {
      return false;
    }
  }
  static void handleError(http.Response response) async {
    try {
      if (response.body.isNotEmpty) {
        final dynamic jsonResponse = jsonDecode(response.body);
        if (jsonResponse is Map<String, dynamic>) {
          final model = AppResponse.fromJson(jsonResponse);
          if (model.success == false) {
            showErrorMsg(model.message ?? "Error");
          }
        } else {
          showErrorMsg("Invalid response format");
        }
      } else {
        showErrorMsg("No response data");
      }
    } catch (e) {
      print("handle Error -- ${e}");
      debugPrint(e.toString());
      showErrorMsg("An error occurred while processing the response");
    }
  }
  // static void handleError(http.Response response) async {
  //   try {
  //     final model = appResponseFromJson(response.body);
  //     if (model.success == false) {
  //       print('Check Hi -----------------');
  //       showErrorMsg(model.message ?? "Error");
  //     }
  //   } catch (e) {
  //     print("handle Error -- ${e}");
  //     debugPrint(e.toString());
  //   }
  // }
}
