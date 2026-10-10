import 'package:flutter/material.dart';
import '../../models/provider/provider_request.dart';
import '../../models/provider/provider_charger.dart';

class ProviderStateManager extends ChangeNotifier {
  static final ProviderStateManager _instance = ProviderStateManager._internal();
  factory ProviderStateManager() => _instance;
  ProviderStateManager._internal();

  final List<ProviderRequest> _requests = [
    ProviderRequest(
      id: 'REQ-101',
      providerId: 'PROV-1',
      customerId: 'CUST-101',
      chargerId: 'CHG-1',
      status: 'pending',
      requestedAt: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    ProviderRequest(
      id: 'REQ-102',
      providerId: 'PROV-1',
      customerId: 'CUST-102',
      chargerId: 'CHG-2',
      status: 'pending',
      requestedAt: DateTime.now().subtract(const Duration(minutes: 12)),
    ),
  ];

  final List<ProviderCharger> _chargers = [
    const ProviderCharger(
      id: 'CHG-1',
      providerId: 'PROV-1',
      name: 'Charger 1',
      status: 'Available',
      powerKw: 7.4,
      pricePerKwh: 12.0,
    ),
    const ProviderCharger(
      id: 'CHG-2',
      providerId: 'PROV-1',
      name: 'Charger 2',
      status: 'Available',
      powerKw: 11.0,
      pricePerKwh: 15.0,
    ),
  ];

  List<ProviderRequest> get requests => List.unmodifiable(_requests);
  List<ProviderRequest> get pendingRequests => _requests.where((r) => r.status == 'pending').toList();
  List<ProviderRequest> get acceptedRequests => _requests.where((r) => r.status == 'accepted').toList();
  List<ProviderRequest> get rejectedRequests => _requests.where((r) => r.status == 'rejected').toList();

  List<ProviderCharger> get chargers => List.unmodifiable(_chargers);

  void acceptRequest(String requestId) {
    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      final old = _requests[index];
      _requests[index] = ProviderRequest(
        id: old.id,
        providerId: old.providerId,
        customerId: old.customerId,
        chargerId: old.chargerId,
        status: 'accepted',
        requestedAt: old.requestedAt,
      );
      notifyListeners();
    }
  }

  void rejectRequest(String requestId) {
    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      final old = _requests[index];
      _requests[index] = ProviderRequest(
        id: old.id,
        providerId: old.providerId,
        customerId: old.customerId,
        chargerId: old.chargerId,
        status: 'rejected',
        requestedAt: old.requestedAt,
      );
      notifyListeners();
    }
  }

  void addCharger(ProviderCharger charger) {
    _chargers.add(charger);
    notifyListeners();
  }

  void removeCharger(String id) {
    _chargers.removeWhere((c) => c.id == id);
    notifyListeners();
  }
}
