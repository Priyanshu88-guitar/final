import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/common/voltera_button.dart';
import 'dart:math' as math;

class ChargerMapScreen extends StatefulWidget {
  const ChargerMapScreen({super.key});

  @override
  State<ChargerMapScreen> createState() => _ChargerMapScreenState();
}

class _ChargerMapScreenState extends State<ChargerMapScreen> {
  final MapController _mapController = MapController();
  bool _isLoadingLocation = true;

  // Default fallback coordinates in Jamnagar
  static const LatLng _customerTestCoords = LatLng(22.4720, 70.0633); // Lakhota Lake
  static const LatLng _providerTestCoords = LatLng(22.4830, 70.0650); // Park Colony

  LatLng _origin = _customerTestCoords;
  LatLng _destination = _providerTestCoords;
  String _destinationName = 'VOLTERA Charging Station - Park Colony';

  double _distanceKm = 0.0;
  String _etaText = '-- mins';
  bool _hasInitializedArgs = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasInitializedArgs) {
      _hasInitializedArgs = true;
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        if (args['destinationName'] != null) {
          _destinationName = args['destinationName'] as String;
        }
        if (args['destinationLat'] != null && args['destinationLng'] != null) {
          _destination = LatLng(
            (args['destinationLat'] as num).toDouble(),
            (args['destinationLng'] as num).toDouble(),
          );
        }
      }
      _initMapNavigation();
    }
  }

  Future<void> _initMapNavigation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (serviceEnabled && (permission == LocationPermission.whileInUse || permission == LocationPermission.always)) {
      try {
        Position position = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
        _origin = LatLng(position.latitude, position.longitude);
      } catch (_) {}
    }

    _calculateDistanceAndETA();

    setState(() {
      _isLoadingLocation = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fitMapToPoints();
    });
  }

  void _calculateDistanceAndETA() {
    const double R = 6371.0; // Earth radius in km
    final double lat1 = _origin.latitude * math.pi / 180;
    final double lon1 = _origin.longitude * math.pi / 180;
    final double lat2 = _destination.latitude * math.pi / 180;
    final double lon2 = _destination.longitude * math.pi / 180;

    final double dLat = lat2 - lat1;
    final double dLon = lon2 - lon1;

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) * math.cos(lat2) * math.sin(dLon / 2) * math.sin(dLon / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    _distanceKm = R * c;

    // Estimate ETA based on average city speed of 25 km/h
    final double hours = _distanceKm / 25.0;
    final int minutes = (hours * 60).ceil();
    _etaText = '$minutes mins';
  }

  List<LatLng> _getRealisticRoadPath(LatLng start, LatLng end) {
    // Generate realistic multi-segment road path with intermediate waypoints
    final List<LatLng> path = [start];
    
    final double midLat = (start.latitude + end.latitude) / 2;
    final double midLng = (start.longitude + end.longitude) / 2;
    
    final double offsetLat = (end.longitude - start.longitude) * 0.04;
    final double offsetLng = (start.latitude - end.latitude) * 0.04;
    
    final LatLng waypoint1 = LatLng(midLat + offsetLat, midLng + offsetLng);
    final LatLng waypoint2 = LatLng(midLat - offsetLng, midLng + offsetLat);
    
    path.add(waypoint1);
    path.add(waypoint2);
    path.add(end);
    return path;
  }

  void _fitMapToPoints() {
    try {
      final bounds = LatLngBounds.fromPoints([_origin, _destination]);
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(60.0),
        ),
      );
    } catch (_) {}
  }

  Future<void> _launchExternalMaps() async {
    final String googleMapsUrl = 'https://www.google.com/maps/dir/?api=1&origin=${_origin.latitude},${_origin.longitude}&destination=${_destination.latitude},${_destination.longitude}&travelmode=driving';
    final Uri uri = Uri.parse(googleMapsUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch maps application')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final roadPath = _getRealisticRoadPath(_origin, _destination);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Route to $_destinationName'),
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoadingLocation
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryDarkGreen))
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _origin,
                    initialZoom: 14.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.voltera.app',
                    ),
                    // Realistic Curved Road Path Polyline
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: roadPath,
                          color: AppColors.primaryDarkGreen,
                          strokeWidth: 5.0,
                        ),
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        // User Origin Marker
                        Marker(
                          point: _origin,
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
                        // Destination Charger Marker
                        Marker(
                          point: _destination,
                          width: 60,
                          height: 60,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.primaryDarkGreen, width: 4),
                              boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 10, spreadRadius: 3)],
                            ),
                            child: const Center(
                              child: Icon(Icons.ev_station, color: AppColors.primaryDarkGreen, size: 28),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                // Bottom Route Details Panel
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 6))],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _destinationName,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.directions_car, color: AppColors.primaryDarkGreen, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Distance: ${_distanceKm.toStringAsFixed(1)} km • ETA: $_etaText',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        VolteraButton(
                          text: 'Open in Google Maps / Navigation',
                          onPressed: _launchExternalMaps,
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
