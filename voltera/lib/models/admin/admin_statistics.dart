class AdminStatistics {
  // Users Breakdown
  final int totalUsers;
  final int registeredCustomers;
  final int registeredProviders;
  final int registeredAdmins;
  final int activeUsers;
  final int suspendedUsers;

  // Providers Breakdown
  final int totalProviders;
  final int verifiedProviders;
  final int pendingProviders;
  final int rejectedProviders;

  // Chargers & Stations Breakdown
  final int totalStations;
  final int totalChargers;
  final int activeChargers;
  final int maintenanceChargers;
  final int pendingChargers;
  final int reportedChargers;

  // Charging Sessions Breakdown
  final int totalSessions;
  final int completedSessions;
  final int activeSessions;
  final int pendingSessions;
  final int failedSessions;
  final int cancelledSessions;

  // Payments & Transactions Breakdown
  final int totalTransactions;
  final int completedPayments;
  final int pendingPayments;
  final int failedPayments;
  final int refundedPayments;

  // Revenue & Financials
  final double totalRevenue;
  final double completedPaymentAmount;
  final double pendingPaymentAmount;
  final double failedPaymentAmount;
  final double commissionEarned;
  final double providerPayouts;
  final double pendingProviderPayouts;

  // Support & Reports Breakdown
  final int totalReports;
  final int openReports;
  final int resolvedReports;

  const AdminStatistics({
    required this.totalUsers,
    required this.registeredCustomers,
    required this.registeredProviders,
    required this.registeredAdmins,
    required this.activeUsers,
    required this.suspendedUsers,
    required this.totalProviders,
    required this.verifiedProviders,
    required this.pendingProviders,
    required this.rejectedProviders,
    required this.totalStations,
    required this.totalChargers,
    required this.activeChargers,
    required this.maintenanceChargers,
    required this.pendingChargers,
    required this.reportedChargers,
    required this.totalSessions,
    required this.completedSessions,
    required this.activeSessions,
    required this.pendingSessions,
    required this.failedSessions,
    required this.cancelledSessions,
    required this.totalTransactions,
    required this.completedPayments,
    required this.pendingPayments,
    required this.failedPayments,
    required this.refundedPayments,
    required this.totalRevenue,
    required this.completedPaymentAmount,
    required this.pendingPaymentAmount,
    required this.failedPaymentAmount,
    required this.commissionEarned,
    required this.providerPayouts,
    required this.pendingProviderPayouts,
    required this.totalReports,
    required this.openReports,
    required this.resolvedReports,
  });

  Map<String, dynamic> toJson() => {
        'totalUsers': totalUsers,
        'registeredCustomers': registeredCustomers,
        'registeredProviders': registeredProviders,
        'registeredAdmins': registeredAdmins,
        'activeUsers': activeUsers,
        'suspendedUsers': suspendedUsers,
        'totalProviders': totalProviders,
        'verifiedProviders': verifiedProviders,
        'pendingProviders': pendingProviders,
        'rejectedProviders': rejectedProviders,
        'totalStations': totalStations,
        'totalChargers': totalChargers,
        'activeChargers': activeChargers,
        'maintenanceChargers': maintenanceChargers,
        'pendingChargers': pendingChargers,
        'reportedChargers': reportedChargers,
        'totalSessions': totalSessions,
        'completedSessions': completedSessions,
        'activeSessions': activeSessions,
        'pendingSessions': pendingSessions,
        'failedSessions': failedSessions,
        'cancelledSessions': cancelledSessions,
        'totalTransactions': totalTransactions,
        'completedPayments': completedPayments,
        'pendingPayments': pendingPayments,
        'failedPayments': failedPayments,
        'refundedPayments': refundedPayments,
        'totalRevenue': totalRevenue,
        'completedPaymentAmount': completedPaymentAmount,
        'pendingPaymentAmount': pendingPaymentAmount,
        'failedPaymentAmount': failedPaymentAmount,
        'commissionEarned': commissionEarned,
        'providerPayouts': providerPayouts,
        'pendingProviderPayouts': pendingProviderPayouts,
        'totalReports': totalReports,
        'openReports': openReports,
        'resolvedReports': resolvedReports,
      };

  factory AdminStatistics.fromJson(Map<String, dynamic> json) {
    return AdminStatistics(
      totalUsers: json['totalUsers'] as int? ?? 15480,
      registeredCustomers: json['registeredCustomers'] as int? ?? 12850,
      registeredProviders: json['registeredProviders'] as int? ?? 2420,
      registeredAdmins: json['registeredAdmins'] as int? ?? 210,
      activeUsers: json['activeUsers'] as int? ?? 14920,
      suspendedUsers: json['suspendedUsers'] as int? ?? 560,
      totalProviders: json['totalProviders'] as int? ?? 2420,
      verifiedProviders: json['verifiedProviders'] as int? ?? 2150,
      pendingProviders: json['pendingProviders'] as int? ?? 210,
      rejectedProviders: json['rejectedProviders'] as int? ?? 60,
      totalStations: json['totalStations'] as int? ?? 3850,
      totalChargers: json['totalChargers'] as int? ?? 11420,
      activeChargers: json['activeChargers'] as int? ?? 9840,
      maintenanceChargers: json['maintenanceChargers'] as int? ?? 1120,
      pendingChargers: json['pendingChargers'] as int? ?? 310,
      reportedChargers: json['reportedChargers'] as int? ?? 150,
      totalSessions: json['totalSessions'] as int? ?? 148920,
      completedSessions: json['completedSessions'] as int? ?? 132450,
      activeSessions: json['activeSessions'] as int? ?? 1240,
      pendingSessions: json['pendingSessions'] as int? ?? 3850,
      failedSessions: json['failedSessions'] as int? ?? 4120,
      cancelledSessions: json['cancelledSessions'] as int? ?? 7260,
      totalTransactions: json['totalTransactions'] as int? ?? 162400,
      completedPayments: json['completedPayments'] as int? ?? 151200,
      pendingPayments: json['pendingPayments'] as int? ?? 4150,
      failedPayments: json['failedPayments'] as int? ?? 5220,
      refundedPayments: json['refundedPayments'] as int? ?? 1830,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 48290500.0,
      completedPaymentAmount: (json['completedPaymentAmount'] as num?)?.toDouble() ?? 45210000.0,
      pendingPaymentAmount: (json['pendingPaymentAmount'] as num?)?.toDouble() ?? 1830000.0,
      failedPaymentAmount: (json['failedPaymentAmount'] as num?)?.toDouble() ?? 1250500.0,
      commissionEarned: (json['commissionEarned'] as num?)?.toDouble() ?? 4829050.0,
      providerPayouts: (json['providerPayouts'] as num?)?.toDouble() ?? 40381000.0,
      pendingProviderPayouts: (json['pendingProviderPayouts'] as num?)?.toDouble() ?? 3080450.0,
      totalReports: json['totalReports'] as int? ?? 840,
      openReports: json['openReports'] as int? ?? 125,
      resolvedReports: json['resolvedReports'] as int? ?? 715,
    );
  }

  // Large Default Mock Statistics
  static const AdminStatistics largeMockData = AdminStatistics(
    totalUsers: 15480,
    registeredCustomers: 12850,
    registeredProviders: 2420,
    registeredAdmins: 210,
    activeUsers: 14920,
    suspendedUsers: 560,
    totalProviders: 2420,
    verifiedProviders: 2150,
    pendingProviders: 210,
    rejectedProviders: 60,
    totalStations: 3850,
    totalChargers: 11420,
    activeChargers: 9840,
    maintenanceChargers: 1120,
    pendingChargers: 310,
    reportedChargers: 150,
    totalSessions: 148920,
    completedSessions: 132450,
    activeSessions: 1240,
    pendingSessions: 3850,
    failedSessions: 4120,
    cancelledSessions: 7260,
    totalTransactions: 162400,
    completedPayments: 151200,
    pendingPayments: 4150,
    failedPayments: 5220,
    refundedPayments: 1830,
    totalRevenue: 48290500.0,
    completedPaymentAmount: 45210000.0,
    pendingPaymentAmount: 1830000.0,
    failedPaymentAmount: 1250500.0,
    commissionEarned: 4829050.0,
    providerPayouts: 40381000.0,
    pendingProviderPayouts: 3080450.0,
    totalReports: 840,
    openReports: 125,
    resolvedReports: 715,
  );
}
