class AdminTransactionRecord {
  final String id;
  final String userName;
  final String userPhone;
  final String stationName;
  final String type; // CHARGING_SESSION, WALLET_RECHARGE, PROVIDER_PAYOUT
  final String method; // UPI, CREDIT_CARD, DEBIT_CARD, WALLET, NET_BANKING
  final String status; // COMPLETED, PENDING, FAILED, REFUNDED
  final double amount;
  final DateTime timestamp;
  final String referenceNumber;

  const AdminTransactionRecord({
    required this.id,
    required this.userName,
    this.userPhone = '+91 98765 43210',
    required this.stationName,
    required this.type,
    required this.method,
    required this.status,
    required this.amount,
    required this.timestamp,
    this.referenceNumber = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userName': userName,
        'userPhone': userPhone,
        'stationName': stationName,
        'type': type,
        'method': method,
        'status': status,
        'amount': amount,
        'timestamp': timestamp.toIso8601String(),
        'referenceNumber': referenceNumber,
      };

  factory AdminTransactionRecord.fromJson(Map<String, dynamic> json) {
    return AdminTransactionRecord(
      id: json['id'] as String? ?? '',
      userName: json['userName'] as String? ?? 'User',
      userPhone: json['userPhone'] as String? ?? '+91 98765 43210',
      stationName: json['stationName'] as String? ?? 'Voltera Station',
      type: json['type'] as String? ?? 'CHARGING_SESSION',
      method: json['method'] as String? ?? 'UPI',
      status: json['status'] as String? ?? 'COMPLETED',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : DateTime.now(),
      referenceNumber: json['referenceNumber'] as String? ?? 'REF-908123',
    );
  }
}
