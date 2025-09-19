// import 'package:aura_real/aura_real.dart';
// import 'package:geolocator/geolocator.dart';
//
//
//
// Future<bool> requestLocationPermission(BuildContext context) async {
//   if (Platform.isAndroid) {
//     PermissionStatus status = await Permission.location.status;
//
//     if (status.isGranted) {
//       debugPrint("✅ Location permission already granted.");
//       context.navigator.pushNamedAndRemoveUntil(
//         DashboardScreen.routeName,
//             (route) => false,
//       );      return true;
//     }
//
//     PermissionStatus permissionStatus = await Permission.location.request();
//
//     if (permissionStatus.isDenied) {
//       debugPrint("❌ Location permission denied.");
//       return false;
//     }
//
//     if (permissionStatus.isPermanentlyDenied) {
//       // showPermissionDialog(context);
//       return false;
//     }
//
//     return permissionStatus.isGranted;
//   } else {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       return Future.error('Location services are disabled.');
//     }
//
//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         // showPermissionDialog(context);
//         return Future.error('Location permission denied');
//       }
//       return false;
//     }
//
//     if (permission == LocationPermission.always) {
//       debugPrint("✅ Location permission already granted.");
//       return true;
//     }
//
//     if (permission == LocationPermission.whileInUse) {
//       return true;
//     }
//
//     if (permission == LocationPermission.deniedForever) {
//       // showPermissionDialog(context);
//       return false;
//     }
//     return permission == LocationPermission.always;
//   }
// }
//
//
