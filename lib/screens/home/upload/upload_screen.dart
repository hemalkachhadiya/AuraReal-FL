import 'dart:ui' as ui;
import 'package:aura_real/aura_real.dart';
import 'package:aura_real/apis/model/post_model.dart';

class UploadScreen extends StatelessWidget {
  final PostModel? post;

  const UploadScreen({super.key, this.post});

  static const routeName = "upload_screen";

  static Widget builder(BuildContext context, {PostModel? post}) {
    // If post is not provided directly, try to get it from route arguments
    final PostModel? routePost =
        post ?? (ModalRoute.of(context)?.settings.arguments as PostModel?);

    // Extract userId from routePost or provide a default/fallback
    final String? userId = routePost?.userId?.id;
    print("userId======= ${userId}");
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UploadProvider>(
          create:
              (c) =>
                  UploadProvider(userId ?? ''), // Pass userId to UploadProvider
        ),
        ChangeNotifierProvider<PostsProvider>(create: (c) => PostsProvider()),
      ],
      child: UploadScreen(post: routePost),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context, listen: true);
    final isArabic = appProvider.locale?.languageCode == 'ar';

    return Consumer<UploadProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          body: Directionality(
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      height: 300,
                      width: double.infinity,
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(0.0),
                            topRight: Radius.circular(0.0),
                            bottomLeft:
                                isArabic
                                    ? Radius.circular(40.0)
                                    : Radius.circular(0.0),
                            bottomRight:
                                isArabic
                                    ? Radius.circular(0.0)
                                    : Radius.circular(40.0),
                          ),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(0.0),
                          topRight: Radius.circular(0.0),
                          bottomLeft:
                              isArabic
                                  ? Radius.circular(40.0)
                                  : Radius.circular(0.0),
                          bottomRight:
                              isArabic
                                  ? Radius.circular(0.0)
                                  : Radius.circular(40.0),
                        ),
                        child: Stack(
                          children: [
                            // Blurred background image
                            Transform(
                              alignment: Alignment.center,
                              transform:
                                  Matrix4.identity()
                                    ..scale(isArabic ? -1.0 : 1.0, 1.0, 1.0),
                              // Horizontal flip
                              child: SvgAsset(
                                imagePath: AssetRes.blurBgIcon,
                                height: 300,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            // Foreground image
                            Transform(
                              alignment: Alignment.center,
                              transform:
                                  Matrix4.identity()
                                    ..scale(isArabic ? -1.0 : 1.0, 1.0, 1.0),
                              // Horizontal flip
                              child: ImageFiltered(
                                imageFilter: ui.ImageFilter.blur(
                                  sigmaX: 6,
                                  sigmaY: 6,
                                ),
                                child: Center(
                                  child: AssetsImg(
                                    imagePath: AssetRes.uploadBgIcon,
                                    height: 300,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),

                            // Overlay content
                            Stack(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      40.ph.spaceVertical,
                                      // Back button
                                      InkWell(
                                        onTap: () => context.navigator.pop(),
                                        child: Align(
                                          alignment:
                                              isArabic
                                                  ? Alignment.centerRight
                                                  : Alignment.centerLeft,
                                          child: Container(
                                            width: 32.pw,
                                            height: 32.ph,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: ColorRes.primaryColor,
                                            ),
                                            child: Center(
                                              child: Transform.rotate(
                                                angle: isArabic ? 3.14159 : 0,
                                                // 180 degrees for Arabic
                                                child: SvgAsset(
                                                  imagePath: AssetRes.leftIcon,
                                                  // Use same icon for both
                                                  color: ColorRes.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      16.ph.spaceVertical,
                                      // Star rating and score
                                      Row(
                                        children: [
                                          StarRatingWidget(
                                            rating: 4,
                                            size: 13,
                                            activeColor: ColorRes.yellowColor,
                                            inactiveColor: ColorRes.yellowColor,
                                          ),
                                          10.pw.spaceHorizontal,
                                          Text(
                                            provider.profileData?.ratingsAvg
                                                    .toString() ??
                                                "0.0",
                                            style: styleW700S16.copyWith(
                                              color: ColorRes.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      10.ph.spaceVertical,
                                      // Name
                                      Text(
                                        provider.profileData?.username ?? "",
                                        style: styleW700S24.copyWith(
                                          color: ColorRes.white,
                                        ),
                                      ),
                                      23.ph.spaceVertical,
                                      // User details
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            width: 130,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    SvgAsset(
                                                      imagePath:
                                                          AssetRes.userIcon2,
                                                      width: 18,
                                                      height: 18,
                                                    ),
                                                    8.pw.spaceHorizontal,
                                                    Expanded(
                                                      child: Text(
                                                        provider
                                                                .profileData
                                                                ?.bio ??
                                                            "-",
                                                        maxLines: 1,
                                                        style: styleW500S12
                                                            .copyWith(
                                                              color:
                                                                  ColorRes
                                                                      .white,
                                                            ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                8.ph.spaceVertical,
                                                Row(
                                                  children: [
                                                    SvgAsset(
                                                      imagePath:
                                                          AssetRes.smsIcon,
                                                      width: 18,
                                                      height: 18,
                                                    ),
                                                    8.pw.spaceHorizontal,
                                                    Expanded(
                                                      child: Text(
                                                        provider
                                                                .profileData
                                                                ?.email ??
                                                            "-",
                                                        style: styleW500S12
                                                            .copyWith(
                                                              color:
                                                                  ColorRes
                                                                      .white,
                                                            ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                8.ph.spaceVertical,
                                                Row(
                                                  children: [
                                                    SvgAsset(
                                                      imagePath:
                                                          AssetRes.globalIcon,
                                                      width: 18,
                                                      height: 18,
                                                    ),
                                                    8.pw.spaceHorizontal,
                                                    Text(
                                                      provider
                                                              .profileData
                                                              ?.website ??
                                                          "-",
                                                      maxLines: 1,
                                                      style: styleW500S12
                                                          .copyWith(
                                                            color:
                                                                ColorRes.white,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          Row(
                                            spacing: 8.pw,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                children: [
                                                  Text(
                                                    provider
                                                            .profileData
                                                            ?.followersCount
                                                            .toString() ??
                                                        "0.0",
                                                    style: styleW700S16
                                                        .copyWith(
                                                          color: ColorRes.white,
                                                        ),
                                                  ),
                                                  Text(
                                                    isArabic
                                                        ? "متابع"
                                                        : "Follower",
                                                    style: styleW400S10
                                                        .copyWith(
                                                          color: ColorRes.white,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                              Column(
                                                children: [
                                                  Text(
                                                    provider
                                                            .profileData
                                                            ?.ratingsAvg
                                                            .toString() ??
                                                        "",
                                                    style: styleW700S16
                                                        .copyWith(
                                                          color: ColorRes.white,
                                                        ),
                                                  ),
                                                  Text(
                                                    isArabic
                                                        ? "نقاط التقييم"
                                                        : "Rating Points",
                                                    style: styleW400S10
                                                        .copyWith(
                                                          color: ColorRes.white,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                              Column(
                                                children: [
                                                  Text(
                                                    provider
                                                            .profileData
                                                            ?.totalPosts
                                                            .toString() ??
                                                        "",
                                                    style: styleW700S16
                                                        .copyWith(
                                                          color: ColorRes.white,
                                                        ),
                                                  ),
                                                  Text(
                                                    isArabic ? "منشور" : "Post",
                                                    style: styleW400S10
                                                        .copyWith(
                                                          color: ColorRes.white,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  right:
                                      isArabic
                                          ? null
                                          : Constants.horizontalPadding,
                                  left:
                                      isArabic
                                          ? Constants.horizontalPadding
                                          : null,
                                  top: 50,
                                  child: Container(
                                    width: 98,
                                    height: 98,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: ColorRes.grey3,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    padding: EdgeInsets.all(2),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: CachedImage(
                                        provider.profileData?.profileImage !=
                                                null
                                            ? EndPoints.domain +
                                                provider
                                                    .profileData!
                                                    .profileImage!
                                                    .toBackslashPath()
                                            : "",
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    Positioned(
                      right: isArabic ? null : 0,
                      left: isArabic ? 0 : null,
                      bottom: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Custom Follow Button
                          Container(
                            width: 100.pw,
                            height: 48.ph,
                            decoration: BoxDecoration(
                              color: ColorRes.primaryColor,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(15),
                                onTap: () {
                                  // Handle follow action
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgAsset(
                                      imagePath: AssetRes.userIcon2,
                                      width: 16,
                                      height: 16,
                                      color: ColorRes.white,
                                    ),
                                    SizedBox(width: 6.pw),
                                    Text(
                                      isArabic ? "متابعة" : "Follow",
                                      style: TextStyle(
                                        color: ColorRes.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          7.pw.spaceHorizontal,
                          // Custom Message Button
                          Container(
                            width: 100.pw,
                            height: 48.ph,
                            decoration: BoxDecoration(
                              color: ColorRes.primaryColor,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(15),
                                onTap: () {
                                  // Handle message action
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgAsset(
                                      imagePath: AssetRes.msgIcon,
                                      width: 16,
                                      height: 16,
                                      color: ColorRes.white,
                                    ),
                                    SizedBox(width: 6.pw),
                                    Text(
                                      isArabic ? "رسالة" : "Message",
                                      style: TextStyle(
                                        color: ColorRes.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          14.pw.spaceHorizontal,
                        ],
                      ),
                    ),
                  ],
                ),

                25.ph.spaceVertical,
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(color: ColorRes.white),
                    child: CustomListView(
                      itemCount:
                          provider.loader
                              ? 0
                              : provider.postByUserResponse.length + 1,
                      onRefresh:
                          () => provider.getPostByUserAPI(
                            resetData: true,

                          ),
                      emptyWidget: UnKnownScreen(),
                      showEmptyWidget:
                          !provider.loader &&
                          provider.postByUserResponse.isEmpty,
                      separatorBuilder:
                          (ctx, ind) => Container(
                            height: 1.ph,
                            width: 100.pw,
                            color: ColorRes.black.withValues(alpha: 0.1),
                          ),
                      itemBuilder: (context, index) {
                        if (index >= provider.postByUserResponse.length) {
                          if (!provider.hasMoreData) {
                            return Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: Text(
                                  'No more items',
                                  style: styleW500S12.copyWith(
                                    color: ColorRes.grey,
                                  ),
                                ),
                              ),
                            );
                          }
                          if (!provider.isApiCalling) {
                            provider.getPostByUserAPI();
                          }
                          return SizedBox(
                            height: 100.ph,
                            child: const SmallLoader(),
                          );
                        }
                        return PostCard(
                          post: provider.postByUserResponse[index],
                          onTap: () {},
                        );
                      },
                    ),
                  ),
                ),
                // Expanded(
                //   child: Consumer<PostsProvider>(
                //     builder: (context, postsProvider, child) {
                //       return RefreshIndicator(
                //         color: ColorRes.primaryColor,
                //         onRefresh: () => postsProvider.loadPosts(),
                //         child: CustomListView(
                //           padding: EdgeInsets.zero,
                //           separatorBuilder:
                //               (p0, p1) => Container(
                //                 padding: EdgeInsets.only(bottom: 10.ph),
                //               ),
                //           physics: const AlwaysScrollableScrollPhysics(),
                //           itemCount: postsProvider.posts.length,
                //           itemBuilder: (context, index) {
                //             final listPost = postsProvider.posts[index];
                //             return PostCard(post: listPost,onTap: (){},);
                //           },
                //         ),
                //       );
                //     },
                //   ),
                // ),
              ],
            ),
          ),
        );
      },
    );
  }
}
