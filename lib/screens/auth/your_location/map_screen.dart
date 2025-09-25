import 'package:aura_real/aura_real.dart';
import 'package:aura_real/screens/auth/your_location/map_screen_provider.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:map_location_picker/map_location_picker.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  static const routeName = "map_screen";

  static Widget builder(BuildContext context) {
    return ChangeNotifierProvider<MapScreenProvider>(
      create: (c) => MapScreenProvider(),
      child: const MapScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MapScreenProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          body: Stack(
            children: [
              if (provider.initialLocation != null)
                GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: CameraPosition(
                    target: provider.initialLocation!,
                    zoom: 14,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    provider.controller.complete(controller);
                  },
                  markers: provider.markers,
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  compassEnabled: false,
                  zoomControlsEnabled: false,
                  onTap: (LatLng latLng) {
                    provider.updateMapLocation(
                      latLng.latitude,
                      latLng.longitude,
                    );
                  },
                ),
              Positioned(
                top: 60,
                left: 20,
                right: 20,
                // child: Container(
                // decoration: BoxDecoration(
                //   color: Colors.white,
                //   borderRadius: BorderRadius.circular(10),
                //   boxShadow: [
                //     BoxShadow(
                //       color: Colors.black.withValues(alpha: 0.1),
                //       blurRadius: 10,
                //       spreadRadius: 2,
                //     ),
                //   ],
                // ),
                child: GooglePlaceAutoCompleteTextField(
                  textEditingController: provider.mapController,
                  googleAPIKey: provider.googleApiKey,
                  focusNode: provider.focusNode,
                  textInputAction: TextInputAction.done,
                  boxDecoration: BoxDecoration(),
                  inputDecoration: InputDecoration(
                    hintText: "Search places...",
                    filled: true,
                    fillColor: ColorRes.lightGrey2,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40.pw),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 20,
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: SvgAsset(
                        imagePath: AssetRes.searchIcon,
                        width: 18,
                        height: 18,
                      ),
                    ),
                  ),
                  debounceTime: 800,

                  // instead of 800
                  isLatLngRequired: true,
                  getPlaceDetailWithLatLng: (prediction) async {
                    if (prediction.lat != null && prediction.lng != null) {
                      double? lat = double.tryParse(prediction.lat.toString());
                      double? lng = double.tryParse(prediction.lng.toString());
                      if (lat != null && lng != null) {
                        provider.updateMapLocation(lat, lng);
                      }
                    }
                  },
                  itemClick: (prediction) {
                    SystemChannels.textInput.invokeMethod('TextInput.hide');
                    provider.focusNode.requestFocus();
                    provider.mapController.clear();

                    if (prediction.lat != null && prediction.lng != null) {
                      double? lat = double.tryParse(prediction.lat.toString());
                      double? lng = double.tryParse(prediction.lng.toString());
                      if (lat != null && lng != null) {
                        provider.updateMapLocation(lat, lng);
                      }
                    }
                  },
                ),
                // ),
              ),

              // Current Location Button
              // Positioned(
              //   bottom: 120,
              //   right: 20,
              //   child: FloatingActionButton(
              //     onPressed: _fetchAndSetCurrentLocation,
              //     backgroundColor: Colors.white,
              //     child: Icon(Icons.my_location, color: Colors.blue),
              //   ),
              // ),
              if (MediaQuery.of(context).viewInsets.bottom == 0)
                Positioned(
                  bottom: 40,
                  left: 20,
                  right: 20,
                  child: SubmitButton(
                    title: "Select",

                    onTap: () async {
                      debugPrint(
                        "SELECTED LOCATION:-${provider.selectedLocation}",
                      );
                      var address =
                          await GetLocationService.getAddressFromLatLng1(
                            location: provider.selectedLocation,
                          );
                      print("Selected Adders ==== ${address}");

                      await GetLocationService.getAddressFromLatLng1(
                        location: provider.selectedLocation,
                      );

                      if (context.mounted) {
                        if (provider.selectedLocation != null) {
                          PrefService.set(
                            PrefKeys.latitude,
                            provider.selectedLocation!.latitude,
                          );
                          PrefService.set(
                            PrefKeys.longitude,
                            provider.selectedLocation!.longitude,
                          );
                          PrefService.set(PrefKeys.location, address);
                          print("address===== ${address}");
                          // context.navigator.pushNamedAndRemoveUntil(
                          //   DashboardScreen.routeName,
                          //   (_) => false,
                          // );
                        } else {
                          context.navigator.pop(context);
                        }
                      }
                    },
                  ),

                  // ElevatedButton(
                  //   onPressed: () {
                  //     if (Navigator.canPop(context)) {
                  //       Navigator.pop(context, _selectedLocation);
                  //       if (widget.isEdit == 1) {
                  //       } else {
                  //         SpUtil.putDouble(
                  //           SpConstUtil.latitude,
                  //           _selectedLocation!.latitude,
                  //         );
                  //         SpUtil.putDouble(
                  //           SpConstUtil.longitude,
                  //           _selectedLocation!.longitude,
                  //         );

                  //         debugPrint(
                  //           'latitude : ${_selectedLocation!.latitude}',
                  //         );
                  //         debugPrint(
                  //           'longitude : ${_selectedLocation!.longitude}',
                  //         );
                  //       }
                  //     }
                  //   },
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor: themeColor.dune,
                  //     elevation: 0,
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(10),
                  //     ),
                  //   ),
                  //   child: text(
                  //     text: "Select",
                  //     fontSize: 16,
                  //     fontFamily: "LexendDeca-VariableFont_wght",
                  //     fontWeight: FontWeight.w600,
                  //     color: themeColor.white,
                  //   ),
                  // ),
                ),
            ],
          ),
        );
      },
    );
  }
}
