class AdminRevenue {
  final double grossRevenue;
  final double commissionEarned;
  final double providerPayouts;
  final double pendingPayouts;
  final int completedTxnsCount;
  final int pendingTxnsCount;
  final int failedTxnsCount;
  final String currency;

  const AdminRevenue({
    required this.grossRevenue,
    required this.commissionEarned,
    required this.providerPayouts,
    this.pendingPayouts = 3080450.0,
    this.completedTxnsCount = 151200,
    this.pendingTxnsCount = 4150,
    this.failedTxnsCount = 5220,
    required this.currency,
  });

  Map<String, dynamic> toJson() => {
        'grossRevenue': grossRevenue,
        'commissionEarned': commissionEarned,
        'providerPayouts': providerPayouts,
        'pendingPayouts': pendingPayouts,
        'completedTxnsCount': completedTxnsCount,
        'pendingTxnsCount': pendingTxnsCount,
        'failedTxnsCount': failedTxnsCount,
        'currency': currency,
      };

  factory AdminRevenue.fromJson(Map<String, dynamic> json) {
    return AdminRevenue(
      grossRevenue: (json['grossRevenue'] as num?)?.toDouble() ?? 48290500.0,
      commissionEarned: (json['commissionEarned'] as num?)?.toDouble() ?? 4829050.0,
      providerPayouts: (json['providerPayouts'] as num?)?.toDouble() ?? 40381000.0,
      pendingPayouts: (json['pendingPayouts'] as num?)?.toDouble() ?? 3080450.0,
      completedTxnsCount: json['completedTxnsCount'] as int? ?? 151200,
      pendingTxnsCount: json['pendingTxnsCount'] as int? ?? 4150,
      failedTxnsCount: json['failedTxnsCount'] as int? ?? 5220,
      currency: json['currency'] as String? ?? 'INR',
    );
  }
}
