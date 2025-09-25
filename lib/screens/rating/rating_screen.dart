import 'package:aura_real/aura_real.dart';
import 'package:aura_real/screens/rating/widget/user_profile_rating_widget.dart';
import 'package:flip_card/flip_card.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RatingScreen extends StatelessWidget {
  const RatingScreen({super.key});

  static const routeName = "rating_screen";

  static Widget builder(BuildContext context) {
    return ChangeNotifierProvider<RatingProvider>(
      create: (context) => RatingProvider(),
      child: _RatingScreenContent(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RatingProvider>(
      create: (context) => RatingProvider(),
      child: _RatingScreenContent(),
    );
  }
}

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

  /// Camera Screen (unchanged)
  Widget _buildCameraView(
      BuildContext context,
      RatingProvider provider,
      bool? isArabic,
      ) {
    // your camera screen code remains same...
    return Container(); // trimmed to focus on map view
  }

  /// Map Screen
  Widget _buildMapView(BuildContext context, RatingProvider provider) {
    return FutureBuilder<LatLng?>(
      future: provider.getCurrentLocation(),
      builder: (context, snapshot) {
        var latitude = PrefService.getDouble(PrefKeys.latitude);
        var longitude = PrefService.getDouble(PrefKeys.longitude);
        LatLng initialPosition = LatLng(latitude, longitude);

        Set<Circle> circles = {};
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData &&
            snapshot.data != null) {
          initialPosition = snapshot.data!;
          circles.add(
            Circle(
              circleId: const CircleId('user_location'),
              center: initialPosition,
              radius: 100, // small circle
              fillColor: Colors.blue.withValues(alpha: 0.2),
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
                  markers: provider.markers, // profile markers with images
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
                ),

                /// Top user count
                Positioned(
                  left: Constants.horizontalPadding,
                  top: 15,
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      "${provider.users.length} users loaded",
                      style:
                      styleW400S12.copyWith(color: ColorRes.primaryColor),
                    ),
                  ),
                ),

                /// Camera / Map toggle
                Positioned(
                  top: 40,
                  left: 0,
                  right: 0,
                  child: _buildMapCameraToggle(context, provider),
                ),

                /// Floating buttons
                Positioned(
                  left: Constants.horizontalPadding,
                  top: 100,
                  child: _buildFloatingButtons(provider),
                ),

                /// Profile bottom card
                if (provider.selectedUser != null)
                  Positioned(
                    bottom: 80,
                    left: 0,
                    right: 0,
                    child: UserProfileRatingWidget(
                      user: provider.selectedUser,
                      onPrivateChat: () {
                        print("Private Chat clicked");
                      },
                      onVisitProfile: () {
                        print(
                            "Visit Profile: ${provider.selectedUser?.fullName}");
                      },
                      onRate: () {
                        openCustomDialog(
                          context,
                          borderRadius: 30,
                          title: "Send Rating",
                          customChild: Column(
                            children: [
                              StarRatingWidget(
                                onRatingChanged: (rate) {
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
                                title: "Send",
                                onTap: () {
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

  Widget _buildMapCameraToggle(
      BuildContext context, RatingProvider provider) {
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
                  title: "Camera",
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
                  title: "Map",
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
  }

  Widget _buildFloatingButtons(RatingProvider provider) {
    return Column(
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
          child: const Icon(Icons.my_location, color: ColorRes.primaryColor),
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          mini: true,
          backgroundColor: Colors.white,
          onPressed: () {
            provider.mapController?.animateCamera(CameraUpdate.zoomIn());
          },
          child: const Icon(Icons.add, color: ColorRes.primaryColor),
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          mini: true,
          backgroundColor: Colors.white,
          onPressed: () {
            provider.mapController?.animateCamera(CameraUpdate.zoomOut());
          },
          child: const Icon(Icons.remove, color: ColorRes.primaryColor),
        ),
      ],
    );
  }
}
