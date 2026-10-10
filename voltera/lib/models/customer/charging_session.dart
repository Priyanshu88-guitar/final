class ChargingSession {
  final String id;
  final String bookingId;
  final String customerId;
  final String chargerId;
  final double energyConsumedKwh;
  final double currentPowerKw;
  final int durationMinutes;
  final String status;
  final double totalCost;

  const ChargingSession({
    required this.id,
    required this.bookingId,
    required this.customerId,
    required this.chargerId,
    required this.energyConsumedKwh,
    required this.currentPowerKw,
    required this.durationMinutes,
    required this.status,
    required this.totalCost,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'bookingId': bookingId,
        'customerId': customerId,
        'chargerId': chargerId,
        'energyConsumedKwh': energyConsumedKwh,
        'currentPowerKw': currentPowerKw,
        'durationMinutes': durationMinutes,
        'status': status,
        'totalCost': totalCost,
      };

  factory ChargingSession.fromJson(Map<String, dynamic> json) {
    return ChargingSession(
      id: json['id'] as String? ?? '',
      bookingId: json['bookingId'] as String? ?? '',
      customerId: json['customerId'] as String? ?? '',
      chargerId: json['chargerId'] as String? ?? '',
      energyConsumedKwh: (json['energyConsumedKwh'] as num?)?.toDouble() ?? 0.0,
      currentPowerKw: (json['currentPowerKw'] as num?)?.toDouble() ?? 0.0,
      durationMinutes: json['durationMinutes'] as int? ?? 0,
      status: json['status'] as String? ?? 'active',
      totalCost: (json['totalCost'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
