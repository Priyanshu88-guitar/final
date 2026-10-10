class Payment {
  final String id;
  final String userId;
  final String sessionId;
  final double amount;
  final String currency;
  final String status;
  final DateTime timestamp;

  const Payment({
    required this.id,
    required this.userId,
    required this.sessionId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'sessionId': sessionId,
        'amount': amount,
        'currency': currency,
        'status': status,
        'timestamp': timestamp.toIso8601String(),
      };

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      sessionId: json['sessionId'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'USD',
      status: json['status'] as String? ?? 'pending',
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : DateTime.now(),
    );
  }
}
