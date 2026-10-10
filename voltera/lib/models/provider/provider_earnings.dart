class ProviderEarnings {
  final String providerId;
  final double totalEarnings;
  final double pendingPayout;
  final String currency;

  const ProviderEarnings({
    required this.providerId,
    required this.totalEarnings,
    required this.pendingPayout,
    required this.currency,
  });

  Map<String, dynamic> toJson() => {
        'providerId': providerId,
        'totalEarnings': totalEarnings,
        'pendingPayout': pendingPayout,
        'currency': currency,
      };

  factory ProviderEarnings.fromJson(Map<String, dynamic> json) {
    return ProviderEarnings(
      providerId: json['providerId'] as String? ?? '',
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0.0,
      pendingPayout: (json['pendingPayout'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'USD',
    );
  }
}
