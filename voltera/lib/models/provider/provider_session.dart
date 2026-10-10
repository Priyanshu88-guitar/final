class ProviderSession {
  final String id;
  final String providerId;
  final String customerId;
  final String chargerId;
  final double energyDeliveredKwh;
  final double earnings;
  final String status;
  final DateTime startTime;

  const ProviderSession({
    required this.id,
    required this.providerId,
    required this.customerId,
    required this.chargerId,
    required this.energyDeliveredKwh,
    required this.earnings,
    required this.status,
    required this.startTime,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'providerId': providerId,
        'customerId': customerId,
        'chargerId': chargerId,
        'energyDeliveredKwh': energyDeliveredKwh,
        'earnings': earnings,
        'status': status,
        'startTime': startTime.toIso8601String(),
      };

  factory ProviderSession.fromJson(Map<String, dynamic> json) {
    return ProviderSession(
      id: json['id'] as String? ?? '',
      providerId: json['providerId'] as String? ?? '',
      customerId: json['customerId'] as String? ?? '',
      chargerId: json['chargerId'] as String? ?? '',
      energyDeliveredKwh: (json['energyDeliveredKwh'] as num?)?.toDouble() ?? 0.0,
      earnings: (json['earnings'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'active',
      startTime: json['startTime'] != null ? DateTime.parse(json['startTime']) : DateTime.now(),
    );
  }
}
