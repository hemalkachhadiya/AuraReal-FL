import 'package:aura_real/aura_real.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  static const routeName = "setting_screen";

  static Widget builder(BuildContext context) {
    return ChangeNotifierProvider<SettingProvider>(
      create: (c) => SettingProvider(),
      child: const SettingScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            leadingWidth: Constants.horizontalPadding,
            title: Text(
              context.l10n?.setting ?? "Settings",
              style: styleW700S22,
            ),
            backgroundColor: ColorRes.dullWhite,
            elevation: 0,
          ),
          body: CustomSingleChildScroll(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
            child: Column(
              spacing: 25.ph,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildTabWidget(
                  provider: provider,
                  onTap: () {
                    context.navigator.pushNamed(ProfileScreen.routeName);
                  },
                  title: context.l10n?.profile ?? "",
                  img: AssetRes.user4Icon,
                ),
                buildTabWidget(
                  provider: provider,
                  onTap: () {
                    context.navigator.pushNamed(ChangePasswordScreen.routeName);
                  },
                  title: context.l10n?.changePassword ?? "",
                  img: AssetRes.lock2Icon,
                ),
                buildTabWidget(
                  provider: provider,
                  onTap: () {
                    context.navigator.pushNamed(LanguageScreen.routeName);

                    // showDialog(
                    //   context: context,
                    //   builder: (context) {
                    //     return AlertDialog(
                    //       title: Text(context.l10n?.language ?? "Language"),
                    //       content: Column(
                    //         mainAxisSize: MainAxisSize.min,
                    //         children:
                    //             appProvider.languageList.map((locale) {
                    //               return ListTile(
                    //                 title: Text(
                    //                   locale.languageCode == 'en'
                    //                       ? 'English'
                    //                       : 'العربية',
                    //                   style: TextStyle(
                    //                     color:
                    //                         appProvider.locale == locale
                    //                             ? ColorRes.primaryColor
                    //                             : null,
                    //                   ),
                    //                 ),
                    //                 onTap: () async {
                    //                   await appProvider.changeLanguage(locale);
                    //                   if (context.mounted) {
                    //                     context.navigator.pop();
                    //                   }
                    //                 },
                    //               );
                    //             }).toList(),
                    //       ),
                    //     );
                    //   },
                    // );
                  },
                  title: context.l10n?.language ?? "",
                  img: AssetRes.languageCircleIcon,
                ),
                buildTabWidget(
                  provider: provider,
                  onTap: () {
                    provider.toggleNotification(provider.isNotificationEnabled);
                  },
                  title: context.l10n?.notificationsCap ?? "",
                  img: AssetRes.notificationIcon,
                  isSwitch: true,
                ),
                buildTabWidget(
                  provider: provider,
                  onTap: () {},
                  title: context.l10n?.privacyPolicy ?? "",
                  img: AssetRes.informationIcon,
                ),
                buildTabWidget(
                  provider: provider,
                  onTap: () {},
                  title: context.l10n?.termsAndCondition ?? "",
                  img: AssetRes.informationIcon,
                ),
                buildTabWidget(
                  provider: provider,
                  onTap: () {
                    showLogoutDialog(context, provider);
                    // openCustomDialog(
                    //                     //   context,
                    //                     //   borderRadius: 30,
                    //                     //   title: context.l10n?.logoutSpace ?? "",
                    //                     //   subtitle: context.l10n?.areYouSureWantToLogOut ?? "",
                    //                     //   customChild: Container(
                    //                     //     width: 225.pw,
                    //                     //     padding: EdgeInsets.only(top: 15.ph),
                    //                     //     child: SubmitButton(
                    //                     //       height: 45.ph,
                    //                     //       loading: provider.loader,
                    //                     //       title: context.l10n?.logout ?? "2",
                    //                     //       raduis: 15,
                    //                     //       onTap: () async {
                    //                     //         await provider.logoutTap(context);
                    //                     //       },
                    //                     //       style: styleW600S12.copyWith(color: ColorRes.white),
                    //                     //     ),
                    //                     //   ),
                    // );
                  },
                  title: context.l10n?.logout ?? "",
                  img: AssetRes.logoutIcon,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showLogoutDialog(BuildContext context, SettingProvider provider) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing during logout
      builder:
          (context) => AlertDialog(
            title: Text(context.l10n?.logoutSpace ?? "",style: styleW700S24, textAlign: TextAlign.center),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(context.l10n?.areYouSureWantToLogOut ?? "",style: styleW400S16.copyWith(color: ColorRes.grey6),
                  textAlign: TextAlign.center,),
                if (provider.loader) ...[
                  15.ph.spaceVertical,
                  CircularProgressIndicator(),
                  15.ph.spaceVertical,
                ],
              ],
            ),
            actions: [
              Center(
                child: Consumer<SettingProvider>(
                  builder: (context, provider, child) {
                    return Container(
                      width: 225.pw,
                      padding: EdgeInsets.only(top: 15.ph),
                      child: SubmitButton(
                        height: 45.ph,
                        loading: provider.loader,
                        title: context.l10n?.logout ?? "2",
                        raduis: 15,
                        onTap:
                            provider.loader
                                ? null
                                : () async {
                                  await provider.logoutTap(context);
                                },
                        style: styleW600S12.copyWith(color: ColorRes.white),
                      ),
                    )
                    /*TextButton(
                  onPressed: provider.loader
                      ? null
                      : () async {
                    await provider.logoutTap(context);
                  },
                  child: provider.loader
                      ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  )
                      : Text(
                    context.l10n?.logout ?? "Logout",
                    style: TextStyle(color: Colors.red),
                  ),
                )*/
                    ;
                  },
                ),
              ),
            ],
          ),
    );
  }

  Widget buildTabWidget({
    String? img,
    String? title,
    VoidCallback? onTap,
    bool? isSwitch = false,
    SettingProvider? provider,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(0),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          children: [
            SvgAsset(imagePath: img ?? "", width: 24.pw, height: 24.ph),
            10.pw.spaceHorizontal,
            Text(
              title ?? "",
              style: styleW500S14.copyWith(color: ColorRes.black),
            ),
            Spacer(),
            if (isSwitch!)
              SizedBox(
                width: 44.pw,
                height: 24.ph,
                child: Switch(
                  padding: EdgeInsets.symmetric(vertical: 0),
                  value: provider?.isNotificationEnabled ?? false,
                  onChanged: (value) {
                    provider?.toggleNotification(value);
                  },
                  activeColor: ColorRes.primaryColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
