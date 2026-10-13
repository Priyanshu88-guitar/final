import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/services/api_service.dart';
import '../../../widgets/common/voltera_button.dart';
import '../charger_map_screen.dart';

class FullChargerMapScreen extends StatefulWidget {
  const FullChargerMapScreen({super.key});

  @override
  State<FullChargerMapScreen> createState() => _FullChargerMapScreenState();
}

class _FullChargerMapScreenState extends State<FullChargerMapScreen> {
  final MapController _mapController = MapController();
  LatLng _currentLocation = const LatLng(22.4720, 70.0633); // Jamnagar Center (Lakhota Lake)
  List<Map<String, dynamic>> _chargers = [];
  Map<String, dynamic>? _selectedCharger;
  bool _isLoading = true;

  final List<Map<String, dynamic>> _jamnagarLandmarks = [
    {'name': 'Lakhota Lake EV Hub', 'address': 'Near Lakhota Lake / Ranmal Lake, Jamnagar', 'lat': 22.4720, 'lng': 70.0633, 'powerKw': 60.0, 'price': 140, 'status': 'AVAILABLE'},
    {'name': 'Park Colony Supercharger', 'address': 'Park Colony Main Road, Jamnagar', 'lat': 22.4830, 'lng': 70.0650, 'powerKw': 60.0, 'price': 140, 'status': 'AVAILABLE'},
    {'name': 'PN Marg Fast Charge', 'address': 'Pandit Nehru Marg, Jamnagar', 'lat': 22.4750, 'lng': 70.0500, 'powerKw': 60.0, 'price': 140, 'status': 'AVAILABLE'},
    {'name': 'Ranjit Park Charging Plaza', 'address': 'Near Ranjit Park, Jamnagar', 'lat': 22.4600, 'lng': 70.0550, 'powerKw': 60.0, 'price': 140, 'status': 'AVAILABLE'},
    {'name': 'Bedi Gate Eco Hub', 'address': 'Bedi Gate Road, Jamnagar', 'lat': 22.4780, 'lng': 70.0710, 'powerKw': 60.0, 'price': 140, 'status': 'AVAILABLE'},
    {'name': 'Digvijay Plot EV Hub', 'address': 'Digvijay Plot, Jamnagar', 'lat': 22.4760, 'lng': 70.0580, 'powerKw': 60.0, 'price': 140, 'status': 'AVAILABLE'},
    {'name': 'Circuit House Central EV', 'address': 'Near Circuit House, Jamnagar', 'lat': 22.4991, 'lng': 70.0448, 'powerKw': 60.0, 'price': 140, 'status': 'AVAILABLE'},
    {'name': 'Patel Colony Power Hub', 'address': 'Patel Colony Jamnagar', 'lat': 22.4810, 'lng': 70.0620, 'powerKw': 60.0, 'price': 140, 'status': 'AVAILABLE'},
    {'name': 'Jamnagar Bus Station Fast Charge', 'address': 'ST Bus Station Road, Jamnagar', 'lat': 22.4680, 'lng': 70.0590, 'powerKw': 60.0, 'price': 140, 'status': 'AVAILABLE'},
    {'name': 'GIDC Phase-III Industrial Charger', 'address': 'GIDC Phase-III, Jamnagar', 'lat': 22.4450, 'lng': 70.0900, 'powerKw': 60.0, 'price': 140, 'status': 'AVAILABLE'},
    {'name': 'Hapa Railway Station EV Hub', 'address': 'Hapa Railway Station Area, Jamnagar', 'lat': 22.4350, 'lng': 70.1200, 'powerKw': 60.0, 'price': 140, 'status': 'AVAILABLE'},
    {'name': 'Dwarkadhish Highway Express', 'address': 'Dwarka-Jamnagar Highway', 'lat': 22.4900, 'lng': 69.9800, 'powerKw': 60.0, 'price': 140, 'status': 'AVAILABLE'},
    {'name': 'Amber Cinema Square EV Point', 'address': 'Amber Cinema Road, Jamnagar', 'lat': 22.4730, 'lng': 70.0540, 'powerKw': 60.0, 'price': 140, 'status': 'AVAILABLE'},
    {'name': 'Vasant Vihar Green Charge', 'address': 'Vasant Vihar Society, Jamnagar', 'lat': 22.4880, 'lng': 70.0670, 'powerKw': 60.0, 'price': 140, 'status': 'AVAILABLE'},
    {'name': 'Janta Chowk VoltStation', 'address': 'Janta Chowk, Jamnagar', 'lat': 22.4650, 'lng': 70.0680, 'powerKw': 60.0, 'price': 140, 'status': 'AVAILABLE'},
  ];

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    // 1. Get Location & Request Permission
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (serviceEnabled && (permission == LocationPermission.always || permission == LocationPermission.whileInUse)) {
      try {
        Position position = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
        _currentLocation = LatLng(position.latitude, position.longitude);
      } catch (_) {}
    }

    // 2. Fetch Chargers from API
    try {
      final apiService = ApiService();
      final res = await apiService.get('/chargers');
      if (res['data'] is List && (res['data'] as List).isNotEmpty) {
        _chargers = List<Map<String, dynamic>>.from(res['data']);
      }
    } catch (_) {}

    // Fallback or combine with landmark data if API is empty
    if (_chargers.isEmpty) {
      _chargers = _jamnagarLandmarks.map((l) => {
        'name': l['name'],
        'status': l['status'],
        'powerKw': l['powerKw'],
        'pricePerHour': l['price'],
        'station': {
          'name': l['name'],
          'address': l['address'],
          'latitude': l['lat'],
          'longitude': l['lng'],
        }
      }).toList();
    }

    setState(() {
      _isLoading = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController.move(_currentLocation, 14.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jamnagar EV Chargers (Live Map)'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryDarkGreen))
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentLocation,
                    initialZoom: 14.0,
                    onTap: (tapPosition, point) {
                      setState(() {
                        _selectedCharger = null;
                      });
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.voltera.app',
                    ),
                    MarkerLayer(
                      markers: [
                        // Current Location Marker
                        Marker(
                          point: _currentLocation,
                          width: 45,
                          height: 45,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, spreadRadius: 2)],
                            ),
                            child: const Icon(Icons.my_location, color: Colors.white, size: 22),
                          ),
                        ),
                        // Glowing Charger Markers (Hotel-style search pins)
                        ..._chargers.map((c) {
                          final station = c['station'] ?? {};
                          final lat = (station['latitude'] as num?)?.toDouble() ?? 22.4720;
                          final lng = (station['longitude'] as num?)?.toDouble() ?? 70.0633;
                          final isAvailable = c['status'] == 'AVAILABLE';
                          final isSelected = _selectedCharger == c;

                          return Marker(
                            point: LatLng(lat, lng),
                            width: isSelected ? 70 : 55,
                            height: isSelected ? 70 : 55,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedCharger = c;
                                });
                                _mapController.move(LatLng(lat, lng), 15.5);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isAvailable ? AppColors.primaryDarkGreen : AppColors.error,
                                    width: isSelected ? 4 : 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (isAvailable ? AppColors.primaryDarkGreen : AppColors.error).withValues(alpha: 0.6),
                                      blurRadius: isSelected ? 12 : 8,
                                      spreadRadius: isSelected ? 4 : 2,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.ev_station,
                                    color: isAvailable ? AppColors.primaryDarkGreen : AppColors.error,
                                    size: isSelected ? 30 : 24,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
                
                // Bottom Details Panel
                if (_selectedCharger != null)
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  _selectedCharger!['name'] ?? 'EV Charger',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 20),
                                onPressed: () {
                                  setState(() {
                                    _selectedCharger = null;
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _selectedCharger!['station']?['address'] ?? 'Jamnagar Landmark Area',
                            style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _selectedCharger!['status'] == 'AVAILABLE' ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _selectedCharger!['status'] ?? 'UNKNOWN',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: _selectedCharger!['status'] == 'AVAILABLE' ? Colors.green : Colors.red,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${(_selectedCharger!['powerKw'] ?? 60.0)} kW • ₹${(_selectedCharger!['pricePerHour'] ?? 140)}/hr',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          VolteraButton(
                            text: 'Navigate & Book',
                            onPressed: () {
                              final station = _selectedCharger!['station'] ?? {};
                              final lat = (station['latitude'] as num?)?.toDouble() ?? 22.4720;
                              final lng = (station['longitude'] as num?)?.toDouble() ?? 70.0633;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ChargerMapScreen(),
                                  settings: RouteSettings(
                                    arguments: {
                                      'destinationName': _selectedCharger!['name'] ?? 'Charger',
                                      'destinationAddress': station['address'] ?? '',
                                      'destinationLat': lat,
                                      'destinationLng': lng,
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
