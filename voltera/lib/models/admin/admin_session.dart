class AdminSessionRecord {
  final String id;
  final String customerId;
  final String providerId;
  final String chargerId;
  final String status;
  final DateTime startTime;

  const AdminSessionRecord({
    required this.id,
    required this.customerId,
    required this.providerId,
    required this.chargerId,
    required this.status,
    required this.startTime,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerId': customerId,
        'providerId': providerId,
        'chargerId': chargerId,
        'status': status,
        'startTime': startTime.toIso8601String(),
      };

  factory AdminSessionRecord.fromJson(Map<String, dynamic> json) {
    return AdminSessionRecord(
      id: json['id'] as String? ?? '',
      customerId: json['customerId'] as String? ?? '',
      providerId: json['providerId'] as String? ?? '',
      chargerId: json['chargerId'] as String? ?? '',
      status: json['status'] as String? ?? 'active',
      startTime: json['startTime'] != null ? DateTime.parse(json['startTime']) : DateTime.now(),
    );
  }
}
