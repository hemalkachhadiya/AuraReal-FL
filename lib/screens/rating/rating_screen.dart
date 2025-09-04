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
                                          color: provider.getCameraTabTextColor(),
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
                                  Flexible(
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
                                          8.pw.spaceHorizontal,
                                          // Rating Section
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                "(8.84/10)",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              8.pw.spaceHorizontal,
                                              StarRatingWidget(
                                                rating: 4.5,
                                                size: 16,
                                                activeColor:
                                                    ColorRes.yellowColor,
                                                inactiveColor: Colors.grey,
                                              ),
                                              8.pw.spaceHorizontal,
                                              Text(
                                                "5.0",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),

                                          20.ph.spaceVertical,

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
                                      color: Colors.black.withValues(alpha: 0.5),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.flash_on,
                                      color: Colors.white,
                                      size: 30,
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
                                      child: Icon(
                                        Icons.camera_alt,
                                        color: ColorRes.primaryColor,
                                        size: 35,
                                      ),
                                    ),
                                  ),

                                  // Gallery Button
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.5),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.photo_library,
                                      color: Colors.white,
                                      size: 25,
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
