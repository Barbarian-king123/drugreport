import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../theme/app_theme.dart';
import '../../services/report_service.dart';
import '../../models/report_model.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  // Default center: Thiruvananthapuram (TVM), Kerala
  LatLng _mapCenter = const LatLng(8.5241, 76.9366);
  double _mapZoom = 14.0;
  bool _showList = false;
  Position? _currentPosition;
  String? _statusMessage;
  bool _permissionDenied = false;
  bool _isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    setState(() => _isLoadingLocation = true);
    final pos = await _determinePosition();
    if (!mounted) return;

    if (pos != null) {
      final target = LatLng(pos.latitude, pos.longitude);
      setState(() {
        _currentPosition = pos;
        _mapCenter = target;
        _mapZoom = 15.0;
        _isLoadingLocation = false;
      });

      _safeMoveMap(target, 15.0);
    } else {
      setState(() => _isLoadingLocation = false);
    }
  }

  void _safeMoveMap(LatLng target, double zoom) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        _mapController.move(target, zoom);
      } catch (e) {
        debugPrint('MapController move deferred: $e');
      }
    });
  }

  Future<void> _recenterOnUser() async {
    if (_currentPosition != null) {
      final target = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
      _safeMoveMap(target, 16.0);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Centered on your location'),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      await _initializeLocation();
    }
  }

  Future<Position?> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _statusMessage = 'Location services disabled. Turn on GPS to locate nearby reports.';
        _permissionDenied = true;
      });
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _statusMessage = 'Location permission denied. Grant location access to center map.';
          _permissionDenied = true;
        });
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _statusMessage = 'Location permission permanently denied. Open settings to grant access.';
        _permissionDenied = true;
      });
      return null;
    }

    setState(() {
      _statusMessage = null;
      _permissionDenied = false;
    });

    try {
      // First try quick last known position
      final lastPos = await Geolocator.getLastKnownPosition();
      if (lastPos != null) {
        _currentPosition = lastPos;
        _safeMoveMap(LatLng(lastPos.latitude, lastPos.longitude), 15.0);
      }
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );
    } catch (error) {
      if (_currentPosition != null) return _currentPosition;
      setState(() {
        _statusMessage = 'Unable to get live GPS location. Using Thiruvananthapuram (TVM) area.';
      });
      return Position(
        longitude: 76.9366,
        latitude: 8.5241,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: const Text(
          'Live Incident Map',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(_showList ? Icons.map_outlined : Icons.format_list_bulleted_rounded),
            tooltip: _showList ? 'Show Live Map' : 'Show List View',
            onPressed: () => setState(() => _showList = !_showList),
          ),
        ],
      ),
      body: _showList ? _buildListView() : _buildMapView(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _recenterOnUser,
        backgroundColor: AppColors.primaryCoral,
        foregroundColor: AppColors.onCoralText,
        icon: _isLoadingLocation
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.onCoralText,
                ),
              )
            : const Icon(Icons.my_location_rounded, size: 20),
        label: const Text(
          'Recenter',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
        ),
      ),
    );
  }

  Widget _buildMapView() {
    return StreamBuilder<List<ReportModel>>(
      stream: ReportService().nearbyReports(),
      builder: (context, snapshot) {
        final reports = snapshot.data ?? [];
        final markers = <Marker>[];

        // Add user location pulse marker
        if (_currentPosition != null) {
          markers.add(
            Marker(
              point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
              width: 50,
              height: 50,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.trustGreen.withValues(alpha: 0.25),
                    ),
                  ),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.trustGreen,
                      border: Border.all(color: Colors.white, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.trustGreen.withValues(alpha: 0.5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Add incident report markers
        for (final r in reports) {
          final loc = r.location;
          if (loc != null) {
            final rawLat = loc['latitude'] ?? loc['lat'];
            final rawLng = loc['longitude'] ?? loc['lng'];
            if (rawLat != null && rawLng != null) {
              final lat = (rawLat as num).toDouble();
              final lng = (rawLng as num).toDouble();
              markers.add(
                Marker(
                  point: LatLng(lat, lng),
                  width: 40,
                  height: 40,
                  child: GestureDetector(
                    onTap: () {
                      _safeMoveMap(LatLng(lat, lng), 16.0);
                      _showReportDetailsSheet(r);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.criticalRed,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.criticalRed.withValues(alpha: 0.4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              );
            }
          }
        }

        return Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _mapCenter,
                initialZoom: _mapZoom,
                maxZoom: 18.0,
                minZoom: 3.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.yourcompany.drugreport',
                ),
                MarkerLayer(markers: markers),
              ],
            ),
            if (_statusMessage != null) _buildStatusBanner(),
          ],
        );
      },
    );
  }

  Widget _buildStatusBanner() {
    return Positioned(
      left: 16,
      right: 16,
      top: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.surfaceBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 12,
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.location_off_outlined, color: AppColors.highPriorityAmber, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _statusMessage ?? '',
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
              ),
            ),
            if (_permissionDenied)
              TextButton(
                onPressed: () => Geolocator.openAppSettings(),
                child: const Text('Settings', style: TextStyle(color: AppColors.primaryCoral, fontSize: 12)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView() {
    return StreamBuilder<List<ReportModel>>(
      stream: ReportService().nearbyReports(),
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(
            child: Text('Error loading reports: ${snap.error}',
                style: const TextStyle(color: AppColors.criticalRed)),
          );
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryCoral));
        }

        final reports = snap.data!;
        if (reports.isEmpty) {
          return const Center(
            child: Text(
              'No active reports found in your immediate area.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reports.length,
          itemBuilder: (context, i) {
            final r = reports[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  r.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    'Status: ${r.verdict.toUpperCase()}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                trailing: const Icon(Icons.chevron_right, color: AppColors.primaryCoral),
                onTap: () => _showReportDetailsSheet(r),
              ),
            );
          },
        );
      },
    );
  }

  void _showReportDetailsSheet(ReportModel r) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Incident Marker',
                    style: TextStyle(
                      color: AppColors.primaryCoral,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.criticalRed.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      r.verdict.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.criticalRed,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                r.description,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
