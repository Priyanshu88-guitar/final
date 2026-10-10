class DemoChargerModel {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String connectorType;
  final String chargerType;
  final double powerKw;
  final double pricePerKwh;
  final String status;
  final double rating;

  const DemoChargerModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.connectorType,
    required this.chargerType,
    required this.powerKw,
    required this.pricePerKwh,
    required this.status,
    required this.rating,
  });
}

class DemoChargersData {
  static const List<DemoChargerModel> stations = [
    DemoChargerModel(
      id: 'demo-station-1',
      name: 'VOLTERA Charging Station - SG Highway',
      address: 'SG Highway, Ahmedabad',
      latitude: 23.0307,
      longitude: 72.5169,
      connectorType: 'CCS2',
      chargerType: 'Fast DC Charger',
      powerKw: 60.0,
      pricePerKwh: 18.0,
      status: 'Available',
      rating: 4.7,
    ),
    DemoChargerModel(
      id: 'demo-station-2',
      name: 'VOLTERA Charging Station - Satellite',
      address: 'Satellite, Ahmedabad',
      latitude: 23.0216,
      longitude: 72.5100,
      connectorType: 'Type 2',
      chargerType: 'AC Standard Charger',
      powerKw: 22.0,
      pricePerKwh: 15.0,
      status: 'Available',
      rating: 4.5,
    ),
    DemoChargerModel(
      id: 'demo-station-3',
      name: 'VOLTERA Charging Station - Bopal',
      address: 'Bopal, Ahmedabad',
      latitude: 23.0350,
      longitude: 72.4650,
      connectorType: 'CCS2 / Type 2',
      chargerType: 'Ultra Fast DC Charger',
      powerKw: 120.0,
      pricePerKwh: 22.0,
      status: 'Busy',
      rating: 4.8,
    ),
  ];
}
