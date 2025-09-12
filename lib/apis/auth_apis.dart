import 'package:aura_real/apis/app_response.dart';
import 'package:aura_real/apis/model/location_model.dart';
import 'package:aura_real/aura_real.dart';
import 'package:aura_real/screens/auth/sign_in/model/google_login_response_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginResult {
  final LoginRes? loginRes;
  final bool isInCorrectPassword;

  LoginResult({this.loginRes, this.isInCorrectPassword = false});
}

class AuthApis {
  ///Register API
  static Future<bool> registerAPI({
    required String phoneNumber,
    required String email,
    required String fullName,
    required String password,
    required String otpType,
  }) async {
    try {
      final response = await ApiService.postApi(
        url: EndPoints.register,
        body: {
          "email": email,
          "fullName": fullName,
          "password": password,
          "phoneNumber": phoneNumber,
          "is_otp_type": otpType,
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
    required String phone,
    required String otpType,
  }) async {
    try {
      // Determine the body based on otpType
      Map<String, dynamic> body = {"otp": otp.toString()};

      if (otpType == "0" || otpType.toLowerCase() == "email") {
        PrefService.set(PrefKeys.email, email);
        body["email"] = email; // For email OTP
      } else if (otpType == "1" || otpType.toLowerCase() == "sms") {
        PrefService.set(PrefKeys.phoneNumber, phone);
        if (phone.isEmpty) {
          showCatchToast('Phone number not available for SMS OTP', null);
          return null;
        }
        body["phoneNumber"] = phone;
      } else {
        showCatchToast('Invalid OTP type', null);
        return null;
      }

      final response = await ApiService.postApi(
        url: EndPoints.verifyOTP,
        body: body,
      );
      if (response == null) {
        showCatchToast('No response from server', null);
        return null;
      }

      if (kDebugMode) {
        print("BODY: ${jsonEncode(body)}");
      }
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
  static Future<LoginResult> loginAPI({
    required String password,
    required String email,
  }) async {
    try {
      final response = await ApiService.postApi(
        url: EndPoints.login,
        body: {"email": email, "password": password},
        is402Response: false, // Initial value, will be overridden by response
      );

      if (response == null) {
        showCatchToast('No response from server', null);
        return LoginResult(isInCorrectPassword: false); // Return default result
      }

      final responseBody = jsonDecode(response.body);
      print("isInCorrectPassword====== false"); // Initial state

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
          return LoginResult(loginRes: LoginRes.fromJson(responseBody['data']));
        }
      } else if (response.statusCode == 402) {
        return LoginResult(isInCorrectPassword: true);
      } else {
        showCatchToast(responseBody['message'] ?? 'Login failed', null);
        return LoginResult(isInCorrectPassword: false);
      }

      // Default return to satisfy non-nullable type (should not reach here)
      return LoginResult(isInCorrectPassword: false);
    } catch (exception, stack) {
      showCatchToast(exception.toString(), stack);
      return LoginResult(isInCorrectPassword: false); // Return on exception
    }
  }

  // static Future<LoginRes?> loginAPI({
  //   required String password,
  //   required String email,
  //   required bool isInCorrectPassword  , // Default to false
  // }) async {
  //   try {
  //     final response = await ApiService.postApi(
  //       url: EndPoints.login,
  //       body: {"email": email, "password": password},
  //       is402Response: isInCorrectPassword,
  //     );
  //
  //     if (response == null) {
  //       showCatchToast('No response from server', null);
  //       return null;
  //     }
  //
  //     final responseBody = jsonDecode(response.body);
  //     print("isInCorrectPassword====== $isInCorrectPassword");
  //
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       if (responseBody['data'] != null && responseBody != null) {
  //         await PrefService.set(
  //           PrefKeys.userData,
  //           jsonEncode(responseBody['data']),
  //         );
  //
  //         await PrefService.set(
  //           PrefKeys.token,
  //           jsonEncode(responseBody['data']['token']),
  //         );
  //
  //         showSuccessToast(responseBody['message'] ?? 'Login successful');
  //         return LoginRes.fromJson(responseBody['data']);
  //       }
  //     } else if (response.statusCode == 402) {
  //       showCatchToast(responseBody['message'], null);
  //       isInCorrectPassword = true; // Set flag for incorrect credentials
  //       print("is In corrct Password========= ${isInCorrectPassword}");
  //       return null;
  //     } else {
  //       showCatchToast(responseBody['message'] ?? 'Login failed', null);
  //       return null;
  //     }
  //   } catch (exception, stack) {
  //     showCatchToast(exception.toString(), stack);
  //     return null;
  //   }
  // }

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

  static Future<Profile?> userUpdateProfile({
    required String userId,
    required String fullName,
    required String email,
    required String phoneNumber,
  }) async {
    try {
      final response = await ApiService.putApi(
        url: EndPoints.updateUserProfile,
        body: {
          "userId": userId,
          "fullName": fullName,
          "email": email,
          "phoneNumber": phoneNumber,
        },
      );

      if (response == null) {
        showCatchToast('No response from server', null);
        return null;
      }
      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Res Body Data ${responseBody['profile']}");
        if (responseBody['profile'] != null && responseBody != null) {
          // showSuccessToast(responseBody['message'] ?? 'Login successful');
          await PrefService.set(
            PrefKeys.userData,
            jsonEncode(responseBody['data']),
          );
          return Profile.fromJson(responseBody['profile']);
        }
      }
    } catch (exception, stack) {
      showCatchToast(exception, stack);
      return null;
    }
  }

  ///Request Password API
  static Future<bool?> reqPasswordResetAPI({required String email}) async {
    try {
      final response = await ApiService.postApi(
        url: EndPoints.requestPasswordReset,
        body: {"identifier": email},
      );
      if (response == null) {
        showCatchToast('No response from server', null);
        return false;
      }
      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseBody['message'] != null && responseBody != null) {
          showSuccessToast(responseBody['message'] ?? 'Login successful');
          return true;
        }
      }
    } catch (exception, stack) {
      showCatchToast(exception, stack);
      return false;
    }
  }

  ///Request Password API
  static Future<bool?> otpVerifyForgotPasswordAPI({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await ApiService.postApi(
        url: EndPoints.verifyPasswordResetOTP,
        body: {"identifier": email, "otp": otp},
      );
      if (response == null) {
        showCatchToast('No response from server', null);
        return false;
      }
      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseBody['message'] != null && responseBody != null) {
          showSuccessToast(responseBody['message'] ?? 'Login successful');
          return true;
        }
      }
    } catch (exception, stack) {
      showCatchToast(exception, stack);
      return false;
    }
  }

  ///Request Password API
  static Future<bool?> resetPasswordAPI({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await ApiService.postApi(
        url: EndPoints.resetPassword,
        body: {"identifier": email, "otp": otp, "newPassword": newPassword},
      );
      if (response == null) {
        showCatchToast('No response from server', null);
        return false;
      }
      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseBody['message'] != null && responseBody != null) {
          showSuccessToast(responseBody['message'] ?? 'Login successful');
          return true;
        }
      }
    } catch (exception, stack) {
      showCatchToast(exception, stack);
      return false;
    }
  }

  //change password
  static Future<bool> changePasswordAPI({
    required String userId,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final response = await ApiService.postApi(
        url: EndPoints.changePassword,
        body: {
          "userId": userId,
          "oldPassword": oldPassword,
          "newPassword": newPassword,
        },
      );

      if (response == null) {
        showCatchToast("No response from server", null);
        return false;
      }

      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success
        showSuccessToast(
          responseBody['message'] ?? 'Password changed successfully',
        );
        return true;
      } else {
        // Failure
        showCatchToast(responseBody['message'] ?? 'Something went wrong', null);
        return false;
      }
    } catch (exception, stack) {
      showCatchToast(exception, stack);
      return false;
    }
  }

  ///FollowUserProfile API
  static Future<bool> followUserProfile({
    required String followUserId,
    required String userId,
  }) async {
    try {
      final response = await ApiService.postApi(
        url: EndPoints.follow,
        body: {"followUserId": followUserId, "userId": userId},
      );

      if (response == null) {
        showCatchToast("No response from server", null);
        return false;
      }

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        showSuccessToast(responseBody['message'] ?? 'Follow successful');
        return true;
      } else {
        showCatchToast(responseBody['message'] ?? 'Failed', null);
        return false;
      }
    } catch (e, s) {
      showCatchToast(e, s);
      return false;
    }
  }

  //   ///UnFollowUserProfile API
  // static Future unfollowUserProfile({
  //   required String followUserId,
  //   required String userId,
  // }) async {
  //   try {
  //     final response = await ApiService.postApi(
  //       url: EndPoints.unfollow,
  //       body: {"userId": userId, "followUserId": followUserId},
  //     );
  //     if (response == null) {
  //       showCatchToast('No response from server', null);
  //       return false;
  //     }
  //     final responseBody = jsonDecode(response.body);
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       showSuccessToast(responseBody['message'] ?? 'Follow successful');
  //       return true;
  //     }
  //   } catch (exception, stack) {
  //     showCatchToast(exception, stack);
  //     return false;
  //   }
  // }
  static Future<bool> unfollowUserProfile({
    required String followUserId,
    required String userId,
  }) async {
    try {
      final response = await ApiService.postApi(
        url: EndPoints.unfollow,
        body: {"unfollowUserId": followUserId, "userId": userId},
      );

      if (response == null) {
        showCatchToast("No response from server", null);
        return false;
      }

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        showSuccessToast(responseBody['message'] ?? 'Follow successful');
        return true;
      } else {
        showCatchToast(responseBody['message'] ?? 'Failed', null);
        return false;
      }
    } catch (e, s) {
      showCatchToast(e, s);
      return false;
    }
  }

  ///Location API
  static Future<LocationModel?> postLocationAPI({
    required double latitude,
    required double longitude,
    required String address,
    required String city,
    required String state,
    required String country,
  }) async {
    try {
      final response = await ApiService.postApi(
        url: EndPoints.location,
        body: jsonEncode({
          "user_id": userData?.id.toString(),
          "latitude": latitude,
          "longitude": longitude,
          "address": address,
          "city": city,
          "state": state,
          "country": country,
          "is_current": true,
        }),
        header: {'Content-Type': 'application/json'},
      );

      print(
        "Location BODY ====== ${jsonEncode({"latitude": latitude, "longitude": longitude, "address": address, "city": city, "state": state, "country": country, "is_current": true})}",
      );
      if (response == null) {
        showCatchToast('No response from server', null);
        return null;
      }

      final responseBody = jsonDecode(response.body);
      print("Location API ----- ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Res Body Data ${responseBody['location']}");
        print("Res Body Data ${responseBody['location']['_id']}");
        if (responseBody['location'] != null && responseBody != null) {
          // Pass a specific string field (e.g., address) or a custom message to showSuccessToast
          print(
            "Location Id ---> ${jsonEncode(responseBody['location']['_id'])}",
          );
          await PrefService.set(
            PrefKeys.locationId,
            jsonEncode(responseBody['location']['_id']),
          );
          return LocationModel.fromJson(responseBody['location']);
        }
      }
      return null;
    } catch (exception, stack) {
      showCatchToast(exception, stack);
      return null;
    }
  }
}
