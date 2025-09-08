class EndPoints {
  /// LOCAL URL
  static const domain = "http://192.168.1.30:4000/";

  /// Test URL
  static const baseUrl = "${domain}api/v1/";

  /// ------------------------------------ Auth -------------------------------
  static const register = "${baseUrl}user/register";
  static const login = "${baseUrl}user/login";
  static const verifyOTP = "${baseUrl}verify-otp";
  static const logout = "${baseUrl}userlogout";

  /// ------------------------------------ Google Login -------------------------------
  static const googleLogin = "${baseUrl}google-login";

  /// ------------------------------------ User Profile -------------------------------
  static const getUserProfile = "${baseUrl}getuserprofile?userId=";

 /// ------------------------------------ Dashboard -------------------------------
  static const getAllPostAPI = "${baseUrl}getallposts";
  static const getPostByUSer = "${baseUrl}getpostsbyuser?userId=68b6cf303add7fc6d731b7c7";
}
