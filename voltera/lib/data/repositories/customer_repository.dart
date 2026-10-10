import 'package:flutter/foundation.dart';
import '../../models/customer/charger.dart';
import '../../models/customer/booking.dart';
import '../../models/customer/charging_session.dart';
import '../../models/customer/payment.dart';
import '../../models/customer/review.dart';
import '../../models/customer/wallet.dart';
import '../services/api_service.dart';
import '../../core/demo/demo_config.dart';
import '../../core/demo/demo_data.dart';

abstract class CustomerRepository {
  Future<List<Charger>> getChargers({Map<String, dynamic>? filters});
  Future<Charger?> getChargerDetails(String chargerId);
  Future<Booking> createBooking(Booking booking);
  Future<ChargingSession?> getActiveSession(String customerId);
  Future<Payment> processPayment(Payment payment);
  Future<void> submitReview(Review review);
  Future<Wallet> getWallet(String customerId);
}

class CustomerRepositoryImpl implements CustomerRepository {
  final ApiService apiService;

  const CustomerRepositoryImpl({required this.apiService});

  @override
  Future<List<Charger>> getChargers({Map<String, dynamic>? filters}) async {
    if (DemoConfig.demoMode) {
      return DemoData.nearbyChargers.map((c) => Charger(
        id: c['id'] as String? ?? 'chg',
        name: c['name'] as String? ?? 'Charger',
        providerId: 'demo-provider',
        locationAddress: c['address'] as String? ?? '',
        latitude: 23.0225,
        longitude: 72.5714,
        connectorType: c['connector'] as String? ?? 'CCS2',
        powerKw: 60.0,
        pricePerHour: 120.0,
        pricePerKwh: 18.0,
        isAvailable: c['status'] == 'Available',
        rating: (c['rating'] as num?)?.toDouble() ?? 4.7,
      )).toList();
    }

    try {
      debugPrint('FETCHING CHARGERS FROM: /chargers with filters: $filters');
      final response = await apiService.get('/chargers', queryParameters: filters);
      debugPrint('CHARGERS API SUCCESS: Status 200, received response');
      final data = response['data'];

      if (data is List) {
        return data.map((item) {
          if (item is Map<String, dynamic>) {
            final station = item['station'] as Map<String, dynamic>? ?? {};
            return Charger(
              id: item['id'] as String? ?? '',
              name: item['name'] as String? ?? station['name'] as String? ?? 'Voltera Charger',
              providerId: station['providerId'] as String? ?? item['providerId'] as String? ?? '',
              locationAddress: station['address'] as String? ?? '',
              latitude: (station['latitude'] as num?)?.toDouble() ?? 0.0,
              longitude: (station['longitude'] as num?)?.toDouble() ?? 0.0,
              connectorType: item['connectorType'] as String? ?? '',
              powerKw: (item['powerKw'] as num?)?.toDouble() ?? 0.0,
              pricePerHour: (item['pricePerHour'] as num?)?.toDouble() ?? 0.0,
              pricePerKwh: (item['pricePerKwh'] as num?)?.toDouble() ?? 0.0,
              isAvailable: item['status'] == 'AVAILABLE',
              rating: 4.5,
            );
          }
          return Charger.fromJson(item);
        }).toList();
      }
      return [];
    } catch (e, stackTrace) {
      debugPrint('CHARGERS API ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<Charger?> getChargerDetails(String chargerId) async {
    if (DemoConfig.demoMode) {
      final match = DemoData.nearbyChargers.firstWhere(
        (c) => c['id'] == chargerId,
        orElse: () => DemoData.nearbyChargers.first,
      );
      return Charger(
        id: match['id'] as String? ?? 'chg-1',
        name: match['name'] as String? ?? 'GreenCharge Hub',
        providerId: 'demo-provider',
        locationAddress: match['address'] as String? ?? 'SG Highway, Ahmedabad',
        latitude: 23.0225,
        longitude: 72.5714,
        connectorType: match['connector'] as String? ?? 'CCS2',
        powerKw: 60.0,
        pricePerHour: 120.0,
        pricePerKwh: 18.0,
        isAvailable: match['status'] == 'Available',
        rating: (match['rating'] as num?)?.toDouble() ?? 4.7,
      );
    }

    try {
      final response = await apiService.get('/chargers/$chargerId');
      final data = response['data'];
      if (data != null && data is Map<String, dynamic>) {
        final station = data['station'] as Map<String, dynamic>? ?? {};
        return Charger(
          id: data['id'] as String? ?? '',
          name: data['name'] as String? ?? station['name'] as String? ?? 'Voltera Charger',
          providerId: station['providerId'] as String? ?? data['providerId'] as String? ?? '',
          locationAddress: station['address'] as String? ?? '',
          latitude: (station['latitude'] as num?)?.toDouble() ?? 0.0,
          longitude: (station['longitude'] as num?)?.toDouble() ?? 0.0,
          connectorType: data['connectorType'] as String? ?? '',
          powerKw: (data['powerKw'] as num?)?.toDouble() ?? 0.0,
          pricePerHour: (data['pricePerHour'] as num?)?.toDouble() ?? 0.0,
          pricePerKwh: (data['pricePerKwh'] as num?)?.toDouble() ?? 0.0,
          isAvailable: data['status'] == 'AVAILABLE',
          rating: 4.5,
        );
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Booking> createBooking(Booking booking) async {
    if (DemoConfig.demoMode) {
      return booking;
    }

    try {
      final response = await apiService.post(
        '/customer/bookings',
        body: {
          'chargerId': booking.chargerId,
          'startTime': booking.startTime.toIso8601String(),
          'endTime': booking.endTime.toIso8601String(),
        },
      );
      final data = response['data'];
      if (data != null && data is Map<String, dynamic>) {
        return Booking.fromJson(data);
      }
      return booking;
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<ChargingSession?> getActiveSession(String customerId) async {
    if (DemoConfig.demoMode) {
      return ChargingSession(
        id: 'sess-active',
        bookingId: 'BK-101',
        customerId: customerId,
        chargerId: 'chg-1',
        energyConsumedKwh: 8.6,
        currentPowerKw: 22.0,
        durationMinutes: 24,
        status: 'active',
        totalCost: 155.0,
      );
    }

    try {
      final response = await apiService.get('/customer/sessions/active');
      final data = response['data'];
      if (data != null && data is Map<String, dynamic>) {
        return ChargingSession.fromJson(data);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Payment> processPayment(Payment payment) async {
    if (DemoConfig.demoMode) {
      return payment;
    }

    try {
      final response = await apiService.post(
        '/customer/payments/create',
        body: {
          'amount': payment.amount.toInt(),
          'currency': payment.currency,
          'sessionId': payment.sessionId,
        },
      );
      final data = response['data'];
      if (data != null && data is Map<String, dynamic>) {
        return Payment.fromJson(data);
      }
      return payment;
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<void> submitReview(Review review) async {
    if (DemoConfig.demoMode) return;

    try {
      await apiService.post(
        '/customer/reviews',
        body: review.toJson(),
      );
    } catch (_) {
      // Review submission optional endpoint handle
    }
  }

  @override
  Future<Wallet> getWallet(String customerId) async {
    if (DemoConfig.demoMode) {
      return Wallet(
        id: 'WLT-DEMO',
        customerId: customerId,
        balance: 1850.0,
        currency: 'INR',
      );
    }

    try {
      final response = await apiService.get('/customer/transactions');
      final data = response['data'];
      double balance = 1850.0;
      if (data is List) {
        for (final tx in data) {
          if (tx is Map<String, dynamic> && tx['amount'] is num) {
            balance += (tx['amount'] as num).toDouble();
          }
        }
      }
      return Wallet(
        id: 'WLT-$customerId',
        customerId: customerId,
        balance: balance,
        currency: 'INR',
      );
    } catch (_) {
      return Wallet(
        id: 'WLT-$customerId',
        customerId: customerId,
        balance: 1850.0,
        currency: 'INR',
      );
    }
  }
}
