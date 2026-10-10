class Charger {
  final String id;
  final String name;
  final String providerId;
  final String locationAddress;
  final double latitude;
  final double longitude;
  final String connectorType;
  final double powerKw;
  final double pricePerHour;
  final double pricePerKwh;
  final bool isAvailable;
  final double rating;

  const Charger({
    required this.id,
    required this.name,
    required this.providerId,
    required this.locationAddress,
    required this.latitude,
    required this.longitude,
    required this.connectorType,
    required this.powerKw,
    required this.pricePerHour,
    required this.pricePerKwh,
    required this.isAvailable,
    required this.rating,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'providerId': providerId,
        'locationAddress': locationAddress,
        'latitude': latitude,
        'longitude': longitude,
        'connectorType': connectorType,
        'powerKw': powerKw,
        'pricePerHour': pricePerHour,
        'pricePerKwh': pricePerKwh,
        'isAvailable': isAvailable,
        'rating': rating,
      };

  factory Charger.fromJson(Map<String, dynamic> json) {
    return Charger(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      providerId: json['providerId'] as String? ?? '',
      locationAddress: json['locationAddress'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      connectorType: json['connectorType'] as String? ?? '',
      powerKw: (json['powerKw'] as num?)?.toDouble() ?? 0.0,
      pricePerHour: (json['pricePerHour'] as num?)?.toDouble() ?? 0.0,
      pricePerKwh: (json['pricePerKwh'] as num?)?.toDouble() ?? 0.0,
      isAvailable: json['isAvailable'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
