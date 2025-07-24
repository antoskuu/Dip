import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:ui';
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Permission de localisation refusée.')));
      }
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
            initialCenter: dips.isNotEmpty
                ? LatLng(dips.last.latitude, dips.last.longitude)
                : const LatLng(54.5260, 15.2551), // centre de l'Europe
            initialZoom: dips.isNotEmpty ? 6.5 : 3.5, // zoom plus large pour voir toute l'Europe
            onTap: (tapPosition, point) {
              setState(() => _addDipLocation = point);
            },
            interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
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
                  child: Center(
                    child: AnimatedScale(
                      scale: isBouncing ? 1.25 : 1.0,
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.elasticOut,
                      child: GestureDetector(
                        onTap: () => _onTapDip(dip, idx),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white,
                                Colors.blue[50]!,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                              BoxShadow(
                                color: Colors.blue.withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            border: Border.all(
                              color: Colors.blue[200]!,
                              width: 2,
                            ),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: dip.photoPath != null
                              ? Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: Image.file(
                                        File(dip.photoPath!),
                                        width: 48,
                                        height: 48,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(14),
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.transparent,
                                            Colors.blue.withValues(alpha: 0.1),
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.blue[100]!,
                                        Colors.blue[200]!,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.water_drop_rounded,
                                    color: Colors.blue[600],
                                    size: 26,
                                  ),
                                ),
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
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue[100]!,
                            Colors.blue[200]!,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.blue[400]!, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.8),
                            blurRadius: 8,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        Icons.add_location_alt_rounded,
                        color: Colors.blue[700],
                        size: 32,
                      ),
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
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue[600]!.withValues(alpha: 0.95),
                            Colors.blue[800]!.withValues(alpha: 0.95),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.add_location_alt_rounded, size: 24),
                        label: const Text(
                          'Ajouter un Dip ici',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            letterSpacing: 0.5,
                          ),
                        ),
                        onPressed: () => _onAddDip(_addDipLocation!),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        if (_loading)
          const Center(child: CircularProgressIndicator()),
        Positioned(
          bottom: 32,
          right: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: _isLocating ? null : _centerOnUser,
                          child: Container(
                            width: 56,
                            height: 56,
                            alignment: Alignment.center,
                            child: _isLocating
                                ? const SizedBox(
                                    width: 24, 
                                    height: 24, 
                                    child: CircularProgressIndicator(strokeWidth: 2)
                                  )
                                : Icon(Icons.my_location, size: 26, color: Colors.blue[700]),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue[700]!.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.blue[300]!.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: () async {
                            if (dips.isNotEmpty) {
                              _mapController.move(
                                LatLng(dips.last.latitude, dips.last.longitude),
                                12.0,
                              );
                            } else {
                              _mapController.move(const LatLng(45.75, 4.85), 10.0);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.place, size: 20, color: Colors.white),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Dernier Dip',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}