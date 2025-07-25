import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:ui';
import '../models/dip.dart';
import '../services/dip_database.dart';
import '../utils/localization.dart';
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
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();
  bool _loading = true;
  int? _bouncingMarkerIndex;
  LatLng? _addDipLocation;
  bool _isLocating = false;

  // Map style management
  int _currentMapStyleIndex = 0;
  final List<Map<String, String>> _mapStyles = [
    {
      'name': 'Standard',
      'url': 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      'attribution': '© OpenStreetMap contributors',
    },
    {
      'name': 'Topo',
      'url': 'https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png',
      'attribution': '© OpenTopoMap contributors',
    },
    {
      'name': 'Satellite',
      'url': 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
      'attribution': '© Esri, Maxar, Earthstar Geographics',
    },
  ];

  late FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _loadDips();
    _searchFocusNode = FocusNode();
  }

  Future<void> _searchAndMoveToCity(String query) async {
    if (query.isEmpty) return;
    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final location = locations.first;
        _mapController.move(LatLng(location.latitude, location.longitude), 10.0);
        _searchFocusNode.unfocus();
        _searchController.clear();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)?.cityNotFound ?? 'Ville non trouvée.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)?.searchError ?? 'Erreur lors de la recherche.')),
        );
      }
    }
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

  void _toggleMapStyle() {
    setState(() {
      _currentMapStyleIndex = (_currentMapStyleIndex + 1) % _mapStyles.length;

    });
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)?.locationPermissionDenied ?? 'Permission de localisation refusée.')));
      }
      return;
    }
    
    try {
      // Essayer d'abord la dernière position connue (plus rapide)
      Position? lastKnownPosition = await Geolocator.getLastKnownPosition();
      
      if (lastKnownPosition != null) {
        final latLng = LatLng(lastKnownPosition.latitude, lastKnownPosition.longitude);
        _mapController.move(latLng, 13.0);
      } else {
        // Si pas de dernière position, utiliser une position approximative (plus rapide)
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
          timeLimit: const Duration(seconds: 5),
        );
        final latLng = LatLng(pos.latitude, pos.longitude);
        _mapController.move(latLng, 13.0);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d\'obtenir la position.')),
        );
      }
    }
    
    setState(() => _isLocating = false);
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: const LatLng(46.2276, 2.2137), // France
                initialZoom: 5.5,
                onTap: (tapPosition, point) {
                  if (_searchFocusNode.hasFocus) {
                    _searchFocusNode.unfocus();
                  } else {
                    setState(() {
                      _addDipLocation = point;
                    });
                  }
                },
                interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
              children: [
            TileLayer(
              urlTemplate: _mapStyles[_currentMapStyleIndex]['url']!,
              subdomains: const ['a', 'b', 'c'],
              userAgentPackageName: 'com.example.dip_app',
            ),
            if (_addDipLocation != null)
              MarkerLayer(
                markers: [
                  Marker(
                    width: 30,
                    height: 30,
                    point: _addDipLocation!,
                    child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Ping circle
                          Container(
                            width: 20,
                            height: 20,
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                        // Ping tail
                        Positioned(
                          bottom: 0,
                          child: Container(
                            width: 3,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(2),
                                bottomRight: Radius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
                              colors: [Colors.white, Colors.blue[50]!],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4)),
                              BoxShadow(color: Colors.blue.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2)),
                            ],
                            border: Border.all(color: Colors.blue[200]!, width: 2),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: dip.photoPath != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.file(File(dip.photoPath!), width: 48, height: 48, fit: BoxFit.cover),
                                )
                              : Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    gradient: LinearGradient(
                                      colors: [Colors.blue[100]!, Colors.blue[200]!],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: const Icon(Icons.pool_rounded, color: Colors.white, size: 28),
                                ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        // Search Bar
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: 16,
          right: 16,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.3),
                    width: 1,
                  ),
                ),
              child: TextField(
                focusNode: _searchFocusNode,
                controller: _searchController,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)?.searchCity ?? 'Rechercher une ville...',
                  hintStyle: TextStyle(
                    color: Colors.black.withOpacity(0.6),
                    fontSize: 16,
                  ),
                  prefixIcon: Icon(Icons.search, color: Colors.black.withOpacity(0.7)),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.black.withOpacity(0.7)),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
                onSubmitted: (value) => _searchAndMoveToCity(value),
              ),
            ),
          ),
        ),
      ),
        if (_loading)
          const Center(child: CircularProgressIndicator()),
        if (!_loading)
          Positioned(
            bottom: 100,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: 'toggle_layers',
                  onPressed: _toggleMapStyle,
                  child: const Icon(Icons.layers),
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: 'center_on_user',
                  onPressed: _centerOnUser,
                  child: _isLocating
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.my_location),
                ),
              ],
            ),
          ),

        if (_addDipLocation != null)
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add_location_alt),
                    label: Text(AppLocalizations.of(context)?.addThisDip ?? 'Ajouter ce dip'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 0,
                    ),
                  onPressed: () {
                    _onAddDip(_addDipLocation!);
                  },
                ),
              ),
            ),
          ),
          ],
        ),
    );
  }
}