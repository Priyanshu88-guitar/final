import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/common/voltera_button.dart';

class ChargerMapScreen extends StatefulWidget {
  const ChargerMapScreen({super.key});

  @override
  State<ChargerMapScreen> createState() => _ChargerMapScreenState();
}

class _ChargerMapScreenState extends State<ChargerMapScreen> {
  GoogleMapController? _mapController;
  bool _isLoadingLocation = true;

  // Exact test coordinates as requested
  static const LatLng _customerTestCoords = LatLng(22.4991315, 70.0447841);
  static const LatLng _providerTestCoords = LatLng(22.464432, 70.043333);

  LatLng _origin = _customerTestCoords;
  LatLng _destination = _providerTestCoords;
  String _destinationName = 'VOLTERA Charging Station - SG Highway';

  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
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
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      LocationPermission permission = await Geolocator.checkPermission();
      if (serviceEnabled && (permission == LocationPermission.always || permission == LocationPermission.whileInUse)) {
        Position position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
        );
        _origin = LatLng(position.latitude, position.longitude);
      } else {
        _origin = _customerTestCoords;
      }
    } catch (_) {
      _origin = _customerTestCoords;
    }

    if (mounted) {
      setState(() {
        _isLoadingLocation = false;
      });
    }

    _calculateDistanceAndETA();
    _buildMapElements();
  }

  void _calculateDistanceAndETA() {
    double distanceMeters = Geolocator.distanceBetween(
      _origin.latitude,
      _origin.longitude,
      _destination.latitude,
      _destination.longitude,
    );
    _distanceKm = distanceMeters / 1000.0;

    double hours = _distanceKm / 40.0;
    int minutes = (hours * 60).round();
    if (minutes < 1) minutes = 1;
    _etaText = '$minutes mins (${_distanceKm.toStringAsFixed(1)} km)';
  }

  bool _isValidLat(double lat) => lat >= -90 && lat <= 90;
  bool _isValidLng(double lng) => lng >= -180 && lng <= 180;

  void _buildMapElements() {
    final Set<Marker> markers = {};
    final Set<Polyline> polylines = {};

    if (_isValidLat(_origin.latitude) && _isValidLng(_origin.longitude)) {
      markers.add(
        Marker(
          markerId: const MarkerId('origin-marker'),
          position: _origin,
          infoWindow: const InfoWindow(title: 'Your Location (Customer)', snippet: '22.4991315, 70.0447841'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      );
    }

    if (_isValidLat(_destination.latitude) && _isValidLng(_destination.longitude)) {
      markers.add(
        Marker(
          markerId: const MarkerId('destination-marker'),
          position: _destination,
          infoWindow: InfoWindow(title: _destinationName, snippet: '22.464432, 70.043333'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );
    }

    polylines.add(
      Polyline(
        polylineId: const PolylineId('route-polyline'),
        points: [_origin, _destination],
        color: AppColors.primaryDarkGreen,
        width: 5,
      ),
    );

    if (mounted) {
      setState(() {
        _markers = markers;
        _polylines = polylines;
      });
    }

    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(
              _origin.latitude < _destination.latitude ? _origin.latitude : _destination.latitude,
              _origin.longitude < _destination.longitude ? _origin.longitude : _destination.longitude,
            ),
            northeast: LatLng(
              _origin.latitude > _destination.latitude ? _origin.latitude : _destination.latitude,
              _origin.longitude > _destination.longitude ? _origin.longitude : _destination.longitude,
            ),
          ),
          80.0,
        ),
      );
    }
  }

  Future<void> _launchExternalGoogleMaps() async {
    final String url = 'https://www.google.com/maps/dir/?api=1&origin=${_origin.latitude},${_origin.longitude}&destination=${_destination.latitude},${_destination.longitude}&travelmode=driving';
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Google Maps app.'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error launching navigation: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text('Live Navigation Map'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location, color: AppColors.primaryDarkGreen),
            onPressed: () {
              if (_mapController != null) {
                _mapController!.animateCamera(
                  CameraUpdate.newLatLngZoom(_origin, 15.0),
                );
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _destination,
              zoom: 14.0,
            ),
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
            onMapCreated: (controller) {
              _mapController = controller;
              _buildMapElements();
            },
          ),

          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 12, offset: const Offset(0, 4)),
                ],
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
                          _destinationName,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryDarkGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _etaText,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryDarkGreen),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Destination: ${_destination.latitude.toStringAsFixed(6)}, ${_destination.longitude.toStringAsFixed(6)}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            if (_mapController != null) {
                              _mapController!.animateCamera(
                                CameraUpdate.newLatLngZoom(_destination, 15.0),
                              );
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: AppColors.primaryDarkGreen),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('View Destination', style: TextStyle(color: AppColors.primaryDarkGreen, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: VolteraButton(
                          text: 'Start Navigation',
                          onPressed: _launchExternalGoogleMaps,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          if (_isLoadingLocation)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2)),
                  ],
                ),
                child: Row(
                  children: const [
                    SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                    SizedBox(width: 12),
                    Text('Loading live route...', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
