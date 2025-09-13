import 'package:aura_real/aura_real.dart'; // Removed duplicate import

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
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final isArabic = appProvider.locale?.languageCode == 'ar';
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
                  provider: null,
                  onTap: () {
                    context.navigator.pushNamed(ProfileScreen.routeName);
                  },
                  title: context.l10n?.profile ?? "",
                  img: AssetRes.user4Icon,
                ),
                buildTabWidget(
                  provider: null,
                  onTap: () {
                    context.navigator.pushNamed(ChangePasswordScreen.routeName);
                  },
                  title: context.l10n?.changePassword ?? "",
                  img: AssetRes.lock2Icon,
                ),
                buildTabWidget(
                  provider: null,
                  isLanguage: true,
                  onTap: () {
                    context.navigator.pushNamed(LanguageScreen.routeName);
                  },
                  title: context.l10n?.language ?? "",
                  img: AssetRes.languageCircleIcon,
                  appProvider: appProvider,
                ),
                buildTabWidget(
                  provider: context.read<SettingProvider>(),
                  onTap: () {
                    context.read<SettingProvider>().toggleNotification(
                      context.read<SettingProvider>().isNotificationEnabled,
                    );
                  },
                  title: context.l10n?.notificationsCap ?? "",
                  img: AssetRes.notificationIcon,
                  isSwitch: true,
                ),
                buildTabWidget(
                  provider: null,
                  onTap: () {},
                  title: context.l10n?.privacyPolicy ?? "",
                  img: AssetRes.informationIcon,
                ),
                buildTabWidget(
                  provider: null,
                  onTap: () {},
                  title: context.l10n?.termsAndCondition ?? "",
                  img: AssetRes.informationIcon,
                ),
                buildTabWidget(
                  provider: context.read<SettingProvider>(),
                  onTap: () {
                    showLogoutDialog(context, context.read<SettingProvider>());
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
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  margin: EdgeInsets.only(bottom: 15),
                  child: InkWell(
                    onTap: () {
                      context.navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(50),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: ColorRes.red,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.close,
                            color: ColorRes.white,
                            size: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Spacer(),
              ],
            ),
            Text(
              context.l10n?.logoutSpace ?? "",
              style: styleW700S24,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.l10n?.areYouSureWantToLogOut ?? "",
              style: styleW400S16.copyWith(color: ColorRes.grey6),
              textAlign: TextAlign.center,
            ),
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
                    onTap: provider.loader
                        ? null
                        : () async {
                      await provider.logoutTap(context);
                    },
                    style: styleW600S12.copyWith(color: ColorRes.white),
                  ),
                );
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
    bool? isLanguage = false,
    SettingProvider? provider,
    AppProvider? appProvider,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(0),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgAsset(imagePath: img ?? "", width: 24.pw, height: 24.ph),
            10.pw.spaceHorizontal,
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    title ?? "",
                    style: styleW500S14.copyWith(color: ColorRes.black),
                  ),
                  if (isLanguage!)
                    Flexible(
                      child: Padding(
                        padding: EdgeInsets.only(left: 25.pw), // Increased space for better separation
                        child: Text(
                          appProvider?.isArabic ?? false
                              ? "اللغة الحالية (${appProvider?.getLanguageName(appProvider.locale?.languageCode ?? 'en')})"
                              : appProvider?.getLanguageName(appProvider.locale?.languageCode ?? 'en') ?? "English",
                          style: styleW500S14.copyWith(color: ColorRes.primaryColor),
                          overflow: TextOverflow.ellipsis, // Handles long text
                        ),
                      ),
                    ),
                ],
              ),
            ),
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