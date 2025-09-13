import 'package:aura_real/app/app_provider.dart';
import 'package:aura_real/aura_real.dart';
import 'package:aura_real/screens/rating/rating_provider.dart';
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
      child: const _RatingScreenContent(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If navigated directly without provider, wrap with provider
    return ChangeNotifierProvider<RatingProvider>(
      create: (context) => RatingProvider(),
      child: const _RatingScreenContent(),
    );
  }
}

// Separate content widget that consumes the provider
class _RatingScreenContent extends StatelessWidget {
  const _RatingScreenContent({super.key});

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
                              color: Colors.black.withOpacity(0.4),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.4),
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

                      const SizedBox(height: 40),
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
    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          // Google Map with markers
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(37.7749, -122.4194), // San Francisco
              zoom: 12,
            ),
            markers: provider.markers,
            onMapCreated: provider.onMapCreated,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            buildingsEnabled: true,
            indoorViewEnabled: true,
            trafficEnabled: false,
            mapType: MapType.normal,
            // Custom map styling (optional)
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

          // Top Controls (Camera/Map toggle)
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
                          // Camera Tab
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
                              onTap: () {
                                provider.setMode('map');
                                // Don't flip if already on map
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

          // Floating Action Buttons (optional)
          Positioned(
            right: 16,
            bottom: 100,
            child: Column(
              children: [
                // My Location Button
                FloatingActionButton(
                  mini: true,
                  backgroundColor: Colors.white,
                  onPressed: () {
                    // Center map on user location
                    provider.mapController?.animateCamera(
                      CameraUpdate.newLatLng(
                        const LatLng(37.7749, -122.4194), // Your current location
                      ),
                    );
                  },
                  child: const Icon(
                    Icons.my_location,
                    color: ColorRes.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                // Zoom In Button
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
                // Zoom Out Button
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

          // Bottom user info overlay (shows selected user info)
          if (provider.selectedUser != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Profile Image
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: ColorRes.primaryColor,
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.network(
                          provider.selectedUser!.profileImage,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 60,
                              height: 60,
                              color: ColorRes.primaryColor.withOpacity(0.2),
                              child: const Icon(
                                Icons.person,
                                color: ColorRes.primaryColor,
                                size: 30,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // User Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            provider.selectedUser!.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${provider.selectedUser!.rating}/10',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Text(
                              //   '${provider.selectedUser!.age} years',
                              //   style: const TextStyle(
                              //     fontSize: 14,
                              //     color: Colors.black54,
                              //   ),
                              // ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Action Buttons
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // Navigate to profile
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorRes.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            minimumSize: const Size(80, 32),
                          ),
                          child: const Text(
                            'Profile',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                        const SizedBox(height: 4),
                        OutlinedButton(
                          onPressed: () {
                            // Start chat
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: ColorRes.primaryColor,
                            side: const BorderSide(color: ColorRes.primaryColor),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            minimumSize: const Size(80, 32),
                          ),
                          child: const Text(
                            'Chat',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
  // Widget _buildMapView(BuildContext context, RatingProvider provider) {
  //   return Container(
  //     color: Colors.white,
  //     child: Stack(
  //       children: [
  //         // Google Map
  //         const GoogleMap(
  //           initialCameraPosition: CameraPosition(
  //             target: LatLng(37.7749, -122.4194),
  //             zoom: 12,
  //           ),
  //         ),
  //
  //         // Top Controls (similar to camera view)
  //         Positioned(
  //           top: 40,
  //           left: 0,
  //           right: 0,
  //           child: Consumer<RatingProvider>(
  //             builder: (context, provider, child) {
  //               return Row(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   Container(
  //                     decoration: BoxDecoration(
  //                       color: ColorRes.lightBlue,
  //                       borderRadius: BorderRadius.circular(25),
  //                       border: Border.all(color: ColorRes.lightBlue),
  //                     ),
  //                     child: Row(
  //                       children: [
  //                         // Camera Tab
  //                         SizedBox(
  //                           width: 131,
  //                           height: 41,
  //                           child: SubmitButton(
  //                             title: context.l10n?.camera ?? "Camera",
  //                             onTap: () {
  //                               provider.setMode('camera');
  //                               provider.flipController.toggleCard();
  //                             },
  //                             style: styleW500S14.copyWith(
  //                               color: provider.getCameraTabTextColor(),
  //                             ),
  //                             bgColor: provider.getCameraTabBgColor(),
  //                             raduis: 10,
  //                           ),
  //                         ),
  //                         // Map Tab
  //                         SizedBox(
  //                           width: 131,
  //                           height: 41,
  //                           child: SubmitButton(
  //                             raduis: 10,
  //                             title: context.l10n?.map ?? "Map",
  //                             style: styleW500S14.copyWith(
  //                               color: provider.getMapTabTextColor(),
  //                             ),
  //                             onTap: () {
  //                               provider.setMode('map');
  //                               // Don't flip if already on map
  //                             },
  //                             bgColor: provider.getMapTabBgColor(),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ],
  //               );
  //             },
  //           ),
  //         ),
  //
  //         /// Back button at bottom
  //         // Positioned(
  //         //   bottom: 50,
  //         //   left: 0,
  //         //   right: 0,
  //         //   child: Center(
  //         //     child: Consumer<RatingProvider>(
  //         //       builder: (context, provider, child) {
  //         //         return ElevatedButton(
  //         //           onPressed: () {
  //         //             provider.setMode('camera');
  //         //             provider.flipController.toggleCard();
  //         //           },
  //         //           style: ElevatedButton.styleFrom(
  //         //             backgroundColor: ColorRes.primaryColor,
  //         //             foregroundColor: Colors.white,
  //         //             padding: const EdgeInsets.symmetric(
  //         //               horizontal: 30,
  //         //               vertical: 12,
  //         //             ),
  //         //             shape: RoundedRectangleBorder(
  //         //               borderRadius: BorderRadius.circular(25),
  //         //             ),
  //         //           ),
  //         //           child: const Text("Back to Camera"),
  //         //         );
  //         //       },
  //         //     ),
  //         //   ),
  //         // ),
  //       ],
  //     ),
  //   );
  // }
}
