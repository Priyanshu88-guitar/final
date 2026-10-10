class Booking {
  final String id;
  final String customerId;
  final String chargerId;
  final DateTime startTime;
  final DateTime endTime;
  final String status;
  final double estimatedCost;

  const Booking({
    required this.id,
    required this.customerId,
    required this.chargerId,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.estimatedCost,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerId': customerId,
        'chargerId': chargerId,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'status': status,
        'estimatedCost': estimatedCost,
      };

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String? ?? '',
      customerId: json['customerId'] as String? ?? '',
      chargerId: json['chargerId'] as String? ?? '',
      startTime: json['startTime'] != null ? DateTime.parse(json['startTime']) : DateTime.now(),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : DateTime.now(),
      status: json['status'] as String? ?? 'pending',
      estimatedCost: (json['estimatedCost'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
