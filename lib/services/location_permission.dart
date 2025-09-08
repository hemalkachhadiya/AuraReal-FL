import 'dart:io';
import 'package:aura_real/aura_real.dart';
import 'package:aura_real/screens/dahsboard/dashboard_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

// Future<bool> checkInternet() async {
//   var connectivity = await Connectivity().checkConnectivity();
//   if (connectivity.contains(ConnectivityResult.mobile) ||
//       connectivity.contains(ConnectivityResult.wifi)) {
//     return true;
//   } else {
//     return false;
//   }
// }

Future<bool> requestLocationPermission(BuildContext context) async {
  if (Platform.isAndroid) {
    PermissionStatus status = await Permission.location.status;

    if (status.isGranted) {
      debugPrint("✅ Location permission already granted.");
      context.navigator.pushNamedAndRemoveUntil(
        DashboardScreen.routeName,
            (route) => false,
      );      return true;
    }

    PermissionStatus permissionStatus = await Permission.location.request();

    if (permissionStatus.isDenied) {
      debugPrint("❌ Location permission denied.");
      return false;
    }

    if (permissionStatus.isPermanentlyDenied) {
      // showPermissionDialog(context);
      return false;
    }

    return permissionStatus.isGranted;
  } else {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // showPermissionDialog(context);
        return Future.error('Location permission denied');
      }
      return false;
    }

    if (permission == LocationPermission.always) {
      debugPrint("✅ Location permission already granted.");
      return true;
    }

    if (permission == LocationPermission.whileInUse) {
      return true;
    }

    if (permission == LocationPermission.deniedForever) {
      // showPermissionDialog(context);
      return false;
    }
    return permission == LocationPermission.always;
  }
}

// Future<bool> requestNoticationPermission(BuildContext context) async {
//   if (Platform.isAndroid) {
//     PermissionStatus status = await Permission.notification.status;
//
//     if (status.isGranted) {
//       debugPrint("✅ Notication permission already granted.");
//       return true;
//     }
//
//     PermissionStatus permissionStatus = await Permission.notification.request();
//
//     if (permissionStatus.isDenied) {
//       debugPrint("❌ Notication permission denied.");
//       return false;
//     }
//
//     if (permissionStatus.isPermanentlyDenied) {
//       // showNotificationPermissionDialog(context);
//       return false;
//     }
//
//     return permissionStatus.isGranted;
//   } else {
//     final iosPlugin =
//     flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
//         IOSFlutterLocalNotificationsPlugin>();
//
//     bool? result = await iosPlugin?.requestPermissions(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//
//     if (result == true) {
//       debugPrint("✅ Notification permission granted on iOS.");
//     } else {
//       debugPrint("❌ Notification permission denied on iOS.");
//     }
//
//     return result ?? false;
//   }
// }
