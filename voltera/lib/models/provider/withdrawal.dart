class Withdrawal {
  final String id;
  final String providerId;
  final double amount;
  final String status;
  final DateTime requestedAt;

  const Withdrawal({
    required this.id,
    required this.providerId,
    required this.amount,
    required this.status,
    required this.requestedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'providerId': providerId,
        'amount': amount,
        'status': status,
        'requestedAt': requestedAt.toIso8601String(),
      };

  factory Withdrawal.fromJson(Map<String, dynamic> json) {
    return Withdrawal(
      id: json['id'] as String? ?? '',
      providerId: json['providerId'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'pending',
      requestedAt: json['requestedAt'] != null ? DateTime.parse(json['requestedAt']) : DateTime.now(),
    );
  }
}
