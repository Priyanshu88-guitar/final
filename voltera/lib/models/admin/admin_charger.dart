class AdminCharger {
  final String id;
  final String name;
  final String stationName;
  final String providerId;
  final String providerName;
  final String location;
  final String connectorType;
  final String powerKw;
  final String pricePerKwh;
  final String verificationStatus; // APPROVED, PENDING, REJECTED
  final String status; // ACTIVE, MAINTENANCE, PENDING, REPORTED
  final bool isEnabled;
  final int totalSessions;
  final double rating;

  const AdminCharger({
    required this.id,
    required this.name,
    this.stationName = '',
    required this.providerId,
    this.providerName = '',
    this.location = '',
    this.connectorType = 'CCS2',
    this.powerKw = '60 kW',
    this.pricePerKwh = '₹18/kWh',
    required this.verificationStatus,
    required this.isEnabled,
    this.status = 'ACTIVE',
    this.totalSessions = 0,
    this.rating = 4.5,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'stationName': stationName,
        'providerId': providerId,
        'providerName': providerName,
        'location': location,
        'connectorType': connectorType,
        'powerKw': powerKw,
        'pricePerKwh': pricePerKwh,
        'verificationStatus': verificationStatus,
        'isEnabled': isEnabled,
        'status': status,
        'totalSessions': totalSessions,
        'rating': rating,
      };

  factory AdminCharger.fromJson(Map<String, dynamic> json) {
    return AdminCharger(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Charger',
      stationName: json['stationName'] as String? ?? json['name'] as String? ?? 'Charging Station',
      providerId: json['providerId'] as String? ?? '',
      providerName: json['providerName'] as String? ?? 'Voltera Provider',
      location: json['location'] as String? ?? json['address'] as String? ?? 'Ahmedabad',
      connectorType: json['connectorType'] as String? ?? 'CCS2',
      powerKw: json['powerKw'] as String? ?? '60 kW',
      pricePerKwh: json['pricePerKwh'] as String? ?? '₹18/kWh',
      verificationStatus: json['verificationStatus'] as String? ?? 'APPROVED',
      isEnabled: json['isEnabled'] as bool? ?? true,
      status: json['status'] as String? ?? 'ACTIVE',
      totalSessions: json['totalSessions'] as int? ?? 150,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.7,
    );
  }
}
