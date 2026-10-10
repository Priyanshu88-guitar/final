class Availability {
  final String chargerId;
  final bool isOnline;
  final String openingTime;
  final String closingTime;

  const Availability({
    required this.chargerId,
    required this.isOnline,
    required this.openingTime,
    required this.closingTime,
  });

  Map<String, dynamic> toJson() => {
        'chargerId': chargerId,
        'isOnline': isOnline,
        'openingTime': openingTime,
        'closingTime': closingTime,
      };

  factory Availability.fromJson(Map<String, dynamic> json) {
    return Availability(
      chargerId: json['chargerId'] as String? ?? '',
      isOnline: json['isOnline'] as bool? ?? false,
      openingTime: json['openingTime'] as String? ?? '00:00',
      closingTime: json['closingTime'] as String? ?? '23:59',
    );
  }
}
