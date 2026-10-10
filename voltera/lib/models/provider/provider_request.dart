class ProviderRequest {
  final String id;
  final String providerId;
  final String customerId;
  final String chargerId;
  final String status;
  final DateTime requestedAt;

  const ProviderRequest({
    required this.id,
    required this.providerId,
    required this.customerId,
    required this.chargerId,
    required this.status,
    required this.requestedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'providerId': providerId,
        'customerId': customerId,
        'chargerId': chargerId,
        'status': status,
        'requestedAt': requestedAt.toIso8601String(),
      };

  factory ProviderRequest.fromJson(Map<String, dynamic> json) {
    return ProviderRequest(
      id: json['id'] as String? ?? '',
      providerId: json['providerId'] as String? ?? '',
      customerId: json['customerId'] as String? ?? '',
      chargerId: json['chargerId'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      requestedAt: json['requestedAt'] != null ? DateTime.parse(json['requestedAt']) : DateTime.now(),
    );
  }
}
