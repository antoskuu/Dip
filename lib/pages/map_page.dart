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
import 'package:image_picker/image_picker.dart';
import 'package:exif/exif.dart';

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
  bool _isImporting = false;
  String? _importStatus;

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
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DipPreviewSheet(dip: dip),
    );
    if (result == 'deleted' || result == 'updated') {
      _loadDips();
    }
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

  Future<void> _importPhotos() async {
    setState(() {
      _isImporting = true;
      _importStatus = 'Analyse de l\'image...';
    });
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked == null) {
        setState(() {
          _isImporting = false;
          _importStatus = null;
        });
        return;
      }
      final path = picked.path;
      final bytes = await File(path).readAsBytes();
      Map<String, IfdTag> tags = {};
      try {
        tags = await readExifFromBytes(bytes).timeout(const Duration(seconds: 8));
      } catch (e) {
        setState(() {
          _isImporting = false;
          _importStatus = 'Erreur lors de l\'analyse des métadonnées.';
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur lors de l\'analyse des métadonnées EXIF.')),
          );
        }
        await Future.delayed(const Duration(seconds: 2));
        setState(() {
          _importStatus = null;
        });
        return;
      }
      double? lat;
      double? lng;
      DateTime? date;
      String? name;
      // Extraction géoloc
      if (tags.containsKey('GPS GPSLatitude') && tags.containsKey('GPS GPSLongitude')) {
        var latVals = tags['GPS GPSLatitude']!.values.toList();
        var lngVals = tags['GPS GPSLongitude']!.values.toList();
        double toDouble(dynamic v) {
          if (v is Ratio) return v.numerator / v.denominator;
          if (v is num) return v.toDouble();
          return double.tryParse(v.toString()) ?? double.nan;
        }
        double latDeg = toDouble(latVals[0]);
        double latMin = toDouble(latVals[1]);
        double latSec = toDouble(latVals[2]);
        double lngDeg = toDouble(lngVals[0]);
        double lngMin = toDouble(lngVals[1]);
        double lngSec = toDouble(lngVals[2]);
        lat = latDeg + latMin / 60 + latSec / 3600;
        lng = lngDeg + lngMin / 60 + lngSec / 3600;
        if (tags['GPS GPSLatitudeRef']?.printable == 'S') lat = -lat;
        if (tags['GPS GPSLongitudeRef']?.printable == 'W') lng = -lng;
      }
      // Extraction date
      if (tags.containsKey('Image DateTime')) {
        try {
          final dateStr = tags['Image DateTime']!.printable;
          final fixed = dateStr.replaceFirst(':', '-', 4).replaceFirst(':', '-', 7);
          date = DateTime.parse(fixed);
        } catch (_) {}
      }
      // Extraction nom du lieu (si possible)
      name = tags['Image ImageDescription']?.printable ?? picked.name.split('.').first;
      bool latValid = lat != null && lat.isFinite && !lat.isNaN;
      bool lngValid = lng != null && lng.isFinite && !lng.isNaN;
      if (latValid && lngValid) {
        final dip = Dip(
          name: (name != null && name.trim().isNotEmpty) ? name : 'Lieu de la photo',
          description: '',
          latitude: lat,
          longitude: lng,
          rating: 3,
          date: date ?? DateTime.now(),
          photoPath: path.isNotEmpty ? path : null,
        );
        try {
          await DipDatabase.instance.createDip(dip);
          await _loadDips();
          setState(() {
            _isImporting = false;
            _importStatus = 'Dip ajouté avec succès à partir de la photo.';
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Import terminé.')),
            );
          }
          await Future.delayed(const Duration(seconds: 2));
          setState(() {
            _importStatus = null;
          });
        } catch (e) {
          setState(() {
            _isImporting = false;
            _importStatus = 'Erreur lors de l\'enregistrement dans la base.';
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erreur SQLite :\n$e')),
            );
          }
          await Future.delayed(const Duration(seconds: 2));
          setState(() {
            _importStatus = null;
          });
        }
      } else {
        setState(() {
          _isImporting = false;
          _importStatus = 'Aucune géolocalisation valide trouvée dans la photo.';
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Aucune géolocalisation valide trouvée dans la photo.')),
          );
        }
        await Future.delayed(const Duration(seconds: 2));
        setState(() {
          _importStatus = null;
        });
      }
    } catch (e) {
      setState(() {
        _isImporting = false;
        _importStatus = 'Erreur inattendue lors de l\'import.';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur inattendue lors de l\'import :\n$e')),
        );
      }
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        _importStatus = null;
      });
    }
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
          bottom: 104,
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
                          onTap: _isImporting ? null : _importPhotos,
                          child: Container(
                            width: 56,
                            height: 56,
                            alignment: Alignment.center,
                            child: _isImporting
                                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                                : Icon(Icons.photo_library_rounded, size: 26, color: Colors.blue[700]),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (_importStatus != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.07),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(_importStatus!, style: TextStyle(color: Colors.blue[900], fontWeight: FontWeight.w500)),
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