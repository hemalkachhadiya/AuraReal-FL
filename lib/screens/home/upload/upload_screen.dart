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
            child: StackedLoader(
              loading: provider.loader,
              child: Column(
                children: [
                  Stack(
                    children: [
                      Stack(
                        children: [
                          /// BackGround Image
                          Container(
                            height: 315.ph,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(0),
                              // color: ColorRes.black.withValues(alpha: 0.5),
                            ),
                            child: Transform(
                              alignment: Alignment.center,
                              transform:
                                  Matrix4.identity()
                                    ..scale(isArabic ? -1.0 : 1.0, 1.0, 1.0),
                              child: ColorFiltered(
                                colorFilter: ColorFilter.mode(
                                  ColorRes.black.withValues(alpha: 0.5),
                                  // Adjust opacity for tint strength
                                  BlendMode
                                      .srcATop, // Combines the yellow tint with the blurred image
                                ),
                                child: Center(
                                  child: AssetsImg(
                                    imagePath: AssetRes.uploadBgIcon,
                                    height: 315,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          ///Profile Data
                          Stack(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: Constants.horizontalPadding,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ///Space
                                    40.ph.spaceVertical,

                                    /// Back button
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
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            color: ColorRes.primaryColor,
                                          ),
                                          child: Center(
                                            child: Transform.rotate(
                                              angle: isArabic ? 3.14159 : 0,
                                              // 180 degrees for Arabic
                                              child: SvgAsset(
                                                imagePath: AssetRes.leftIcon,
                                                color: ColorRes.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    19.ph.spaceVertical,

                                    /// Star rating and score
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
                                          style: styleW700S12.copyWith(
                                            color: ColorRes.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    10.ph.spaceVertical,

                                    /// Name
                                    Text(
                                      provider.profileData?.fullName ?? "",
                                      style: styleW700S24.copyWith(
                                        color: ColorRes.white,
                                      ),
                                    ),

                                    20.ph.spaceVertical,

                                    /// User details
                                    SizedBox(
                                      width: 130,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              SvgAsset(
                                                imagePath: AssetRes.userIcon2,
                                                width: 18,
                                                height: 18,
                                              ),
                                              8.pw.spaceHorizontal,
                                              Expanded(
                                                child: Text(
                                                  provider.profileData?.bio ??
                                                      "Hi ${provider.profileData?.fullName ?? ""}",
                                                  maxLines: 1,
                                                  style: styleW500S10.copyWith(
                                                    color: ColorRes.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          8.ph.spaceVertical,
                                          Row(
                                            children: [
                                              SvgAsset(
                                                imagePath: AssetRes.smsIcon,
                                                width: 18,
                                                height: 18,
                                              ),
                                              8.pw.spaceHorizontal,
                                              Expanded(
                                                child: Text(
                                                  provider.profileData?.email ??
                                                      "-",
                                                  style: styleW500S10.copyWith(
                                                    color: ColorRes.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          8.ph.spaceVertical,
                                          Row(
                                            children: [
                                              SvgAsset(
                                                imagePath: AssetRes.globalIcon,
                                                width: 18,
                                                height: 18,
                                              ),
                                              8.pw.spaceHorizontal,
                                              Text(
                                                provider.profileData?.website ??
                                                    "-",
                                                maxLines: 1,
                                                style: styleW500S10.copyWith(
                                                  color: ColorRes.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
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
                                top: 45,
                                child: Container(
                                  width: 170,
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 98,
                                        height: 98,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: ColorRes.white.withValues(
                                              alpha: 0.5,
                                            ),
                                            width: 3,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            50,
                                          ),
                                        ),
                                        padding: EdgeInsets.all(2),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            50,
                                          ),
                                          child: CachedImage(
                                            provider
                                                        .profileData
                                                        ?.profileImage !=
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
                                      15.ph.spaceVertical,
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
                                                        ?.followingCount
                                                        .toString() ??
                                                    "0.0",
                                                style: styleW700S16.copyWith(
                                                  color: ColorRes.white,
                                                ),
                                              ),
                                              Text(
                                                isArabic ? "متابع" : "Follower",
                                                style: styleW400S10.copyWith(
                                                  color: ColorRes.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              Text(
                                                provider.profileData?.ratingsAvg
                                                        .toString() ??
                                                    "",
                                                style: styleW700S16.copyWith(
                                                  color: ColorRes.white,
                                                ),
                                              ),
                                              Text(
                                                isArabic
                                                    ? "نقاط التقييم"
                                                    : "Rating Points",
                                                style: styleW400S10.copyWith(
                                                  color: ColorRes.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              Text(
                                                provider.profileData?.totalPosts
                                                        .toString() ??
                                                    "",
                                                style: styleW700S16.copyWith(
                                                  color: ColorRes.white,
                                                ),
                                              ),
                                              Text(
                                                isArabic ? "منشور" : "Post",
                                                style: styleW400S10.copyWith(
                                                  color: ColorRes.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      ///Follow & Message
                      Positioned(
                        right: isArabic ? null : 0,
                        left: isArabic ? 0 : null,
                        bottom: 0,
                        child: Container(
                          margin: const EdgeInsets.only(top: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              /// Custom Follow Button
                              Container(
                                width: 100.pw,
                                height: 45.ph,
                                decoration: BoxDecoration(
                                  color: ColorRes.primaryColor,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(15),
                                    onTap: () async {
                                      if (provider.isFollowing) {
                                        await provider.unfollowUserProfile(
                                          context,
                                        );
                                      } else {
                                        await provider.followUserProfile(
                                          context,
                                        );
                                      }
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SvgAsset(
                                          imagePath: AssetRes.userIcon2,
                                          width: 16,
                                          height: 16,
                                          color: ColorRes.white,
                                        ),
                                        SizedBox(width: 6.pw),
                                        provider.followLoader
                                            ? CircularProgressIndicator(
                                              color: ColorRes.white,
                                            )
                                            : Text(
                                              provider.isFollowing
                                                  ? context.l10n?.following ??
                                                      ""
                                                  : context.l10n?.follow ?? "",
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

                              /// Custom Message Button
                              Container(
                                width: 100.pw,
                                height: 45.ph,
                                decoration: BoxDecoration(
                                  color: ColorRes.primaryColor,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(15),
                                    onTap: () {
                                      provider.createChatRoom(context);

                                      // socketIoHelper.webSocketData(
                                      //     messageType: 'text',
                                      //     roomId: '${provider.postUserId}',
                                      //     text: chatTxtController.text);
                                      // Handle message action
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SvgAsset(
                                          imagePath: AssetRes.msgIcon,
                                          width: 16,
                                          height: 16,
                                          color: ColorRes.white,
                                        ),
                                        SizedBox(width: 6.pw),
                                        Text(
                                          context.l10n?.message ?? "",
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
                      ),
                    ],
                  ),

                  10.ph.spaceVertical,
                  // 25.ph.spaceVertical,
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(color: ColorRes.white),
                      child: CustomListView(
                        itemCount:
                            provider.loader
                                ? 0
                                : provider.postByUserResponse.length + 1,
                        onRefresh:
                            () => provider.getPostByUserAPI(resetData: true),
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
                            onRatingSubmitted: (val) {
                              print("Val========= ${val}");
                            },
                            post: provider.postByUserResponse[index],
                            onTap: () {},
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
