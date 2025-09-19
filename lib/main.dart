import 'package:aura_real/aura_real.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
   FirebaseOptions firebaseOptions;

  if (Platform.isIOS) {
    firebaseOptions = const FirebaseOptions(
      apiKey: 'AIzaSyApNVyfagHrb5MUNhOLwKIV5Swh4JSfy8g',
      appId: '1:382221381003:ios-:af9c5c86b94cf26ca1938e',
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
