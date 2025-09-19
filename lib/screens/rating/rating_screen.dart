import 'package:aura_real/app/app_provider.dart';
import 'package:aura_real/aura_real.dart';
import 'package:aura_real/screens/rating/rating_provider.dart';
import 'package:aura_real/screens/rating/widget/user_profile_rating_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flip_card/flip_card.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RatingScreen extends StatelessWidget {
  const RatingScreen({super.key});

  static const routeName = "rating_screen";

  // This is the correct way to provide the RatingProvider
  static Widget builder(BuildContext context) {
    return ChangeNotifierProvider<RatingProvider>(
      create: (context) => RatingProvider(),
      child: _RatingScreenContent(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If navigated directly without provider, wrap with provider
    return ChangeNotifierProvider<RatingProvider>(
      create: (context) => RatingProvider(),
      child: _RatingScreenContent(),
    );
  }
}

// Separate content widget that consumes the provider
class _RatingScreenContent extends StatelessWidget {
  _RatingScreenContent({super.key});

  var newRateVal;

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context, listen: true);
    final isArabic = appProvider.locale?.languageCode == 'ar';

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: Consumer<RatingProvider>(
            builder: (context, provider, child) {
              return FlipCard(
                direction: FlipDirection.HORIZONTAL,
                flipOnTouch: false,
                controller: provider.flipController,
                front: _buildCameraView(context, provider, isArabic),
                back: _buildMapView(context, provider),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCameraView(
    BuildContext context,
    RatingProvider provider,
    bool? isArabic,
  ) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: SvgAsset(imagePath: AssetRes.ratingImg, fit: BoxFit.cover),
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
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ),

          // Main Content
          Positioned.fill(
            child: Column(
              children: [
                // Top spacing
                const SizedBox(height: 40),

                ///Camera and Map Flip Button Toggle
                Consumer<RatingProvider>(
                  builder: (context, provider, child) {
                    return Row(
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
                                width: 131,
                                height: 41,
                                child: SubmitButton(
                                  title: context.l10n?.camera ?? "Camera",
                                  onTap: provider.showCamera /*() {
                                    provider.setMode('camera');

                                    if (provider.isMapSelected) {
                                      provider.flipController.toggleCard();
                                    }
                                  }*/,
                                  style: styleW500S14.copyWith(
                                    color: provider.getCameraTabTextColor(),
                                  ),
                                  bgColor: provider.getCameraTabBgColor(),
                                  raduis: 10,
                                ),
                              ),
                              // Map Tab
                              SizedBox(
                                width: 131,
                                height: 41,
                                child: SubmitButton(
                                  raduis: 10,
                                  title: context.l10n?.map ?? "Map",
                                  style: styleW500S14.copyWith(
                                    color: provider.getMapTabTextColor(),
                                  ),
                                  onTap: provider.showMap /*() {
                                    provider.setMode('map');
                                    if (provider.isCameraSelected) {
                                      provider.flipController.toggleCard();
                                    }
                                  }*/,
                                  bgColor: provider.getMapTabBgColor(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),

                // Spacer to push content to bottom
                const Spacer(),

                // Profile Info Section
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Column(
                    children: [
                      // Name and Action Buttons Row
                      Row(
                        children: [
                          // Profile Info
                          Expanded(
                            flex: 2,
                            child: InkWell(
                              onTap: () {
                                openCustomDialog(
                                  context,
                                  borderRadius: 30,
                                  title:
                                      context.l10n?.sendRating ?? "Send Rating",
                                  customChild: StarRatingWidget(
                                    rating: 5,
                                    activeColor: ColorRes.primaryColor,
                                    inactiveColor: ColorRes.primaryColor,
                                    size: 37,
                                  ),
                                  confirmBtnTitle: context.l10n?.send ?? "Send",
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: ColorRes.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 15,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isArabic!
                                          ? "كادين شلايفر"
                                          : "Kadin Schleifer",
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      style: styleW700S20.copyWith(
                                        color: ColorRes.white,
                                      ),
                                    ),
                                    const SizedBox(height: 9),
                                    // Rating Section
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          "(8.84/10)",
                                          style: styleW700S12.copyWith(
                                            color: ColorRes.white,
                                          ),
                                        ),
                                        6.pw.spaceHorizontal,
                                        StarRatingWidget(
                                          rating: 4.5,
                                          size: 10,
                                          space: 8,
                                          activeColor: ColorRes.yellowColor,
                                          inactiveColor: ColorRes.yellowColor,
                                        ),
                                        6.pw.spaceHorizontal,
                                        Text(
                                          "00",
                                          style: styleW700S12.copyWith(
                                            color: ColorRes.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    // Rate Button
                                    SizedBox(
                                      width: 80,
                                      child: SubmitButton(
                                        title: context.l10n?.rate ?? "Rate",
                                        height: 28,
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

                          15.pw.spaceHorizontal,

                          // Action Buttons
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                SizedBox(
                                  width: 120,
                                  child: SubmitButton2(
                                    raduis: 15,
                                    height: 45,
                                    title:
                                        context.l10n?.profileVisit ??
                                        "Visit Profile",
                                    onTap: () {},
                                    icon: AssetRes.userIcon2,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: 120,
                                  child: SubmitButton2(
                                    height: 45,
                                    raduis: 15,
                                    title:
                                        context.l10n?.privateChat ??
                                        "Private Chat",
                                    onTap: () {},
                                    icon: AssetRes.msgIcon,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      // Bottom Control Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Lightning Button
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.4),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.4),
                              ),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(19),
                              child: SvgAsset(
                                imagePath: AssetRes.flashIcon,
                                width: 19,
                                height: 19,
                              ),
                            ),
                          ),

                          // Camera Button
                          Consumer<RatingProvider>(
                            builder: (context, provider, child) {
                              return InkWell(
                                onTap: () async {
                                  await checkCameraPermission(context);
                                  if (context.mounted) {
                                    provider.openCamera(context);
                                  }
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
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: ColorRes.primaryColor,
                                    size: 30,
                                  ),
                                ),
                              );
                            },
                          ),

                          // Gallery Button
                          Consumer<RatingProvider>(
                            builder: (context, provider, child) {
                              return InkWell(
                                onTap: () {
                                  provider.openGallery(context);
                                },
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                    ),
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.all(19),
                                    child: SvgAsset(
                                      imagePath: AssetRes.cameraIcon3,
                                      width: 19,
                                      height: 19,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      90.ph.spaceVertical,
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapView(BuildContext context, RatingProvider provider) {
    return FutureBuilder<LatLng?>(
      future: provider.getCurrentLocation(),
      builder: (context, snapshot) {
        LatLng initialPosition = const LatLng(
          37.7749,
          -122.4194,
        ); // Fallback: San Francisco
        Set<Circle> circles = {};

        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData &&
            snapshot.data != null) {
          initialPosition = snapshot.data!;
          circles.add(
            Circle(
              circleId: const CircleId('user_location'),
              center: initialPosition,
              radius: 16093.4,
              // 10 miles in meters
              fillColor: Colors.blue.withOpacity(0.2),
              strokeColor: Colors.blue,
              strokeWidth: 2,
            ),
          );
        }

        return StackedLoader(
          loading: provider.loader,
          child: Container(
            color: Colors.white,
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: initialPosition,
                    zoom: 12,
                  ),
                  markers: provider.markers,
                  circles: circles,
                  onMapCreated: provider.onMapCreated,
                  myLocationEnabled: true,

                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  buildingsEnabled: true,
                  indoorViewEnabled: true,
                  trafficEnabled: false,
                  mapType: MapType.normal,
                  style: '''
              [
                {
                  "elementType": "geometry",
                  "stylers": [
                    {
                      "color": "#f5f5f5"
                    }
                  ]
                },
                {
                  "elementType": "labels.icon",
                  "stylers": [
                    {
                      "visibility": "off"
                    }
                  ]
                },
                {
                  "elementType": "labels.text.fill",
                  "stylers": [
                    {
                      "color": "#616161"
                    }
                  ]
                },
                {
                  "elementType": "labels.text.stroke",
                  "stylers": [
                    {
                      "color": "#f5f5f5"
                    }
                  ]
                },
                {
                  "featureType": "water",
                  "elementType": "geometry",
                  "stylers": [
                    {
                      "color": "#c9c9c9"
                    }
                  ]
                }
              ]
              ''',
                ),
                ...provider.mapOverlays, // Add cust
                // om overlays
                ///Camera and Map
                Positioned(
                  top: 40,
                  left: 0,
                  right: 0,
                  child: Consumer<RatingProvider>(
                    builder: (context, provider, child) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: ColorRes.lightBlue,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(color: ColorRes.lightBlue),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 131,
                                  height: 41,
                                  child: SubmitButton(
                                    title: context.l10n?.camera ?? "Camera",
                                    onTap: () {
                                      provider.setMode('camera');
                                      provider.flipController.toggleCard();
                                    },
                                    style: styleW500S14.copyWith(
                                      color: provider.getCameraTabTextColor(),
                                    ),
                                    bgColor: provider.getCameraTabBgColor(),
                                    raduis: 10,
                                  ),
                                ),
                                SizedBox(
                                  width: 131,
                                  height: 41,
                                  child: SubmitButton(
                                    raduis: 10,
                                    title: context.l10n?.map ?? "Map",
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
                      );
                    },
                  ),
                ),

                ///Floating button
                Positioned(
                  left: Constants.horizontalPadding,
                  top: 100,
                  child: Column(
                    children: [
                      FloatingActionButton(
                        mini: true,
                        backgroundColor: Colors.white,
                        onPressed: () async {
                          final location = await provider.getCurrentLocation();
                          if (location != null) {
                            provider.mapController?.animateCamera(
                              CameraUpdate.newLatLng(location),
                            );
                          }
                        },
                        child: const Icon(
                          Icons.my_location,
                          color: ColorRes.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton(
                        mini: true,
                        backgroundColor: Colors.white,
                        onPressed: () {
                          provider.mapController?.animateCamera(
                            CameraUpdate.zoomIn(),
                          );
                        },
                        child: const Icon(
                          Icons.add,
                          color: ColorRes.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton(
                        mini: true,
                        backgroundColor: Colors.white,
                        onPressed: () {
                          provider.mapController?.animateCamera(
                            CameraUpdate.zoomOut(),
                          );
                        },
                        child: const Icon(
                          Icons.remove,
                          color: ColorRes.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),

                ///Profile Rating
                if (provider.selectedUser != null)
                  Positioned(
                    bottom:80,
                    left: 0,
                    right: 0,
                    child: UserProfileRatingWidget(
                      user: provider.selectedUser,

                      onPrivateChat: () {
                        print("On Private Chat");
                      },
                      onVisitProfile: () {
                        print(
                          "Selected User ------- ${provider.selectedUser?.fullName}",
                        );
                        // context.navigator.pushNamed(
                        //   UploadScreen.routeName,
                        //   arguments: provider.selectedUser,
                        // );

                        print("On Visit Profile");
                      },
                      onRate: () {
                        print("On Rate");
                        openCustomDialog(
                          context,
                          borderRadius: 30,
                          title: context.l10n?.sendRating ?? "Send Rating",
                          customChild: Column(
                            children: [
                              StarRatingWidget(
                                onRatingChanged: (rate) {
                                  ///New Rate
                                  newRateVal = rate;
                                },
                                rating: 5,
                                activeColor: ColorRes.primaryColor,
                                inactiveColor: ColorRes.primaryColor,
                                size: 37,
                              ),

                              35.ph.spaceVertical,
                              SubmitButton(
                                height: 45.ph,
                                loading: provider.rateLoader,
                                title: context.l10n?.send ?? "Send",
                                onTap: () {
                                  print(
                                    "Default Rate value ---- ${(provider.selectedUser?.profile?.ratingsAvg?.toStarCount())}",
                                  );

                                  var rating = DoubleRatingExtension(
                                    newRateVal,
                                  ).toStars().toRawRating().toStringAsFixed(0);
                                  print("New Rate value ------- ${rating}");

                                  if (provider.selectedUser?.profile?.ratingsAvg
                                          ?.toStarCount() ==
                                      0) {
                                    provider.newRatePostAPI(
                                      context,
                                      postId: provider.selectedUser?.id,
                                      rating: rating.toString(),
                                    );
                                  } else {
                                    provider.updateRatePostAPI(
                                      context,
                                      postId: provider.selectedUser?.id,
                                      rating: rating.toString(),
                                    );
                                  }
                                  context.navigator.pop();
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
