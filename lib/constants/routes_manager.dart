import 'package:aura_real/aura_real.dart';
import 'package:aura_real/screens/home/post/posts/video_player_screen.dart';

class RouteManager {
  static String get initialRoute => SplashScreen.routeName;

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      /// splash
      case SplashScreen.routeName:
        return MaterialPageRoute(
          builder: SplashScreen.builder,
          settings: settings,
        );

      /// sign in
      case SignInScreen.routeName:
        return MaterialPageRoute(
          builder: SignInScreen.builder,
          settings: settings,
        );

      /// sign up
      case SignUpScreen.routeName:
        return MaterialPageRoute(
          builder: SignUpScreen.builder,
          settings: settings,
        );

      /// Password Reset Screen
      case PasswordRestScreen.routeName:
        return MaterialPageRoute(
          builder: PasswordRestScreen.builder,
          settings: settings,
        );

      /// Check Your EmailS screen
      case CheckYourEmailScreen.routeName:
        return MaterialPageRoute(
          builder: CheckYourEmailScreen.builder,
          settings: settings,
        );

      /// Create New  Password Screen
      case CreateNewPasswordScreen.routeName:
        return MaterialPageRoute(
          builder: CreateNewPasswordScreen.builder,
          settings: settings,
        );

      case MapScreen.routeName:
        return MaterialPageRoute(
          builder: MapScreen.builder,
          settings: settings,
        );

      /// Your Location Screen
      case YourLocationScreen.routeName:
        return MaterialPageRoute(
          builder: YourLocationScreen.builder,
          settings: settings,
        );

      /// Dashboard Screen
      case DashboardScreen.routeName:
        return MaterialPageRoute(
          builder: DashboardScreen.builder,
          settings: settings,
        );

      /// Home Screen
      case HomeScreen.routeName:
        return MaterialPageRoute(
          builder: HomeScreen.builder,
          settings: settings,
        );

      /// Upload Screen
      case UploadScreen.routeName:
        return MaterialPageRoute(
          builder: UploadScreen.builder,
          settings: settings,
        );

      /// Add Post Screen
      case AddPostScreen.routeName:
        return MaterialPageRoute(
          builder: AddPostScreen.builder,
          settings: settings,
        );

      /// Notification Screen
      case NotificationScreen.routeName:
        return MaterialPageRoute(
          builder: NotificationScreen.builder,
          settings: settings,
        );

      /// Rating Screen
      case RatingScreen.routeName:
        return MaterialPageRoute(
          builder: RatingScreen.builder,
          settings: settings,
        );

      /// Chat Screen
      case ChatScreen.routeName:
        return MaterialPageRoute(
          builder: ChatScreen.builder,
          settings: settings,
        );

      /// Setting Screen
      case SettingScreen.routeName:
        return MaterialPageRoute(
          builder: SettingScreen.builder,
          settings: settings,
        );

      /// Profile Screen
      case ProfileScreen.routeName:
        return MaterialPageRoute(
          builder: ProfileScreen.builder,
          settings: settings,
        );

      /// Change Password Screen
      case ChangePasswordScreen.routeName:
        return MaterialPageRoute(
          builder: ChangePasswordScreen.builder,
          settings: settings,
        );

      ///Language Screen
      case LanguageScreen.routeName:
        return MaterialPageRoute(
          builder: LanguageScreen.builder,
          settings: settings,
        );

      // ///Full Screen Screen
      // case FullScreenPostScreen.routeName:
      //   return MaterialPageRoute(
      //     builder: FullScreenPostScreen.builder,
      //     settings: settings,
      //   );

      /// Message Screen
      case MessageScreen.routeName:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null ||
            args['chatUser'] == null ||
            args['chatRoomId'] == null) {
          throw ArgumentError(
            'Arguments {chatUser: ChatUser, chatRoomId: String} are required for MessageScreen',
          );
        }

        final ChatUser chatUser = args['chatUser'];
        final String chatRoomId = args['chatRoomId'];

        return MaterialPageRoute(
          builder:
              (context) => ChangeNotifierProvider<MessageProvider>(
                create:
                    (context) =>
                        MessageProvider()..initializeChat(
                          user: chatUser,
                          chatRoomId: chatRoomId,
                        ),
                child: MessageScreen(chatUser: chatUser),
              ),
          settings: settings,
        );
      // case MessageScreen.routeName:
      //   final args = settings.arguments as ChatUser?;
      //   if (args == null) {
      //     throw ArgumentError(
      //       'ChatUser argument is required for MessageScreen',
      //     );
      //   }
      //   return MaterialPageRoute(
      //     builder:
      //         (context) => ChangeNotifierProvider<MessageProvider>(
      //           create:
      //               (context) => MessageProvider()..initializeChat(user: args),
      //           child: MessageScreen(chatUser: args),
      //         ),
      //     settings: settings,
      //   );
    }
    return null;
  }
}
