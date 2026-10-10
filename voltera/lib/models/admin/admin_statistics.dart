class AdminStatistics {
  final int totalUsers;
  final int totalProviders;
  final int totalChargers;
  final int activeSessions;
  final double totalRevenue;

  const AdminStatistics({
    required this.totalUsers,
    required this.totalProviders,
    required this.totalChargers,
    required this.activeSessions,
    required this.totalRevenue,
  });

  Map<String, dynamic> toJson() => {
        'totalUsers': totalUsers,
        'totalProviders': totalProviders,
        'totalChargers': totalChargers,
        'activeSessions': activeSessions,
        'totalRevenue': totalRevenue,
      };

  factory AdminStatistics.fromJson(Map<String, dynamic> json) {
    return AdminStatistics(
      totalUsers: json['totalUsers'] as int? ?? 0,
      totalProviders: json['totalProviders'] as int? ?? 0,
      totalChargers: json['totalChargers'] as int? ?? 0,
      activeSessions: json['activeSessions'] as int? ?? 0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
