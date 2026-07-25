import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/report_service.dart';
import '../../models/report_model.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  CameraPosition _initialCamera = const CameraPosition(target: LatLng(0, 0), zoom: 1.0);
  final Set<Marker> _markers = {};
  bool _showList = false;
  Position? _currentPosition;
  Position? _pendingPosition;
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
    _pendingPosition = pos;
    _initialCamera = CameraPosition(target: LatLng(pos.latitude, pos.longitude), zoom: 15);
    setState(() {});

    if (_controller.isCompleted) {
      await _moveToPosition(pos);
      _pendingPosition = null;
    }
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

  Future<void> _moveToPosition(Position pos) async {
    final GoogleMapController controller = await _controller.future;
    if (!mounted) return;
    final camera = CameraPosition(target: LatLng(pos.latitude, pos.longitude), zoom: 15);
    try {
      await controller.animateCamera(CameraUpdate.newCameraPosition(camera));
    } catch (_) {
      return;
    }
    if (!mounted) return;
    setState(() {
      _markers.clear();
      _markers.add(Marker(markerId: const MarkerId('me'), position: LatLng(pos.latitude, pos.longitude), infoWindow: const InfoWindow(title: 'Your location')));
    });
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
                        leading: r.imageUrls.isNotEmpty ? Image.network(r.imageUrls.first, width: 56, height: 56, fit: BoxFit.cover) : null,
                      ),
                    );
                  },
                );
              },
            )
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: _initialCamera,
                  markers: _markers,
                  myLocationEnabled: !_permissionDenied,
                  myLocationButtonEnabled: false,
                  onMapCreated: (GoogleMapController controller) async {
                    if (!_controller.isCompleted) {
                      _controller.complete(controller);
                    }
                    if (_pendingPosition != null && mounted) {
                      await _moveToPosition(_pendingPosition!);
                      _pendingPosition = null;
                    }
                  },
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
