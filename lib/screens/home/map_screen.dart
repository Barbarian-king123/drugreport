import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../services/report_service.dart';
import '../../models/report_model.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  LatLng _initialCenter = const LatLng(0, 0);
  double _initialZoom = 1.0;
  final List<Marker> _markers = [];
  bool _showList = false;
  Position? _currentPosition;
  String? _statusMessage;
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    final pos = await _determinePosition();
    if (pos == null) return;
    if (!mounted) return;

    _currentPosition = pos;
    _initialCenter = LatLng(pos.latitude, pos.longitude);
    _initialZoom = 15.0;
    _updateMarkers(pos);
    setState(() {});

    _moveMap(pos);
  }

  Future<Position?> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _statusMessage = 'Location services are disabled. Please enable them in your device settings.';
        _permissionDenied = true;
      });
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _statusMessage = 'Location permission denied. Allow location access to center the map on you.';
          _permissionDenied = true;
        });
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _statusMessage = 'Location permission permanently denied. Open app settings to allow location access.';
        _permissionDenied = true;
      });
      return null;
    }

    setState(() {
      _statusMessage = null;
      _permissionDenied = false;
    });

    try {
      return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    } catch (error) {
      setState(() {
        _statusMessage = 'Unable to get current location. ${error.toString()}';
      });
      return null;
    }
  }

  void _moveMap(Position pos) {
    _mapController.move(LatLng(pos.latitude, pos.longitude), 15.0);
  }

  void _updateMarkers(Position pos) {
    _markers
      ..clear()
      ..add(
        Marker(
          point: LatLng(pos.latitude, pos.longitude),
          width: 40,
          height: 40,
          child: const Icon(
            Icons.location_on,
            color: Colors.red,
            size: 40,
          ),
        ),
      );
  }

  Widget _buildStatusOverlay() {
    if (_statusMessage != null || _currentPosition == null) {
      final message = _statusMessage ?? 'Tap the button below to locate yourself and see nearby reports.';
      return Positioned(
        left: 16,
        right: 16,
        bottom: 24,
        child: Card(
          elevation: 4,
          color: Colors.white.withOpacity(0.95),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                if (_permissionDenied)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Geolocator.openAppSettings(),
                            child: const Text('Open app settings'),
                          ),
                        ),
                        Expanded(
                          child: TextButton(
                            onPressed: _initializeLocation,
                            child: const Text('Try again'),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (!_permissionDenied)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: TextButton(
                      onPressed: _initializeLocation,
                      child: const Text('Try again'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Reports'),
        actions: [
          IconButton(
            icon: Icon(_showList ? Icons.map_outlined : Icons.list_alt),
            tooltip: _showList ? 'Show map' : 'Show list',
            onPressed: () => setState(() => _showList = !_showList),
          ),
        ],
      ),
      body: _showList
          ? StreamBuilder<List<ReportModel>>(
              stream: ReportService().nearbyReports(),
              builder: (context, snap) {
                if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                final reports = snap.data!;
                if (reports.isEmpty) return const Center(child: Text('No nearby reports'));
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: reports.length,
                  itemBuilder: (context, i) {
                    final r = reports[i];
                    return Card(
                      child: ListTile(
                        title: Text(r.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                        subtitle: Text(r.verdict),
                        leading: r.imageUrls.isNotEmpty
                            ? Image.network(r.imageUrls.first, width: 56, height: 56, fit: BoxFit.cover)
                            : null,
                      ),
                    );
                  },
                );
              },
            )
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _initialCenter,
                    initialZoom: _initialZoom,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.yourcompany.drugreport',
                    ),
                    MarkerLayer(markers: _markers),
                  ],
                ),
                _buildStatusOverlay(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Center on my location',
        child: const Icon(Icons.my_location),
        onPressed: _initializeLocation,
      ),
    );
  }
}
