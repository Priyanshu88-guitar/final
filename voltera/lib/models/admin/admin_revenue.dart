class AdminRevenue {
  final double grossRevenue;
  final double commissionEarned;
  final double providerPayouts;
  final String currency;

  const AdminRevenue({
    required this.grossRevenue,
    required this.commissionEarned,
    required this.providerPayouts,
    required this.currency,
  });

  Map<String, dynamic> toJson() => {
        'grossRevenue': grossRevenue,
        'commissionEarned': commissionEarned,
        'providerPayouts': providerPayouts,
        'currency': currency,
      };

  factory AdminRevenue.fromJson(Map<String, dynamic> json) {
    return AdminRevenue(
      grossRevenue: (json['grossRevenue'] as num?)?.toDouble() ?? 0.0,
      commissionEarned: (json['commissionEarned'] as num?)?.toDouble() ?? 0.0,
      providerPayouts: (json['providerPayouts'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'USD',
    );
  }
}
