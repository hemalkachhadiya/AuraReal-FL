import 'package:aura_real/aura_real.dart';
import 'package:aura_real/screens/chat/chat_list/chat_provider.dart'; // Import ChatProvider
import 'package:aura_real/screens/chat/message/message_provider.dart';
import 'package:aura_real/screens/setting/setting/setting_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    Constants.deviceHeight = MediaQuery.of(context).size.height;
    Constants.deviceWidth = MediaQuery.of(context).size.width;
    Constants.isTablet = MediaQuery.of(context).size.width > 600;
    Constants.safeAreaPadding = MediaQuery.of(context).padding;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppProvider>(
          create: (c) => AppProvider()..init(), // Initialize AppProvider
        ),
        ChangeNotifierProvider<ChatProvider>(
          create:
              (c) =>
                  ChatProvider()
                    ..initializeChatData(), // Initialize ChatProvider
        ),
        ChangeNotifierProvider<SettingProvider>(
          create: (c) => SettingProvider(), // Add SettingProvider here
        ),

        // ChangeNotifierProvider<ChatProvider>(
        //    create: (c) => MessageProvider()..initializeChat(user: ChatUser()), // Initialize ChatProvider
        //  ),
      ],
      child: Consumer<AppProvider>(
        builder: (context, state, child) {
          return OKToast(
            child: Directionality(
              textDirection:
                  state.locale?.languageCode == 'ar'
                      ? TextDirection.rtl
                      : TextDirection.ltr,
              child: MaterialApp(
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                locale: state.locale,
                initialRoute: RouteManager.initialRoute,
                onGenerateRoute: RouteManager.onGenerateRoute,
                theme: ThemeData(
                  scaffoldBackgroundColor: ColorRes.dullWhite,
                  colorScheme: const ColorScheme.light().copyWith(
                    primary: ColorRes.primaryColor,
                  ),
                  fontFamily: AssetRes.poppins,
                ),
                navigatorKey: navigatorKey,
                debugShowCheckedModeBanner: false,
              ),
            ),
          );
        },
      ),
    );
  }
}

// import 'package:aura_real/aura_real.dart';
//
// GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
//
// class AppView extends StatelessWidget {
//   const AppView({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     Constants.deviceHeight = MediaQuery.of(context).size.height;
//     Constants.deviceWidth = MediaQuery.of(context).size.width;
//     Constants.isTablet = MediaQuery.of(context).size.width > 600;
//     Constants.safeAreaPadding = MediaQuery.of(context).padding;
//
//     return ChangeNotifierProvider<AppProvider>(
//       create: (c) => AppProvider()..init(), // Initialize immediately
//       child: Consumer<AppProvider>(
//         builder: (context, state, child) {
//           return OKToast(
//             child: Directionality(
//               textDirection: state.locale?.languageCode == 'ar'
//                   ? TextDirection.rtl
//                   : TextDirection.ltr,
//               child: MaterialApp(
//                 localizationsDelegates: AppLocalizations.localizationsDelegates,
//                 supportedLocales: AppLocalizations.supportedLocales,
//                 locale: state.locale,
//                 initialRoute: RouteManager.initialRoute,
//                 onGenerateRoute: RouteManager.onGenerateRoute,
//
//                 theme: ThemeData(
//                   scaffoldBackgroundColor: ColorRes.dullWhite,
//                   colorScheme: const ColorScheme.light().copyWith(
//                     primary: ColorRes.primaryColor,
//                   ),
//                   fontFamily: AssetRes.poppins,
//                 ),
//                 navigatorKey: navigatorKey,
//                 debugShowCheckedModeBanner: false,
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
