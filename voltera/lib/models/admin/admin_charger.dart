class AdminCharger {
  final String id;
  final String name;
  final String providerId;
  final String verificationStatus;
  final bool isEnabled;

  const AdminCharger({
    required this.id,
    required this.name,
    required this.providerId,
    required this.verificationStatus,
    required this.isEnabled,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'providerId': providerId,
        'verificationStatus': verificationStatus,
        'isEnabled': isEnabled,
      };

  factory AdminCharger.fromJson(Map<String, dynamic> json) {
    return AdminCharger(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      providerId: json['providerId'] as String? ?? '',
      verificationStatus: json['verificationStatus'] as String? ?? 'pending',
      isEnabled: json['isEnabled'] as bool? ?? false,
    );
  }
}
