import 'package:aura_real/aura_real.dart';

class RatingScreen extends StatelessWidget {
  const RatingScreen({super.key});

  static const routeName = "rating_screen";

  static Widget builder(BuildContext context) {
    return ChangeNotifierProvider<RatingProvider>(
      create: (context) => RatingProvider(),
      child: const RatingScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context, listen: true);
    final isArabic = appProvider.locale?.languageCode == 'ar';

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: ChangeNotifierProvider<RatingProvider>(
        create: (context) => RatingProvider(),
        child: SafeArea(
          child: Directionality(
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            child: Stack(
              children: [
                // Background Image
                Positioned.fill(
                  child: AssetsImg(
                    imagePath: AssetRes.ratingImg, // Replace with your image
                    fit: BoxFit.cover,
                  ),
                ),

                // Gradient Overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.3),
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                ),

                // Top Controls
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.pw,
                    vertical: 10.ph,
                  ),
                  child: Consumer<RatingProvider>(
                    builder: (context, provider, child) {
                      return Column(
                        children: [
                          40.ph.spaceVertical,

                          // Camera/Map Toggle
                          // Camera/Map Toggle - Updated section for your RatingScreen
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: ColorRes.lightBlue,
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(color: ColorRes.lightBlue),
                                ),
                                child: Row(
                                  children: [
                                    // Camera Tab
                                    SizedBox(
                                      width: 131.pw,
                                      height: 41.ph,
                                      child: SubmitButton(
                                        title: context.l10n?.camera ?? "",
                                        onTap: () {
                                          provider.setMode('camera');
                                        },
                                        style: styleW500S14.copyWith(
                                          color:
                                              provider.getCameraTabTextColor(),
                                        ),
                                        bgColor: provider.getCameraTabBgColor(),
                                        raduis: 10,
                                      ),
                                    ),
                                    // Map Tab
                                    SizedBox(
                                      width: 131.pw,
                                      height: 41.ph,
                                      child: SubmitButton(
                                        raduis: 10,
                                        title: context.l10n?.map ?? "",
                                        style: styleW500S14.copyWith(
                                          color: provider.getMapTabTextColor(),
                                        ),
                                        onTap: () {
                                          provider.setMode('map');
                                        },
                                        bgColor: provider.getMapTabBgColor(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          Spacer(),

                          // Profile Info Section
                          Column(
                            children: [
                              // Name and Age
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        openCustomDialog(
                                          context,
                                          borderRadius: 30,

                                          title: context.l10n?.sendRating ?? "",
                                          customChild: StarRatingWidget(
                                            rating: 5,
                                            activeColor: ColorRes.primaryColor,
                                            inactiveColor:
                                                ColorRes.primaryColor,
                                            size: 37,
                                          ),
                                          confirmBtnTitle:
                                              context.l10n?.send ?? "",
                                        );
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: ColorRes.primaryColor
                                              .withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 8,
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              isArabic
                                                  ? "كادين شلايفر"
                                                  : "Kadin Schleifer",
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                              style: styleW700S20.copyWith(
                                                color: ColorRes.white,
                                              ),
                                            ),
                                            9.pw.spaceVertical,
                                            // Rating Section
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "(8.84/10)",
                                                  style: styleW700S12.copyWith(
                                                    color: ColorRes.white,
                                                  ),
                                                ),
                                                8.pw.spaceHorizontal,
                                                StarRatingWidget(
                                                  rating: 4.5,
                                                  size: 10,
                                                  space: 8,
                                                  activeColor:
                                                      ColorRes.yellowColor,
                                                  inactiveColor: Colors.grey,
                                                ),
                                                8.pw.spaceHorizontal,
                                                Text(
                                                  "5.0",
                                                  style: styleW700S12.copyWith(
                                                    color: ColorRes.white,
                                                  ),
                                                ),
                                              ],
                                            ),

                                            5.ph.spaceVertical,

                                            // Rate Button
                                            SizedBox(
                                              width: 80.pw,
                                              child: SubmitButton(
                                                title: context.l10n?.rate ?? "",
                                                height: 28.ph,
                                                style: styleW500S12.copyWith(
                                                  color: ColorRes.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  20.pw.spaceHorizontal,
                                  // Action Buttons
                                  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      SizedBox(
                                        width: 120.pw,
                                        child: SubmitButton2(
                                          raduis: 15,
                                          height: 45.ph,
                                          title:
                                              context.l10n?.profileVisit ?? "",
                                          onTap: () {},
                                          icon: AssetRes.userIcon2,
                                        ),
                                      ),
                                      10.ph.spaceVertical,

                                      SizedBox(
                                        width: 120.pw,
                                        child: SubmitButton2(
                                          height: 45.ph,
                                          raduis: 15,
                                          title:
                                              context.l10n?.privateChat ?? "",
                                          onTap: () {},
                                          icon: AssetRes.msgIcon,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              40.ph.spaceVertical,

                              // Bottom Control Buttons
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  // Lightning Button
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(
                                        alpha: 0.4,
                                      ),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.4,
                                        ),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(19),
                                      child: SvgAsset(
                                        imagePath: AssetRes.flashIcon,
                                        width: 19,
                                        height: 19,
                                      ),
                                    ),
                                  ),

                                  // Camera Button
                                  InkWell(
                                    onTap: () async {
                                      await checkCameraPermission(context);
                                      if (context.mounted) {}
                                    },
                                    borderRadius: BorderRadius.circular(80),
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: ColorRes.primaryColor,
                                          width: 4,
                                        ),
                                      ),
                                      child: Container(),
                                    ),
                                  ),

                                  // Gallery Button
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(
                                        alpha: 0.5,
                                      ),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.3,
                                        ),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(19),
                                      child: SvgAsset(
                                        imagePath: AssetRes.cameraIcon3,
                                        width: 19,
                                        height: 19,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              40.ph.spaceVertical,
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
