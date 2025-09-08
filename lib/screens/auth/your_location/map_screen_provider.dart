import 'dart:async';
import 'package:flutter/material.dart';
import 'package:map_location_picker/map_location_picker.dart';

class MapScreenProvider extends ChangeNotifier {
  MapScreenProvider() {
    _loadInitialLocation();
  }

  final Completer<GoogleMapController> controller =
      Completer<GoogleMapController>();
  final TextEditingController mapController = TextEditingController();

  final FocusNode focusNode = FocusNode();

  LatLng? initialLocation;
  LatLng? selectedLocation;
  final String googleApiKey = "AIzaSyAEp1bymEbwslNks5rrCgtFKXrcOvAp_O0";

  final Set<Marker> markers = {};

  Future<void> _loadInitialLocation() async {
    initialLocation = const LatLng(21.1702, 72.8311); // Surat, India
    print("✅ Loading initial location: $initialLocation");

    markers.add(
      Marker(
        markerId: const MarkerId("initial_location"),
        position: initialLocation!,
        infoWindow: const InfoWindow(title: "Initial Location"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );

    notifyListeners();
  }

  Future<void> updateMapLocation(double lat, double lng) async {
    LatLng newPosition = LatLng(lat, lng);

    selectedLocation = newPosition;

    markers.removeWhere(
      (marker) => marker.markerId.value == "selected_location",
    );

    markers.add(
      Marker(
        markerId: const MarkerId("selected_location"),
        position: newPosition,
        infoWindow: const InfoWindow(title: "Selected Location"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );

    final GoogleMapController controllerN = await controller.future;
    controllerN.animateCamera(CameraUpdate.newLatLngZoom(newPosition, 15));

    notifyListeners();
  }
}
