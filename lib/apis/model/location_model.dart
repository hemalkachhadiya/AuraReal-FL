class LocationModel {
  final String? userId;
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final bool? isCurrent;
  final String? id;
  final DateTime? createdAt;
  final int? v;

  LocationModel({
    this.userId,
    this.latitude,
    this.longitude,
    this.address,
    this.city,
    this.state,
    this.country,
    this.isCurrent,
    this.id,
    this.createdAt,
    this.v,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) => LocationModel(
    userId: json['user_id'] as String?,
    latitude: (json['latitude'] as num?)?.toDouble(),
    longitude: (json['longitude'] as num?)?.toDouble(),
    address: json['address'] as String?,
    city: json['city'] as String?,
    state: json['state'] as String?,
    country: json['country'] as String?,
    isCurrent: json['is_current'] as bool?,
    id: json['_id'] as String?,
    createdAt: json['created_at'] != null
        ? DateTime.tryParse(json['created_at'])
        : null,
    v: json['__v'] as int?,
  );

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'latitude': latitude,
    'longitude': longitude,
    'address': address,
    'city': city,
    'state': state,
    'country': country,
    'is_current': isCurrent,
    '_id': id,
    'created_at': createdAt?.toIso8601String(),
    '__v': v,
  };

  /// Convenient copyWith
  LocationModel copyWith({
    String? userId,
    double? latitude,
    double? longitude,
    String? address,
    String? city,
    String? state,
    String? country,
    bool? isCurrent,
    String? id,
    DateTime? createdAt,
    int? v,
  }) => LocationModel(
    userId: userId ?? this.userId,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    address: address ?? this.address,
    city: city ?? this.city,
    state: state ?? this.state,
    country: country ?? this.country,
    isCurrent: isCurrent ?? this.isCurrent,
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    v: v ?? this.v,
  );

  // Helper getters for safe access with default values
  String get safeUserId => userId ?? '';
  double get safeLatitude => latitude ?? 0.0;
  double get safeLongitude => longitude ?? 0.0;
  String get safeAddress => address ?? '';
  String get safeCity => city ?? '';
  String get safeState => state ?? '';
  String get safeCountry => country ?? '';
  bool get safeIsCurrent => isCurrent ?? false;
  String get safeId => id ?? '';
  DateTime get safeCreatedAt => createdAt ?? DateTime.now();
  int get safeV => v ?? 0;

  // Additional helper methods
  bool get hasCoordinates => latitude != null && longitude != null;

  String get formattedAddress {
    final parts = [address, city, state, country].where((part) => part != null && part.isNotEmpty).toList();
    return parts.join(', ');
  }

  // Method to check if location is valid (has coordinates and address)
  bool get isValid => hasCoordinates && (address?.isNotEmpty == true);
}