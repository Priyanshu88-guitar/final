import '../../models/admin/admin_user.dart';
import '../../models/admin/admin_statistics.dart';
import '../../models/admin/admin_charger.dart';
import '../../models/admin/admin_session.dart';
import '../../models/admin/admin_revenue.dart';
import '../../models/user_role.dart';
import '../services/api_service.dart';

abstract class AdminRepository {
  Future<AdminStatistics> getAdminStatistics();
  Future<List<AdminUser>> getAllUsers();
  Future<List<AdminCharger>> getAllChargers();
  Future<List<AdminSessionRecord>> getAllSessions();
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
        return AdminStatistics(
          totalUsers: summary['totalUsers'] as int? ?? 0,
          totalProviders: summary['totalProviders'] as int? ?? 0,
          totalChargers: summary['totalStations'] as int? ?? 0,
          activeSessions: summary['activeBookings'] as int? ?? 0,
          totalRevenue: (summary['grossVolume'] as num?)?.toDouble() ?? 0.0,
        );
      }
      return const AdminStatistics(
        totalUsers: 0,
        totalProviders: 0,
        totalChargers: 0,
        activeSessions: 0,
        totalRevenue: 0.0,
      );
    } catch (_) {
      return const AdminStatistics(
        totalUsers: 0,
        totalProviders: 0,
        totalChargers: 0,
        activeSessions: 0,
        totalRevenue: 0.0,
      );
    }
  }

  @override
  Future<List<AdminUser>> getAllUsers() async {
    try {
      final response = await apiService.get('/admin/users');
      final data = response['data'];
      if (data is List) {
        return data.map((item) {
          if (item is Map<String, dynamic>) {
            final roles = item['roles'] as List?;
            String roleStr = 'customer';
            if (roles != null && roles.isNotEmpty) {
              final firstRole = roles.first;
              if (firstRole is Map<String, dynamic>) {
                roleStr = (firstRole['role'] as String? ?? 'CUSTOMER').toLowerCase();
              }
            }
            final role = UserRole.values.firstWhere(
              (e) => e.name == roleStr,
              orElse: () => UserRole.customer,
            );

            return AdminUser(
              id: item['id'] as String? ?? '',
              email: item['email'] as String? ?? item['phoneNumber'] as String? ?? '',
              role: role,
              isActive: item['accountStatus'] == 'ACTIVE',
              createdAt: item['createdAt'] != null
                  ? DateTime.parse(item['createdAt'])
                  : DateTime.now(),
            );
          }
          return AdminUser.fromJson(item);
        }).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<AdminCharger>> getAllChargers() async {
    try {
      final response = await apiService.get('/admin/stations');
      final data = response['data'];
      final List<AdminCharger> chargers = [];
      if (data is List) {
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
                    providerId: providerId,
                    verificationStatus: 'APPROVED',
                    isEnabled: stationStatus == 'ACTIVE',
                  ));
                }
              }
            } else {
              chargers.add(AdminCharger(
                id: station['id'] as String? ?? '',
                name: stationName,
                providerId: providerId,
                verificationStatus: 'APPROVED',
                isEnabled: stationStatus == 'ACTIVE',
              ));
            }
          }
        }
      }
      return chargers;
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<AdminSessionRecord>> getAllSessions() async {
    try {
      final response = await apiService.get('/admin/bookings');
      final data = response['data'];
      if (data is List) {
        return data.map((item) {
          if (item is Map<String, dynamic>) {
            final charger = item['charger'] as Map<String, dynamic>? ?? {};
            final station = charger['station'] as Map<String, dynamic>? ?? {};
            return AdminSessionRecord(
              id: item['id'] as String? ?? '',
              customerId: item['customerId'] as String? ?? '',
              providerId: station['providerId'] as String? ?? '',
              chargerId: item['chargerId'] as String? ?? '',
              status: item['status'] as String? ?? 'ACTIVE',
              startTime: item['startTime'] != null
                  ? DateTime.parse(item['startTime'])
                  : DateTime.now(),
            );
          }
          return AdminSessionRecord.fromJson(item);
        }).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  @override
  Future<AdminRevenue> getRevenueMetrics() async {
    try {
      final response = await apiService.get('/admin/dashboard');
      final data = response['data'];
      if (data != null && data is Map<String, dynamic>) {
        final summary = data['summary'] as Map<String, dynamic>? ?? {};
        final gross = (summary['grossVolume'] as num?)?.toDouble() ?? 0.0;
        final platformFee = gross * 0.10;
        return AdminRevenue(
          grossRevenue: gross,
          commissionEarned: platformFee,
          providerPayouts: gross - platformFee,
          currency: 'INR',
        );
      }
      return const AdminRevenue(
        grossRevenue: 0.0,
        commissionEarned: 0.0,
        providerPayouts: 0.0,
        currency: 'INR',
      );
    } catch (_) {
      return const AdminRevenue(
        grossRevenue: 0.0,
        commissionEarned: 0.0,
        providerPayouts: 0.0,
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
