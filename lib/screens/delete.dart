

///
// final fcmToken = await NotificationsService.getFCMToken();
///
//Future<void> main() async {
//   WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
//   FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
//   try {
//     await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
//     await PrefService.init();
//     await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//     await NotificationsService.init();
//
//     if (!PrefService.getBool(PrefKeys.isOnBoarding)) {
//       await loadImages();
//     }
//   } catch (e) {
//     debugPrint(e.toString());
//   }
//   runApp(const AppView());
// }
