import 'package:aura_real/aura_real.dart';
import 'package:aura_real/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseOptions firebaseOptions;

  if (Platform.isIOS) {
    firebaseOptions = const FirebaseOptions(
      apiKey: 'AIzaSyApNVyfagHrb5MUNhOLwKIV5Swh4JSfy8g',
      appId: '1:382221381003:ios:61d0c8c35658a972a1938e',
      messagingSenderId: '382221381003',
      projectId: 'aurareal-a2ca3',
    );
    debugPrint("Firebase connect IOS");
  } else {
    firebaseOptions = const FirebaseOptions(
      apiKey: 'AIzaSyBm_TOk07V5gnxavJqzZfFXDgZBPwW9gco',
      appId: '1:382221381003:android:b7de2ec5f3f8364aa1938e',
      messagingSenderId: '',
      projectId: 'aurareal-a2ca3',
      // projectId: 'com.smarttechnica.aura.real.social.media',
    );

    ///Notification code
    initializeNotifications();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      String payload = jsonEncode(message.data);

      debugPrint("${payload}");

      if (message.notification != null) {
        // if (AppState.screenStatus == "ScreenShow" &&
        //     AppState.currentChatUserId == message.data['chatRoomId']) {
        //   debugPrint("🔕 Don't show notification - already in chat with sender");
        // } else {
        String payload = jsonEncode(message.data);
        debugPrint('🔥 Showing notification with payload: $payload');
        RemoteNotification notification = message.notification!;

        ///===============Notification Code
        showNotification(
          title: notification.title ?? '',
          body: notification.body ?? '',
          payload: payload,
        );
      }
    });
    debugPrint("Firebase connect Andoid");
    debugPrint("test");
  }
  await Firebase.initializeApp(options: firebaseOptions);
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
    );
    await PrefService.init();
  } catch (e) {
    debugPrint(e.toString());
  }

  runApp(AppView());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  String payload = jsonEncode(message.data);

  if (message.notification != null) {
    String payload = jsonEncode(message.data);
    debugPrint('🔥 Showing notification with payload: $payload');
    RemoteNotification notification = message.notification!;
    // showNotification(
    //   title: notification.title ?? '',
    //   body: notification.body ?? '',
    //   payload: payload,
    // );
  }
  debugPrint('👉 Full message: ${message.toMap()}'); // Logs everything
  debugPrint('Handling background message: ${message.data}');
}