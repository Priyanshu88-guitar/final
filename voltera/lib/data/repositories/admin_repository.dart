import '../../models/admin/admin_user.dart';
import '../../models/admin/admin_statistics.dart';
import '../../models/admin/admin_charger.dart';
import '../../models/admin/admin_session.dart';
import '../../models/admin/admin_revenue.dart';
import '../../models/admin/admin_transaction.dart';
import '../../models/admin/admin_report.dart';
import '../../models/user_role.dart';
import '../../core/demo/demo_data.dart';
import '../services/api_service.dart';

abstract class AdminRepository {
  Future<AdminStatistics> getAdminStatistics();
  Future<List<AdminUser>> getAllUsers();
  Future<List<AdminCharger>> getAllChargers();
  Future<List<AdminSessionRecord>> getAllSessions();
  Future<List<AdminTransactionRecord>> getAllTransactions();
  Future<List<AdminReportRecord>> getAllReports();
  Future<AdminRevenue> getRevenueMetrics();
  Future<void> verifyProviderCharger(String chargerId, bool approve);
}

class AdminRepositoryImpl implements AdminRepository {
  final ApiService apiService;

  const AdminRepositoryImpl({required this.apiService});

  @override
  Future<AdminStatistics> getAdminStatistics() async {
    try {
      final response = await apiService.get('/admin/dashboard');
      final data = response['data'];
      if (data != null && data is Map<String, dynamic>) {
        final summary = data['summary'] as Map<String, dynamic>? ?? {};
        final gross = (summary['grossVolume'] as num?)?.toDouble() ?? 48290500.0;
        final commission = gross * 0.10;
        return AdminStatistics(
          totalUsers: summary['totalUsers'] as int? ?? 15480,
          registeredCustomers: summary['customers'] as int? ?? 12850,
          registeredProviders: summary['providers'] as int? ?? 2420,
          registeredAdmins: summary['admins'] as int? ?? 210,
          activeUsers: summary['activeUsers'] as int? ?? 14920,
          suspendedUsers: summary['suspendedUsers'] as int? ?? 560,
          totalProviders: summary['providers'] as int? ?? 2420,
          verifiedProviders: summary['verifiedProviders'] as int? ?? 2150,
          pendingProviders: summary['pendingProviders'] as int? ?? 210,
          rejectedProviders: summary['rejectedProviders'] as int? ?? 60,
          totalStations: summary['totalStations'] as int? ?? 3850,
          totalChargers: summary['totalChargers'] as int? ?? 11420,
          activeChargers: summary['activeChargers'] as int? ?? 9840,
          maintenanceChargers: summary['maintenanceChargers'] as int? ?? 1120,
          pendingChargers: summary['pendingChargers'] as int? ?? 310,
          reportedChargers: summary['reportedChargers'] as int? ?? 150,
          totalSessions: summary['totalSessions'] as int? ?? 148920,
          completedSessions: summary['completedSessions'] as int? ?? 132450,
          activeSessions: summary['activeBookings'] as int? ?? 1240,
          pendingSessions: summary['pendingSessions'] as int? ?? 3850,
          failedSessions: summary['failedSessions'] as int? ?? 4120,
          cancelledSessions: summary['cancelledSessions'] as int? ?? 7260,
          totalTransactions: summary['totalTransactions'] as int? ?? 162400,
          completedPayments: summary['completedPayments'] as int? ?? 151200,
          pendingPayments: summary['pendingPayments'] as int? ?? 4150,
          failedPayments: summary['failedPayments'] as int? ?? 5220,
          refundedPayments: summary['refundedPayments'] as int? ?? 1830,
          totalRevenue: gross,
          completedPaymentAmount: gross * 0.936,
          pendingPaymentAmount: gross * 0.038,
          failedPaymentAmount: gross * 0.026,
          commissionEarned: commission,
          providerPayouts: gross - commission,
          pendingProviderPayouts: 3080450.0,
          totalReports: summary['totalReports'] as int? ?? 840,
          openReports: summary['openReports'] as int? ?? 125,
          resolvedReports: summary['resolvedReports'] as int? ?? 715,
        );
      }
      return AdminStatistics.largeMockData;
    } catch (_) {
      return AdminStatistics.largeMockData;
    }
  }

  @override
  Future<List<AdminUser>> getAllUsers() async {
    try {
      final response = await apiService.get('/admin/users');
      final data = response['data'];
      if (data is List && data.isNotEmpty) {
        return data.map((item) {
          if (item is Map<String, dynamic>) {
            return AdminUser.fromJson(item);
          }
          return AdminUser.fromJson({});
        }).toList();
      }
      return _getDemoUsers();
    } catch (_) {
      return _getDemoUsers();
    }
  }

  List<AdminUser> _getDemoUsers() {
    return DemoData.adminUsers.map((map) {
      final roleStr = (map['role'] ?? 'customer').toString().toLowerCase();
      final roleEnum = UserRole.values.firstWhere(
        (r) => r.name.toLowerCase() == roleStr,
        orElse: () => UserRole.customer,
      );
      final statusStr = (map['status'] ?? 'ACTIVE').toString().toUpperCase();

      return AdminUser(
        id: map['id'] ?? 'USR-001',
        name: map['name'] ?? 'Demo User',
        phone: map['phone'] ?? '+91 98765 43210',
        email: map['email'] ?? 'demo@voltera.io',
        role: roleEnum,
        roles: [roleEnum],
        isActive: statusStr == 'ACTIVE',
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        location: map['location'] ?? 'Ahmedabad, Gujarat',
        totalSessions: (map['sessions'] is int) ? map['sessions'] : 18,
        walletBalance: 1250.0,
      );
    }).toList();
  }

  @override
  Future<List<AdminCharger>> getAllChargers() async {
    try {
      final response = await apiService.get('/admin/stations');
      final data = response['data'];
      final List<AdminCharger> chargers = [];
      if (data is List && data.isNotEmpty) {
        for (final station in data) {
          if (station is Map<String, dynamic>) {
            final stationName = station['name'] as String? ?? 'Station';
            final providerId = station['providerId'] as String? ?? '';
            final stationStatus = station['status'] as String? ?? 'ACTIVE';

            if (station['chargers'] is List) {
              for (final chg in station['chargers']) {
                if (chg is Map<String, dynamic>) {
                  chargers.add(AdminCharger(
                    id: chg['id'] as String? ?? '',
                    name: chg['name'] as String? ?? stationName,
                    stationName: stationName,
                    providerId: providerId,
                    providerName: 'Voltera Provider',
                    location: station['address'] as String? ?? 'Ahmedabad',
                    connectorType: chg['type'] as String? ?? 'CCS2',
                    powerKw: '${chg['power'] ?? 60} kW',
                    pricePerKwh: '₹${chg['price'] ?? 18}/kWh',
                    verificationStatus: 'APPROVED',
                    isEnabled: stationStatus == 'ACTIVE',
                    status: stationStatus,
                  ));
                }
              }
            } else {
              chargers.add(AdminCharger(
                id: station['id'] as String? ?? '',
                name: stationName,
                stationName: stationName,
                providerId: providerId,
                providerName: 'Voltera Provider',
                location: station['address'] as String? ?? 'Ahmedabad',
                verificationStatus: 'APPROVED',
                isEnabled: stationStatus == 'ACTIVE',
                status: stationStatus,
              ));
            }
          }
        }
        return chargers;
      }
      return _getDemoChargers();
    } catch (_) {
      return _getDemoChargers();
    }
  }

  List<AdminCharger> _getDemoChargers() {
    return DemoData.adminStations.map((map) {
      final statusStr = (map['status'] ?? 'ACTIVE').toString();
      return AdminCharger(
        id: map['id'] ?? 'CHG-101',
        name: map['name'] ?? 'Station',
        stationName: map['name'] ?? 'Station',
        providerId: 'PRV-101',
        providerName: map['provider'] ?? 'Amit Patel',
        location: map['city'] ?? 'Ahmedabad',
        connectorType: map['type'] ?? 'CCS2 Fast',
        powerKw: map['power'] ?? '60 kW',
        pricePerKwh: map['price'] ?? '₹18/kWh',
        verificationStatus: statusStr == 'PENDING' ? 'PENDING' : 'APPROVED',
        isEnabled: statusStr == 'ACTIVE',
        status: statusStr,
        totalSessions: map['sessions'] as int? ?? 450,
        rating: (map['rating'] as num?)?.toDouble() ?? 4.7,
      );
    }).toList();
  }

  @override
  Future<List<AdminSessionRecord>> getAllSessions() async {
    try {
      final response = await apiService.get('/admin/bookings');
      final data = response['data'];
      if (data is List && data.isNotEmpty) {
        return data.map((item) {
          if (item is Map<String, dynamic>) {
            final charger = item['charger'] as Map<String, dynamic>? ?? {};
            final station = charger['station'] as Map<String, dynamic>? ?? {};
            return AdminSessionRecord(
              id: item['id'] as String? ?? '',
              customerId: item['customerId'] as String? ?? '',
              customerName: item['customerName'] as String? ?? 'Customer',
              providerId: station['providerId'] as String? ?? '',
              providerName: 'Station Owner',
              stationName: station['name'] as String? ?? 'Voltera Hub',
              chargerId: item['chargerId'] as String? ?? '',
              status: item['status'] as String? ?? 'COMPLETED',
              duration: '45 min',
              energyKwh: '18.4 kWh',
              cost: 320.0,
              startTime: item['startTime'] != null
                  ? DateTime.parse(item['startTime'])
                  : DateTime.now(),
            );
          }
          return AdminSessionRecord.fromJson(item);
        }).toList();
      }
      return _getDemoSessions();
    } catch (_) {
      return _getDemoSessions();
    }
  }

  List<AdminSessionRecord> _getDemoSessions() {
    return DemoData.adminBookings.map((map) {
      return AdminSessionRecord(
        id: map['id'] ?? 'SES-1001',
        customerId: 'USR-1001',
        customerName: map['customer'] ?? 'Rahul Sharma',
        providerId: 'PRV-201',
        providerName: map['provider'] ?? 'Amit Patel',
        stationName: map['station'] ?? 'Voltera SG Highway',
        chargerId: map['charger'] ?? 'CCS2-01',
        status: (map['status'] ?? 'COMPLETED').toString().toUpperCase(),
        duration: map['duration'] ?? '45 min',
        energyKwh: map['energy'] ?? '18.4 kWh',
        cost: double.tryParse((map['cost'] ?? '320').toString().replaceAll(RegExp(r'[^0-9.]'), '')) ?? 320.0,
        startTime: DateTime.now().subtract(const Duration(hours: 3)),
      );
    }).toList();
  }

  @override
  Future<List<AdminTransactionRecord>> getAllTransactions() async {
    try {
      return _getDemoTransactions();
    } catch (_) {
      return _getDemoTransactions();
    }
  }

  List<AdminTransactionRecord> _getDemoTransactions() {
    return DemoData.adminTransactions.map((map) {
      return AdminTransactionRecord(
        id: map['id'] ?? 'TXN-9001',
        userName: map['user'] ?? 'Rahul Sharma',
        stationName: map['station'] ?? 'Voltera Station',
        type: map['type'] ?? 'CHARGING_SESSION',
        method: map['method'] ?? 'UPI',
        status: (map['status'] ?? 'COMPLETED').toString().toUpperCase(),
        amount: double.tryParse((map['amount'] ?? '331').toString().replaceAll(RegExp(r'[^0-9.]'), '')) ?? 331.0,
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        referenceNumber: map['ref'] ?? 'REF-908123',
      );
    }).toList();
  }

  @override
  Future<List<AdminReportRecord>> getAllReports() async {
    try {
      return _getDemoReports();
    } catch (_) {
      return _getDemoReports();
    }
  }

  List<AdminReportRecord> _getDemoReports() {
    return DemoData.adminReports.map((map) {
      return AdminReportRecord(
        id: map['id'] ?? 'REP-701',
        userName: map['user'] ?? 'Karan Malhotra',
        userEmail: map['email'] ?? 'karan@voltera.demo',
        category: map['category'] ?? 'CHARGER_ISSUE',
        subject: map['subject'] ?? 'Issue Report',
        description: map['description'] ?? 'No details provided.',
        priority: map['priority'] ?? 'HIGH',
        status: (map['status'] ?? 'OPEN').toString().toUpperCase(),
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      );
    }).toList();
  }

  @override
  Future<AdminRevenue> getRevenueMetrics() async {
    try {
      final response = await apiService.get('/admin/dashboard');
      final data = response['data'];
      if (data != null && data is Map<String, dynamic>) {
        final summary = data['summary'] as Map<String, dynamic>? ?? {};
        final gross = (summary['grossVolume'] as num?)?.toDouble() ?? 48290500.0;
        final platformFee = gross * 0.10;
        return AdminRevenue(
          grossRevenue: gross,
          commissionEarned: platformFee,
          providerPayouts: gross - platformFee,
          pendingPayouts: 3080450.0,
          completedTxnsCount: 151200,
          pendingTxnsCount: 4150,
          failedTxnsCount: 5220,
          currency: 'INR',
        );
      }
      return const AdminRevenue(
        grossRevenue: 48290500.0,
        commissionEarned: 4829050.0,
        providerPayouts: 40381000.0,
        pendingPayouts: 3080450.0,
        completedTxnsCount: 151200,
        pendingTxnsCount: 4150,
        failedTxnsCount: 5220,
        currency: 'INR',
      );
    } catch (_) {
      return const AdminRevenue(
        grossRevenue: 48290500.0,
        commissionEarned: 4829050.0,
        providerPayouts: 40381000.0,
        pendingPayouts: 3080450.0,
        completedTxnsCount: 151200,
        pendingTxnsCount: 4150,
        failedTxnsCount: 5220,
        currency: 'INR',
      );
    }
  }

  @override
  Future<void> verifyProviderCharger(String chargerId, bool approve) async {
    try {
      await apiService.patch(
        '/admin/providers/$chargerId/verification',
        body: {
          'status': approve ? 'APPROVED' : 'REJECTED',
        },
      );
    } catch (_) {}
  }
}
