// import 'package:aura_real/aura_real.dart';
//
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
//
//
// class NotificationsService {
//   static FlutterLocalNotificationsPlugin? _flutterLocalNotificationsPlugin;
//   static AndroidNotificationChannel? _channel;
//
//   static Future<void> _firebaseMessagingBackgroundHandler(
//       RemoteMessage message) async {}
//
//   static Future<void> init() async {
//     await Permission.notification.request();
//     FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//
//     _channel = const AndroidNotificationChannel(
//       'channel',
//       'High Importance Notifications',
//       importance: Importance.high,
//       enableLights: true,
//       enableVibration: false,
//     );
//
//     FirebaseMessaging messaging = FirebaseMessaging.instance;
//
//     await messaging.requestPermission(
//       alert: true,
//       announcement: false,
//       badge: true,
//       carPlay: false,
//       criticalAlert: false,
//       provisional: false,
//       sound: true,
//     );
//
//     _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//     const AndroidInitializationSettings initializationSettingsAndroid =
//     AndroidInitializationSettings('@mipmap/ic_launcher');
//     const DarwinInitializationSettings initializationSettingsIOS =
//     DarwinInitializationSettings();
//     const InitializationSettings initializationSettings =
//     InitializationSettings(
//         android: initializationSettingsAndroid,
//         iOS: initializationSettingsIOS);
//     _flutterLocalNotificationsPlugin!.initialize(
//       initializationSettings,
//       onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
//       onDidReceiveNotificationResponse: (NotificationResponse? data) async {
//         if (data?.payload != null) {
//           onNotificationTap(
//               (getMapFromStr(data?.payload) ?? {}).cast<String, dynamic>());
//         }
//       },
//     );
//
//     await _flutterLocalNotificationsPlugin
//         ?.resolvePlatformSpecificImplementation<
//         AndroidFlutterLocalNotificationsPlugin>()
//         ?.createNotificationChannel(_channel!);
//
//     await _flutterLocalNotificationsPlugin
//         ?.resolvePlatformSpecificImplementation<
//         IOSFlutterLocalNotificationsPlugin>()
//         ?.requestPermissions(alert: true, badge: true, sound: true);
//
//     await FirebaseMessaging.instance
//         .setForegroundNotificationPresentationOptions(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
//       RemoteNotification? notification = message.notification;
//       if (notification != null && Platform.isAndroid) {
//         _flutterLocalNotificationsPlugin?.show(
//           notification.hashCode,
//           notification.title,
//           notification.body,
//           NotificationDetails(
//             android: AndroidNotificationDetails(
//               message.notification?.android?.channelId ?? 'channel',
//               _channel?.name ?? "test",
//               icon: '@mipmap/ic_launcher',
//             ),
//             iOS: DarwinNotificationDetails(
//               subtitle: _channel?.description ?? "",
//               presentSound: true,
//               presentAlert: true,
//               //   attachments: attach,
//             ),
//           ),
//           payload: jsonEncode(message.data),
//         );
//       }
//     });
//
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
//       debugPrint("onMessageOpenedApp Called ");
//       debugPrint(message.toString());
//       onNotificationTap(message.data);
//     });
//
//     FirebaseMessaging.instance
//         .getInitialMessage()
//         .then((RemoteMessage? message) async {
//       debugPrint(message.toString());
//       await Future.delayed(const Duration(milliseconds: 4500));
//       if (message != null) {
//         await Firebase.initializeApp();
//         onNotificationTap(message.data);
//       }
//     });
//   }
//
//   static Future<String?> getFCMToken() async {
//     try {
//       FirebaseMessaging instance = FirebaseMessaging.instance;
//       String? token = await instance.getToken();
//       debugPrint("FCM Token = $token");
//       return token;
//     } catch (e) {
//       debugPrint(e.toString());
//     }
//     return null;
//   }
//
//   static Future<void> onNotificationTap(Map<String, dynamic> data) async {
//     debugPrint(data.toString());
//   }
// }
//
// @pragma('vm:entry-point')
// void notificationTapBackground(NotificationResponse data) {
//   if (data.payload != null) {
//     NotificationsService.onNotificationTap(
//         (getMapFromStr(data.payload) ?? {}).cast<String, dynamic>());
//   }
// }
