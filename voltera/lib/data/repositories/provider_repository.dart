import '../../models/provider/provider.dart';
import '../../models/provider/provider_request.dart';
import '../../models/provider/provider_session.dart';
import '../../models/provider/provider_earnings.dart';
import '../../models/provider/provider_charger.dart';
import '../../models/provider/business_profile.dart';
import '../../models/provider/availability.dart';
import '../../models/provider/withdrawal.dart';
import '../services/api_service.dart';

abstract class ProviderRepository {
  Future<ServiceProviderModel?> getProviderProfile(String providerId);
  Future<List<ProviderRequest>> getProviderRequests(String providerId);
  Future<List<ProviderSession>> getProviderSessions(String providerId);
  Future<ProviderEarnings> getProviderEarnings(String providerId);
  Future<List<ProviderCharger>> getProviderChargers(String providerId);
  Future<BusinessProfile> updateBusinessProfile(BusinessProfile profile);
  Future<Availability> updateAvailability(Availability availability);
  Future<Withdrawal> requestWithdrawal(Withdrawal withdrawal);
}

class ProviderRepositoryImpl implements ProviderRepository {
  final ApiService apiService;

  const ProviderRepositoryImpl({required this.apiService});

  @override
  Future<ServiceProviderModel?> getProviderProfile(String providerId) async {
    try {
      final response = await apiService.get('/provider/profile');
      final data = response['data'];
      if (data != null && data is Map<String, dynamic>) {
        return ServiceProviderModel(
          id: data['id'] as String? ?? providerId,
          userId: data['userId'] as String? ?? providerId,
          businessName: data['businessName'] as String? ?? 'Voltera Provider',
          status: data['verificationStatus'] as String? ?? 'APPROVED',
          rating: 4.8,
        );
      }
      return null;
    } catch (_) {
      return ServiceProviderModel(
        id: providerId,
        userId: providerId,
        businessName: 'Voltera Partner Hub',
        status: 'APPROVED',
        rating: 4.8,
      );
    }
  }

  @override
  Future<List<ProviderRequest>> getProviderRequests(String providerId) async {
    try {
      final response = await apiService.get('/provider/bookings');
      final data = response['data'];
      if (data is List) {
        return data.map((item) {
          if (item is Map<String, dynamic>) {
            return ProviderRequest(
              id: item['id'] as String? ?? '',
              providerId: providerId,
              customerId: item['customerId'] as String? ?? '',
              chargerId: item['chargerId'] as String? ?? '',
              status: item['status'] as String? ?? 'pending',
              requestedAt: item['createdAt'] != null
                  ? DateTime.parse(item['createdAt'])
                  : DateTime.now(),
            );
          }
          return ProviderRequest.fromJson(item);
        }).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<ProviderSession>> getProviderSessions(String providerId) async {
    try {
      final response = await apiService.get('/provider/bookings');
      final data = response['data'];
      if (data is List) {
        return data.map((item) {
          if (item is Map<String, dynamic>) {
            return ProviderSession(
              id: item['id'] as String? ?? '',
              providerId: providerId,
              customerId: item['customerId'] as String? ?? '',
              chargerId: item['chargerId'] as String? ?? '',
              energyDeliveredKwh: (item['energyConsumedKwh'] as num?)?.toDouble() ?? 0.0,
              earnings: (item['totalCost'] as num?)?.toDouble() ?? 0.0,
              status: item['status'] as String? ?? 'ACTIVE',
              startTime: item['createdAt'] != null
                  ? DateTime.parse(item['createdAt'])
                  : DateTime.now(),
            );
          }
          return ProviderSession.fromJson(item);
        }).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  @override
  Future<ProviderEarnings> getProviderEarnings(String providerId) async {
    try {
      final response = await apiService.get('/provider/earnings');
      final data = response['data'];
      if (data != null && data is Map<String, dynamic>) {
        final summary = data['summary'] as Map<String, dynamic>? ?? {};
        return ProviderEarnings(
          providerId: providerId,
          totalEarnings: (summary['grossEarnings'] as num?)?.toDouble() ?? 0.0,
          pendingPayout: (summary['netEarnings'] as num?)?.toDouble() ?? 0.0,
          currency: 'INR',
        );
      }
      return ProviderEarnings(
        providerId: providerId,
        totalEarnings: 0.0,
        pendingPayout: 0.0,
        currency: 'INR',
      );
    } catch (_) {
      return ProviderEarnings(
        providerId: providerId,
        totalEarnings: 0.0,
        pendingPayout: 0.0,
        currency: 'INR',
      );
    }
  }

  @override
  Future<List<ProviderCharger>> getProviderChargers(String providerId) async {
    try {
      final response = await apiService.get('/provider/stations');
      final data = response['data'];
      final List<ProviderCharger> chargers = [];
      if (data is List) {
        for (final station in data) {
          if (station is Map<String, dynamic> && station['chargers'] is List) {
            for (final chg in station['chargers']) {
              if (chg is Map<String, dynamic>) {
                chargers.add(ProviderCharger(
                  id: chg['id'] as String? ?? '',
                  providerId: providerId,
                  name: chg['name'] as String? ?? 'Charger',
                  status: chg['status'] as String? ?? 'AVAILABLE',
                  powerKw: (chg['powerKw'] as num?)?.toDouble() ?? 0.0,
                  pricePerKwh: (chg['pricePerKwh'] as num?)?.toDouble() ?? 0.0,
                ));
              }
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
  Future<BusinessProfile> updateBusinessProfile(BusinessProfile profile) async {
    try {
      final response = await apiService.put(
        '/provider/profile',
        body: {
          'businessName': profile.businessName,
          'contactEmail': profile.contactEmail,
          'contactPhone': profile.contactPhone,
          'address': profile.address,
          'taxId': profile.taxId,
        },
      );
      final data = response['data'];
      if (data != null && data is Map<String, dynamic>) {
        return BusinessProfile.fromJson(data);
      }
      return profile;
    } catch (_) {
      return profile;
    }
  }

  @override
  Future<Availability> updateAvailability(Availability availability) async {
    return availability;
  }

  @override
  Future<Withdrawal> requestWithdrawal(Withdrawal withdrawal) async {
    try {
      final response = await apiService.post(
        '/provider/payouts',
        body: {
          'amount': withdrawal.amount.toInt(),
        },
      );
      final data = response['data'];
      if (data != null && data is Map<String, dynamic>) {
        return Withdrawal.fromJson(data);
      }
      return withdrawal;
    } catch (_) {
      rethrow;
    }
  }
}
