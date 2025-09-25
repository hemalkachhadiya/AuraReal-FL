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

//     await _flutterLocalNotificationsPlugin
//         ?.resolvePlatformSpecificImplementation<
//         AndroidFlutterLocalNotificationsPlugin>()
//         ?.createNotificationChannel(_channel!);

//     await _flutterLocalNotificationsPlugin
//         ?.resolvePlatformSpecificImplementation<
//         IOSFlutterLocalNotificationsPlugin>()
//         ?.requestPermissions(alert: true, badge: true, sound: true);

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

//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
//       debugPrint("onMessageOpenedApp Called ");
//       debugPrint(message.toString());
//       onNotificationTap(message.data);
//     });

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

//   static Future<void> onNotificationTap(Map<String, dynamic> data) async {
//     debugPrint(data.toString());
//   }
// }

// @pragma('vm:entry-point')
// void notificationTapBackground(NotificationResponse data) {
//   if (data.payload != null) {
//     NotificationsService.onNotificationTap(
//         (getMapFromStr(data.payload) ?? {}).cast<String, dynamic>());
//   }
// }
// /Smart code ==============================
// import 'package:aura_real/aura_real.dart';

import 'package:aura_real/aura_real.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      );

  final LinuxInitializationSettings initializationSettingsLinux =
      LinuxInitializationSettings(defaultActionName: 'Open notification');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
    macOS: initializationSettingsDarwin,
    linux: initializationSettingsLinux,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      final payload = response.payload;
      if (payload != null) {
        handleNotificationTap(payload);
      }
    },
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );

  final NotificationAppLaunchDetails? launchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  if (launchDetails?.didNotificationLaunchApp ?? false) {
    final payload = launchDetails!.notificationResponse?.payload;
    if (payload != null) {
      Future.delayed(const Duration(seconds: 1), () {
        handleNotificationTap(payload);
      });
    }
  }

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin
      >()
      ?.requestPermissions(alert: true, badge: true, sound: true);
}

// Called when notification is tapped
void handleNotificationTap(String payload) {
  debugPrint("payload === > $payload");

  // try {
  //   final Map<String, dynamic> data = jsonDecode(payload);

  //   if (data['type'] == "2") {
  //     debugPrint(
  //       "Navigating to chat screen for chatRoomId: ${data['chatRoomId']}",
  //     );

  //     navigatorKey.currentState?.push(
  //       MaterialPageRoute(
  //         builder:
  //             (_) => ChatScreen(
  //               chatRoomId: '${data['_id']}',
  //               chatRoomIdWebSocket: '${data['chatRoomId']}',
  //               userrole: true,
  //             ),
  //       ),
  //     );
  //   } else if (data['type'] == "1") {
  //     debugPrint(
  //       "Navigating to chat screen for chatRoomId: ${data['chatRoomId']}",
  //     );
  //     navigatorKey.currentState?.push(
  //       MaterialPageRoute(builder: (_) => YourPostsScreen()),
  //     );
  //   } else if (data['type'] == "6") {
  //     debugPrint(
  //       "Navigating to chat screen for chatRoomId: ${data['chatRoomId']}",
  //     );
  //     navigatorKey.currentState?.push(
  //       MaterialPageRoute(
  //         builder:
  //             (_) => ItemDetailScreen(
  //               passData: 0,
  //               bookNow: int.parse(data['rentalPrices']),
  //               buyNow: int.parse(data['sellprices']),
  //               isLike: bool.parse(data['wishlist']),
  //               postId: data['postId'],
  //               postIndex: 0,
  //               screenName: "Notification",
  //             ),
  //       ),
  //     );
  //   } else if (data['type'] == "7") {
  //     debugPrint(
  //       "Navigating to chat screen for chatRoomId: ${data['chatRoomId']}",
  //     );
  //     navigatorKey.currentState?.push(
  //       MaterialPageRoute(builder: (_) => BookingsScreen()),
  //     );
  //   } else if (data['type'] == "8") {
  //     debugPrint(
  //       "Navigating to chat screen for chatRoomId: ${data['chatRoomId']}",
  //     );
  //     navigatorKey.currentState?.push(
  //       MaterialPageRoute(builder: (_) => MyRentalsScreen()),
  //     );
  //   } else if (data['type'] == "5") {
  //     debugPrint(
  //       "Navigating to chat screen for chatRoomId: ${data['chatRoomId']}",
  //     );

  //     navigatorKey.currentState?.push(
  //       MaterialPageRoute(builder: (_) => UserCoinScreen()),
  //     );
  //   } else if (data['type'] == "PURCHASE") {
  //     navigatorKey.currentState?.push(
  //       MaterialPageRoute(builder: (_) => BookingsScreen()),
  //     );
  //   } else if (data['type'] == "purchase_approved") {
  //     debugPrint(
  //       "Navigating to chat screen for chatRoomId: ${data['chatRoomId']}",
  //     );
  //     navigatorKey.currentState?.push(
  //       MaterialPageRoute(builder: (_) => MyPurchasesScreen()),
  //     );
  //   }
  // } catch (e) {
  //   debugPrint("❌ Error decoding payload: $e");
  // }
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  debugPrint('Background tap payload: ${response.payload}');
  // try {
  //   final Map<String, dynamic> data = jsonDecode(response.payload.toString());

  //   if (data['type'] == "2") {
  //     debugPrint(
  //       "Navigating to chat screen for chatRoomId: ${data['chatRoomId']}",
  //     );

  //     navigatorKey.currentState?.push(
  //       MaterialPageRoute(
  //         builder:
  //             (_) => ChatScreen(
  //               chatRoomId: '${data['_id']}',
  //               chatRoomIdWebSocket: '${data['chatRoomId']}',
  //               userrole: true,
  //             ),
  //       ),
  //     );
  //   } else if (data['type'] == "1") {
  //     debugPrint(
  //       "Navigating to chat screen for chatRoomId: ${data['chatRoomId']}",
  //     );
  //     navigatorKey.currentState?.push(
  //       MaterialPageRoute(builder: (_) => YourPostsScreen()),
  //     );
  //   } else if (data['type'] == "6") {
  //     debugPrint(
  //       "Navigating to chat screen for chatRoomId: ${data['chatRoomId']}",
  //     );
  //     navigatorKey.currentState?.push(
  //       MaterialPageRoute(
  //         builder:
  //             (_) => ItemDetailScreen(
  //               passData: 0,
  //               bookNow: int.parse(data['rentalPrices']),
  //               buyNow: int.parse(data['sellprices']),
  //               isLike: bool.parse(data['wishlist']),
  //               postId: data['postId'],
  //               postIndex: 0,
  //               screenName: "Notification",
  //             ),
  //       ),
  //     );
  //   } else if (data['type'] == "7") {
  //     debugPrint(
  //       "Navigating to chat screen for chatRoomId: ${data['chatRoomId']}",
  //     );
  //     navigatorKey.currentState?.push(
  //       MaterialPageRoute(builder: (_) => BookingsScreen()),
  //     );
  //   } else if (data['type'] == "8") {
  //     debugPrint(
  //       "Navigating to chat screen for chatRoomId: ${data['chatRoomId']}",
  //     );
  //     navigatorKey.currentState?.push(
  //       MaterialPageRoute(builder: (_) => MyRentalsScreen()),
  //     );
  //   } else if (data['type'] == "5") {
  //     debugPrint(
  //       "Navigating to chat screen for chatRoomId: ${data['chatRoomId']}",
  //     );

  //     navigatorKey.currentState?.push(
  //       MaterialPageRoute(builder: (_) => UserCoinScreen()),
  //     );
  //   } else if (data['type'] == "PURCHASE") {
  //     navigatorKey.currentState?.push(
  //       MaterialPageRoute(builder: (_) => BookingsScreen()),
  //     );
  //   } else if (data['type'] == "purchase_approved") {
  //     navigatorKey.currentState?.push(
  //       MaterialPageRoute(builder: (_) => MyPurchasesScreen()),
  //     );
  //   }
  // } catch (e) {
  //   debugPrint("❌ Error decoding payload: $e");
  // }
}

Future<void> showNotification({
  required String title,
  required String body,
  required String payload,
}) async {
  debugPrint("🔥 Showing notification with payload: $payload");

  await flutterLocalNotificationsPlugin.show(
    DateTime.now().millisecondsSinceEpoch ~/ 1000,
    title,
    body,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        icon: "@mipmap/ic_launcher",
        'new_channel',
        'High Importance Notifications',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
      ),
    ),
    payload: payload,
  );
}
