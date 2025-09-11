class EndPoints {
  /// LOCAL URL
  static const domain = "http://192.168.1.23:4000/";

  ///Live URL
  // static const domain = "https://aurarealapi.smarttechnica.com/";

  /// Base URL
  static const baseUrl = "${domain}api/v1/";

  /// ------------------------------------ Socket -------------------------------
  static const WebSocketurl =
      "http://localhost:4000/socket.io/?EIO=4&transport=websocket";

  /// ------------------------------------ Auth -------------------------------
  static const register = "${baseUrl}user/register";
  static const login = "${baseUrl}user/login";
  static const verifyOTP = "${baseUrl}verify-otp";
  static const logout = "${baseUrl}userlogout";

  /// ------------------------------------ Forgot Password -------------------------------

  static const requestPasswordReset = "${baseUrl}requestPasswordReset";
  static const verifyPasswordResetOTP = "${baseUrl}verifyPasswordResetOTP";
  static const resetPassword = "${baseUrl}resetPassword";
  static const changePassword = "${baseUrl}changePassword";

  /// ------------------------------------ Google Login -------------------------------
  static const googleLogin = "${baseUrl}google-login";

  /// ------------------------------------ User Profile -------------------------------
  static const getUserProfile = "${baseUrl}getuserprofile?userId=";
  static const updateUserProfile = "${baseUrl}updateUser";

  /// ------------------------------------ Location -------------------------------

  static const location = "${baseUrl}user/location";
  static const getUserLocations = "${baseUrl}getUserLocations?user_id=";

  /// ------------------------------------ Dashboard -------------------------------
  static const createPostAPI = "${baseUrl}createpost";
  static const getAllPostAPI = "${baseUrl}getallposts";
  static const getPostByUSer = "${baseUrl}getpostsbyuser?userId";
  static const getUserProfileWithPosts =
      "${baseUrl}getUserProfileWithPosts?userId=";

  static const ratepost = "${baseUrl}ratepost";

  /// ------------------------------------ Follow and UnFollow User Profile -------------------------------

  static const follow = "${baseUrl}follow";
  static const unfollow = "${baseUrl}unfollow";
}
