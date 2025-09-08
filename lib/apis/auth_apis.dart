import 'package:aura_real/apis/app_response.dart';
import 'package:aura_real/apis/model/location_model.dart';
import 'package:aura_real/aura_real.dart';
import 'package:aura_real/screens/auth/sign_in/model/google_login_response_model.dart';
import 'package:aura_real/screens/auth/sign_in/model/login_response_model.dart';
import 'package:aura_real/services/api_services.dart';
import 'package:aura_real/utils/end_points.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  ///Google Login API
  static Future<GoogleLoginRes?> googleAPI({
    required String googleId,
    required String email,
  }) async {
    try {
      final response = await ApiService.postApi(
        url: EndPoints.googleLogin,
        body: {"email": email, "googleId": googleId},
      );
      if (response == null) {
        showCatchToast('No response from server', null);
        return null;
      }
      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Res Body Data ${responseBody['user']}");
        if (responseBody['user'] != null && responseBody != null) {
          await PrefService.set(
            PrefKeys.userData,
            jsonEncode(responseBody['user']),
          );

          await PrefService.set(
            PrefKeys.token,
            jsonEncode(responseBody['user']['token']),
          );

          showSuccessToast(
            responseBody['message'] ?? 'Google Login successful',
          );
          return GoogleLoginRes.fromJson(responseBody['user']);
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
      GoogleSignIn googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }

      await FirebaseAuth.instance.signOut();
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

  // static Future<LocationModel?> getLocationAPI({required String userId}) async {
  //   try {
  //     final response = await ApiService.getApi(
  //       url: "${EndPoints.location}$userId",
  //     );
  //
  //     if (response == null) {
  //       showCatchToast('No response from server', null);
  //       return null;
  //     }
  //     final responseBody = jsonDecode(response.body);
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       print("Res Body Data ${responseBody['location']}");
  //       if (responseBody['location'] != null && responseBody != null) {
  //         showSuccessToast(responseBody['location'] ?? 'Login successful');
  //         return LocationModel.fromJson(responseBody['location']);
  //       }
  //     }
  //   } catch (exception, stack) {
  //     showCatchToast(exception, stack);
  //     return null;
  //   }
  // }
}
