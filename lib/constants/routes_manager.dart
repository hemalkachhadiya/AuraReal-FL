import 'package:aura_real/aura_real.dart';
import 'package:aura_real/screens/auth/check_your_email/check_your_email_screen.dart';
import 'package:aura_real/screens/auth/password_reset/password_reset_screen.dart';
import 'package:aura_real/screens/auth/your_location/your_location_screen.dart';
import 'package:aura_real/screens/dahsboard/dashboard_screen.dart';
import 'package:aura_real/screens/home/add_post/add_post_screen.dart';
import 'package:aura_real/screens/home/home/home_screen.dart';
import 'package:aura_real/screens/home/notification/notification_screen.dart';
import 'package:aura_real/screens/home/upload/upload_screen.dart';
import 'package:aura_real/screens/rating/rating_screen.dart';

import '../screens/auth/create_new_password/create_new_password_screen.dart';

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
    }
    return null;
  }
}
