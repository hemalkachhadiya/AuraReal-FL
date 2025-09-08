import 'package:aura_real/apis/app_response.dart';
import 'package:aura_real/aura_real.dart';
import 'package:aura_real/screens/auth/sign_in/model/login_response_model.dart';
import 'package:aura_real/services/api_services.dart';
import 'package:aura_real/utils/end_points.dart';

class AuthApis {
  ///Register API
  static Future<bool> registerAPI({
    required String phoneNumber,
    required String email,
    required String fullName,
    required String password,
  }) async {
    try {
      final response = await ApiService.postApi(
        url: EndPoints.register,
        body: {
          "email": email,
          "fullName": fullName,
          "password": password,
          "phoneNumber": phoneNumber,
        },
      );
      if (response == null) {
        showCatchToast('No response from server', null);
        return false;
      }

      print(
        "BODY: ${jsonEncode({"email": email, "fullName": fullName, "password": password, "phoneNumber": phoneNumber})}",
      );
      print("res: ${response.body}");
      final model = appResponseFromJson(response.body);
      print("model.data");

      print(model.data);
      print(model.success);
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

  ///OTP API
  static Future<LoginRes?> verifyOTPAPI({
    required String otp,
    required String email,
  }) async {
    try {
      print("OTP CALL ------------------ ${int.parse(otp.toString())}");
      final response = await ApiService.postApi(
        url: EndPoints.verifyOTP,
        body: {"email": email, "otp": int.parse(otp.toString())},
      );
      if (response == null) {
        showCatchToast('No response from server', null);
        return null;
      }

      print("BODY: ${jsonEncode({"email": email, "otp": otp})}");
      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseBody['data'] != null && responseBody != null) {
          await PrefService.set(
            PrefKeys.userData,
            jsonEncode(responseBody['data']),
          );

          await PrefService.set(
            PrefKeys.token,
            jsonEncode(responseBody['data']['token']),
          );

          showSuccessToast(responseBody['message'] ?? 'Login successful');
          return LoginRes.fromJson(responseBody['data']);
        }
      }
    } catch (exception, stack) {
      showCatchToast(exception, stack);
      return null;
    }
  }

  ///Login API
  static Future<LoginRes?> loginAPI({
    required String password,
    required String email,
  }) async {
    try {
      final response = await ApiService.postApi(
        url: EndPoints.login,
        body: {"email": email, "password": password},
      );
      if (response == null) {
        showCatchToast('No response from server', null);
        return null;
      }
      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Res Body Data ${responseBody['data']}");
        if (responseBody['data'] != null && responseBody != null) {
          await PrefService.set(
            PrefKeys.userData,
            jsonEncode(responseBody['data']),
          );

          await PrefService.set(
            PrefKeys.token,
            jsonEncode(responseBody['data']['token']),
          );

          showSuccessToast(responseBody['message'] ?? 'Login successful');
          return LoginRes.fromJson(responseBody['data']);
        }
      }
    } catch (exception, stack) {
      showCatchToast(exception, stack);
      return null;
    }
  }

  ///Logout
  static Future<bool> logoutAPI({required String userId}) async {
    try {
      final response = await ApiService.postApi(
        url: EndPoints.logout,
        body: {"userId": userId},
      );
      if (response == null) {
        showCatchToast('No response from server', null);
        return false;
      }
      final model = appResponseFromJson(response.body);
      print("model.data");

      print(model.data);
      print(model.success);
      if (model.success == true) {
        showSuccessToast(model.message ?? "Message Form LOGOUT API");
        return true;
      } else {
        return false;
      }
    } catch (exception, stack) {
      showCatchToast(exception, stack);
    }
    return false;
  }

  ///Get User Profile
  static Future<Profile?> getUserProfile({required String userId}) async {
    try {
      final response = await ApiService.getApi(
        url: "${EndPoints.getUserProfile}$userId",
      );

      if (response == null) {
        showCatchToast('No response from server', null);
        return null;
      }
      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Res Body Data ${responseBody['profile']}");
        if (responseBody['profile'] != null && responseBody != null) {
          showSuccessToast(responseBody['message'] ?? 'Login successful');
          return Profile.fromJson(responseBody['profile']);
        }
      }
    } catch (exception, stack) {
      showCatchToast(exception, stack);
      return null;
    }
  }
}
