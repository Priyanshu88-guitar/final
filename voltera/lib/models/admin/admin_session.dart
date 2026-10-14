class AdminSessionRecord {
  final String id;
  final String customerId;
  final String customerName;
  final String providerId;
  final String providerName;
  final String stationName;
  final String chargerId;
  final String status; // COMPLETED, ACTIVE, PENDING, FAILED, CANCELLED
  final String duration;
  final String energyKwh;
  final double cost;
  final DateTime startTime;

  const AdminSessionRecord({
    required this.id,
    required this.customerId,
    this.customerName = 'Rahul Sharma',
    required this.providerId,
    this.providerName = 'Amit Patel',
    this.stationName = 'Voltera SG Highway',
    required this.chargerId,
    required this.status,
    this.duration = '45 min',
    this.energyKwh = '18.4 kWh',
    this.cost = 330.0,
    required this.startTime,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerId': customerId,
        'customerName': customerName,
        'providerId': providerId,
        'providerName': providerName,
        'stationName': stationName,
        'chargerId': chargerId,
        'status': status,
        'duration': duration,
        'energyKwh': energyKwh,
        'cost': cost,
        'startTime': startTime.toIso8601String(),
      };

  factory AdminSessionRecord.fromJson(Map<String, dynamic> json) {
    return AdminSessionRecord(
      id: json['id'] as String? ?? '',
      customerId: json['customerId'] as String? ?? '',
      customerName: json['customerName'] as String? ?? 'Customer User',
      providerId: json['providerId'] as String? ?? '',
      providerName: json['providerName'] as String? ?? 'EV Station Owner',
      stationName: json['stationName'] as String? ?? 'Green Charge Hub',
      chargerId: json['chargerId'] as String? ?? '',
      status: json['status'] as String? ?? 'COMPLETED',
      duration: json['duration'] as String? ?? '45 min',
      energyKwh: json['energyKwh'] as String? ?? '18.5 kWh',
      cost: (json['cost'] as num?)?.toDouble() ?? 320.0,
      startTime: json['startTime'] != null ? DateTime.parse(json['startTime']) : DateTime.now(),
    );
  }
}
