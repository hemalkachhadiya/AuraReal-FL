import 'package:aura_real/aura_real.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n?.setting ?? "Settings",
          style: TextStyle(color: ColorRes.primaryColor),
        ),
        backgroundColor: ColorRes.dullWhite,
        elevation: 0,
      ),
      body: CustomSingleChildScroll(
        padding: EdgeInsets.symmetric(
          horizontal: Constants.horizontalPadding,
          vertical: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n?.message ?? "Welcome to Settings",
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            _buildLanguageSection(context),
            const SizedBox(height: 20),

            SubmitButton(
              title: context.l10n?.logout ?? "",
              onTap:
                  () => context.navigator.pushNamedAndRemoveUntil(
                    SignInScreen.routeName,
                    (_) => false,
                  ),
            ),
            // Add other settings here (e.g., notifications, logout)
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSection(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(context.l10n?.language ?? "Language"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children:
                    appProvider.languageList.map((locale) {
                      return ListTile(
                        title: Text(
                          locale.languageCode == 'en' ? 'English' : 'العربية',
                          style: TextStyle(
                            color:
                                appProvider.locale == locale
                                    ? ColorRes.primaryColor
                                    : null,
                          ),
                        ),
                        onTap: () async {
                          await appProvider.changeLanguage(locale);
                          Navigator.pop(context);
                        },
                      );
                    }).toList(),
              ),
            );
          },
        );
      },
      child: Row(
        children: [
          SvgAsset(
            imagePath: AssetRes.languageCircleIcon,
            width: 24,
            height: 24,
          ),
          const SizedBox(width: 10),
          Text(
            context.l10n?.language ?? "Language",
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
          const Spacer(),
          Text(
            Provider.of<AppProvider>(context).locale?.languageCode == 'en'
                ? 'English'
                : 'العربية',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}
