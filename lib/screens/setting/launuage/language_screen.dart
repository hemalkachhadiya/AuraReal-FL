import 'package:aura_real/aura_real.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  static const routeName = "language_screen";

  static Widget builder(BuildContext context) {
    // Don't create new AppProvider, use existing one
    return const LanguageScreen();
  }

  @override
  Widget build(BuildContext context) {
    // Use Consumer to listen to changes
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final isArabic = appProvider.locale?.languageCode == 'ar';

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Constants.horizontalPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // App Bar with back button and title
                  AppBackIcon(title: context.l10n?.language ?? "Language"),

                  const SizedBox(height: 37),

                  // Show loading indicator if changing language
                  if (appProvider.loader)
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                ColorRes.primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            isArabic
                                ? 'جاري تغيير اللغة...'
                                : 'Changing language...',
                            style: styleW500S16.copyWith(
                              color: ColorRes.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Language options using map instead of ListView.builder
                  ...appProvider.languageList.map((locale) {
                    final isSelected =
                        appProvider.locale?.languageCode == locale.languageCode;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? ColorRes.primaryColor.withValues(alpha: 0.1)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border:
                            isSelected
                                ? Border.all(
                                  color: ColorRes.primaryColor,
                                  width: 1.5,
                                )
                                : null,
                      ),
                      child: RadioListTile<Locale>(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        title: Row(
                          children: [
                            // Language flag/icon
                            ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: AssetsImg(
                                imagePath:
                                    locale.languageCode == 'en'
                                        ? AssetRes.enIcon
                                        : AssetRes.arIcon,
                                width: 46,
                                height: 46,
                              ),
                            ),

                            const SizedBox(width: 12),

                            // Language name
                            Expanded(
                              child: Text(
                                locale.languageCode == 'en'
                                    ? 'English'
                                    : 'العربية',
                                style: styleW500S16.copyWith(
                                  color:
                                      isSelected
                                          ? ColorRes.primaryColor
                                          : ColorRes.black,
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                ),
                              ),
                            ),

                            // Current language indicator
                            if (isSelected)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: ColorRes.primaryColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  isArabic ? 'حالي' : 'Current',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        value: locale,
                        groupValue:
                            appProvider.locale ?? const Locale('en', 'US'),
                        onChanged:
                            appProvider.loader
                                ? null // Disable during loading
                                : (Locale? value) async {
                                  if (value != null &&
                                      value != appProvider.locale) {
                                    // Set loader to true before changing language
                                    appProvider.loader = true;

                                    try {
                                      await appProvider.changeLanguage(value);

                                      // Show success message
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              value.languageCode == 'ar'
                                                  ? 'تم تغيير اللغة إلى العربية'
                                                  : 'Language changed to English',
                                            ),
                                            backgroundColor:
                                                ColorRes.primaryColor,
                                            duration: const Duration(
                                              seconds: 2,
                                            ),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      print('Error changing language: $e');
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              isArabic
                                                  ? 'خطأ في تغيير اللغة'
                                                  : 'Error changing language',
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    } finally {
                                      appProvider.loader = false;
                                    }
                                  }
                                },
                        activeColor: ColorRes.primaryColor,
                        controlAffinity: ListTileControlAffinity.trailing,
                      ),
                    );
                  }),

                  const Spacer(),

                  // // Additional options section
                  // Container(
                  //   padding: const EdgeInsets.all(16),
                  //   margin: const EdgeInsets.only(top: 20),
                  //   decoration: BoxDecoration(
                  //     color: Colors.grey[50],
                  //     borderRadius: BorderRadius.circular(12),
                  //   ),
                  //   child: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       Text(
                  //         isArabic ? 'معلومات إضافية' : 'Additional Information',
                  //         style: styleW600S14.copyWith(color: ColorRes.black),
                  //       ),
                  //       const SizedBox(height: 8),
                  //       Text(
                  //         isArabic
                  //             ? 'سيتم تطبيق اللغة المحددة على جميع أجزاء التطبيق'
                  //             : 'The selected language will be applied to all parts of the app',
                  //         style: styleW400S12.copyWith(color: Colors.grey[600]),
                  //       ),
                  //       const SizedBox(height: 12),
                  //
                  //       // Reset to default button
                  //       InkWell(
                  //         onTap: appProvider.loader ||
                  //             appProvider.locale?.languageCode == 'en'
                  //             ? null
                  //             : () async {
                  //           await appProvider.changeLanguage(
                  //             const Locale('en', 'US'),
                  //           );
                  //           if (context.mounted) {
                  //             ScaffoldMessenger.of(context).showSnackBar(
                  //               const SnackBar(
                  //                 content: Text('Language reset to English'),
                  //                 backgroundColor: ColorRes.primaryColor,
                  //               ),
                  //             );
                  //           }
                  //         },
                  //         child: Container(
                  //           padding: const EdgeInsets.symmetric(
                  //             horizontal: 12,
                  //             vertical: 8,
                  //           ),
                  //           decoration: BoxDecoration(
                  //             color: (appProvider.loader ||
                  //                 appProvider.locale?.languageCode == 'en')
                  //                 ? Colors.grey[300]
                  //                 : ColorRes.primaryColor.withValues(alpha: 0.1),
                  //             borderRadius: BorderRadius.circular(8),
                  //             border: Border.all(
                  //               color: (appProvider.loader ||
                  //                   appProvider.locale?.languageCode == 'en')
                  //                   ? Colors.grey
                  //                   : ColorRes.primaryColor,
                  //             ),
                  //           ),
                  //           child: Row(
                  //             mainAxisSize: MainAxisSize.min,
                  //             children: [
                  //               Icon(
                  //                 Icons.refresh,
                  //                 size: 16,
                  //                 color: (appProvider.loader ||
                  //                     appProvider.locale?.languageCode == 'en')
                  //                     ? Colors.grey[600]
                  //                     : ColorRes.primaryColor,
                  //               ),
                  //               const SizedBox(width: 4),
                  //               Text(
                  //                 isArabic
                  //                     ? 'إعادة تعيين للإنجليزية'
                  //                     : 'Reset to English',
                  //                 style: TextStyle(
                  //                   fontSize: 12,
                  //                   color: (appProvider.loader ||
                  //                       appProvider.locale?.languageCode == 'en')
                  //                       ? Colors.grey[600]
                  //                       : ColorRes.primaryColor,
                  //                   fontWeight: FontWeight.w500,
                  //                 ),
                  //               ),
                  //             ],
                  //           ),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
