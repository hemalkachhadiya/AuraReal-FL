class EndPoints {
  /// LOCAL URL
  // static const domain = "http://192.168.1.30:4000/";

  ///Live URL
  static const domain = "https://aurarealapi.smarttechnica.com/";

  /// Test URL
  static const baseUrl = "${domain}api/v1/";

  /// ------------------------------------ Auth -------------------------------
  static const register = "${baseUrl}user/register";
  static const login = "${baseUrl}user/login";
  static const verifyOTP = "${baseUrl}verify-otp";
  static const logout = "${baseUrl}userlogout";

  /// ------------------------------------ Forgot Password -------------------------------

  static const requestPasswordReset = "${baseUrl}requestPasswordReset";
  static const verifyPasswordResetOTP = "${baseUrl}verifyPasswordResetOTP";
  static const resetPassword = "${baseUrl}resetPassword";

  /// ------------------------------------ Google Login -------------------------------
  static const googleLogin = "${baseUrl}google-login";

  /// ------------------------------------ User Profile -------------------------------
  static const getUserProfile = "${baseUrl}getuserprofile?userId=";
  // static const location = "${baseUrl}user/location";

 /// ------------------------------------ Dashboard -------------------------------
  static const getAllPostAPI = "${baseUrl}getallposts";
  static const getPostByUSer = "${baseUrl}getpostsbyuser?userId=68b6cf303add7fc6d731b7c7";
}
