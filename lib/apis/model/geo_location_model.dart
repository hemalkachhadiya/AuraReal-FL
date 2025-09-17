class GeoLocation {
  final String? type;
  final List<double>? coordinates;

  GeoLocation({this.type, this.coordinates});

  GeoLocation copyWith({String? type, List<double>? coordinates}) =>
      GeoLocation(
        type: type ?? this.type,
        coordinates: coordinates ?? this.coordinates,
      );

  factory GeoLocation.fromJson(Map<String, dynamic> json) {
    return GeoLocation(
      type: json['type'] as String?,
      coordinates: (json['coordinates'] as List<dynamic>?)?.map((e) {
        if (e is num) return e.toDouble();
        return null; // Handle invalid values
      }).whereType<double>().toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'type': type, 'coordinates': coordinates};
  }
}