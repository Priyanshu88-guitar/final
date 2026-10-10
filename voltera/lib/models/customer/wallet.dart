class Wallet {
  final String id;
  final String customerId;
  final double balance;
  final String currency;

  const Wallet({
    required this.id,
    required this.customerId,
    required this.balance,
    required this.currency,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerId': customerId,
        'balance': balance,
        'currency': currency,
      };

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'] as String? ?? '',
      customerId: json['customerId'] as String? ?? '',
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'USD',
    );
  }
}
