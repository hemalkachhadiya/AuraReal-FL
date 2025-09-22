import 'package:aura_real/aura_real.dart';

void showErrorMsg(String msg, {BuildContext? context}) {
  showCustomToast(msg, error: true);
  debugPrint("Error: $msg");
}


Future<void> showCatchToast(
  dynamic exception,
  StackTrace? stack, {
  String? msg,
}) async {
  bool isInternetOn = false;
  try {
    final result = await InternetAddress.lookup('example.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      isInternetOn = true;
      debugPrint('connected');
    }
  } on SocketException catch (_) {
    debugPrint('not connected');
  }
  String content = "";
  if (!isInternetOn) {
    content = "Check you Internet connection !";
  } else if (kDebugMode) {
    content = msg ?? exception.toString();
  } else {
    content = "Something went wrong !";
  }
  showCustomToast(content, error: true);
  debugPrint("Error123: $content");
}

void showSuccessToast(String msg) {
  showCustomToast(msg);
}

bool isEnglishSelected() {
  return (PrefService.getString(PrefKeys.localLanguage) == "English") ||
      (PrefService.getString(PrefKeys.localLanguage).isEmpty);
}
