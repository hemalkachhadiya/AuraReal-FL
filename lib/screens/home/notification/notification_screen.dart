import 'package:aura_real/aura_real.dart';
import 'package:aura_real/screens/home/notification/notification_provider.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  static const routeName = "notification_screen";

  static Widget builder(BuildContext context) {
    return ChangeNotifierProvider<NotificationProvider>(
      create: (c) => NotificationProvider(),
      child: const NotificationScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          body: StackedLoader(
            loading: provider.loader,
            child: SafeArea(
              child: Directionality(
                textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                child: Column(
                  children: [
                    8.ph.spaceVertical,
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Constants.horizontalPadding,
                      ),
                      child: AppBackIcon(title: context.l10n?.notificationsCap),
                    ),
                    Expanded(
                      child: StackedLoader(
                        loading: provider.loader,
                        child: CustomListView(
                          itemCount: provider.notificationList.length,
                          onRefresh:
                              () =>
                                  provider.getAllNotificationAPI(resetData: true),
                          separatorBuilder: (p0, p1) => SizedBox(height: 16.ph),
                          itemBuilder:
                              (context, index) => Dismissible(
                                key: Key(index.toString()),
                                direction:
                                    isArabic
                                        ? DismissDirection.endToStart
                                        : DismissDirection.startToEnd,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.pw,
                                    vertical: 12.ph,
                                  ),
                                  child: Row(
                                    children: [
                                      // Profile Image
                                      Container(
                                        width: 57.pw,
                                        height: 57.ph,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                            width: 1,
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            28.5,
                                          ),
                                          child: AssetsImg(
                                            imagePath:
                                                AssetRes.notificationUserImg,
                                            width: 57,
                                            height: 57,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),

                                      SizedBox(width: 12.pw),

                                      // Notification Content
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // User Name
                                            Text(
                                              provider
                                                      .notificationList[index]
                                                      .title ??
                                                  "",
                                              style: styleW600S16.copyWith(
                                                color: Colors.black87,
                                              ),
                                            ),

                                            SizedBox(height: 4.ph),

                                            // Notification Message
                                            Text(
                                              provider
                                                      .notificationList[index]
                                                      .body ??
                                                  "",
                                              style: styleW400S12.copyWith(
                                                color: Colors.grey.shade600,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),

                                            SizedBox(height: 4.ph),

                                            // Time
                                            Text(
                                              isArabic ? "الآن" : "Just now",
                                              style: styleW400S12.copyWith(
                                                color: Colors.grey.shade500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                        ),
                      ),
                    ),
                    20.ph.spaceVertical,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
