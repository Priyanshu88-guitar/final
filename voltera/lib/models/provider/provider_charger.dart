class ProviderCharger {
  final String id;
  final String providerId;
  final String name;
  final String status;
  final double powerKw;
  final double pricePerKwh;

  const ProviderCharger({
    required this.id,
    required this.providerId,
    required this.name,
    required this.status,
    required this.powerKw,
    required this.pricePerKwh,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'providerId': providerId,
        'name': name,
        'status': status,
        'powerKw': powerKw,
        'pricePerKwh': pricePerKwh,
      };

  factory ProviderCharger.fromJson(Map<String, dynamic> json) {
    return ProviderCharger(
      id: json['id'] as String? ?? '',
      providerId: json['providerId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      status: json['status'] as String? ?? 'active',
      powerKw: (json['powerKw'] as num?)?.toDouble() ?? 0.0,
      pricePerKwh: (json['pricePerKwh'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
