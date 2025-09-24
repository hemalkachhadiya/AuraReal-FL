import 'package:map_location_picker/map_location_picker.dart';
// User model for map markers
class UserMarkerData {
  final String id;
  final String name;
  final String profileImage;
  final double rating;
  final LatLng position;
  final int age;

  UserMarkerData({
    required this.id,
    required this.name,
    required this.profileImage,
    required this.rating,
    required this.position,
    required this.age,
  });
}