import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../models/dip.dart';
import '../services/dip_database.dart';
import '../widgets/add_dip_sheet.dart';
import '../widgets/dip_preview_sheet.dart';
import 'dart:io';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  List<Dip> dips = [];
  final MapController _mapController = MapController();
  bool _loading = true;
  int? _bouncingMarkerIndex;
  LatLng? _addDipLocation;
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    _loadDips();
  }

  Future<void> _loadDips() async {
    setState(() => _loading = true);
    dips = await DipDatabase.instance.getAllDips();
    setState(() => _loading = false);
  }

  void _onAddDip(LatLng location) async {
    final result = await showModalBottomSheet<Dip>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddDipSheet(location: location),
    );
    if (result != null) {
      await DipDatabase.instance.createDip(result);
      _loadDips();
    }
    setState(() => _addDipLocation = null);
  }

  void _onTapDip(Dip dip, int index) async {
    setState(() => _bouncingMarkerIndex = index);
    await Future.delayed(const Duration(milliseconds: 180));
    setState(() => _bouncingMarkerIndex = null);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DipPreviewSheet(dip: dip),
    );
  }

  Future<void> _centerOnUser() async {
    setState(() => _isLocating = true);
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
      setState(() => _isLocating = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Permission de localisation refusée.')));
      return;
    }
    final pos = await Geolocator.getCurrentPosition();
    final latLng = LatLng(pos.latitude, pos.longitude);
    _mapController.move(latLng, 13.0);
    setState(() => _isLocating = false);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            center: dips.isNotEmpty
                ? LatLng(dips.last.latitude, dips.last.longitude)
                : LatLng(45.75, 4.85),
            zoom: 6.5,
            onTap: (tapPosition, point) {
              setState(() => _addDipLocation = point);
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.dip_app',
            ),
            MarkerLayer(
              markers: dips.asMap().entries.map((entry) {
                final dip = entry.value;
                final idx = entry.key;
                final isBouncing = _bouncingMarkerIndex == idx;
                return Marker(
                  width: 70,
                  height: 70,
                  point: LatLng(dip.latitude, dip.longitude),
                  builder: (ctx) => Center(
                    child: AnimatedScale(
                      scale: isBouncing ? 1.25 : 1.0,
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.elasticOut,
                      child: GestureDetector(
                        onTap: () => _onTapDip(dip, idx),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.10),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            border: Border.all(color: Colors.blue[100]!, width: 2),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: dip.photoPath != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.file(
                                    File(dip.photoPath!),
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Icon(Icons.place, color: Colors.blue[400], size: 38),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList()
              + (_addDipLocation != null ? [
                Marker(
                  width: 60,
                  height: 60,
                  point: _addDipLocation!,
                  builder: (ctx) => Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blue, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(Icons.add_location_alt_rounded, color: Colors.blue, size: 36),
                    ),
                  ),
                )
              ] : []),
            ),
          ],
        ),
        if (_addDipLocation != null)
          Positioned(
            bottom: 110,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  elevation: 8,
                ),
                icon: const Icon(Icons.add),
                label: const Text('Ajouter un Dip ici'),
                onPressed: () => _onAddDip(_addDipLocation!),
              ),
            ),
          ),
        if (_loading)
          const Center(child: CircularProgressIndicator()),
        Positioned(
          bottom: 32,
          right: 32,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                heroTag: 'center_gps',
                onPressed: _isLocating ? null : _centerOnUser,
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue[700],
                child: _isLocating
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.my_location),
              ),
              const SizedBox(height: 16),
              FloatingActionButton.extended(
                heroTag: 'center_last',
                onPressed: () async {
                  if (dips.isNotEmpty) {
                    _mapController.move(
                      LatLng(dips.last.latitude, dips.last.longitude),
                      12.0,
                    );
                  } else {
                    _mapController.move(LatLng(45.75, 4.85), 10.0);
                  }
                },
                icon: const Icon(Icons.place),
                label: const Text('Dernier Dip'),
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
              ),
            ],
          ),
        ),
      ],
    );
  }
}