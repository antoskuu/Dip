import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/dip.dart';
import '../utils/temperature_utils.dart';
import 'package:latlong2/latlong.dart';
import '../services/user_stats_service.dart';

class AddDipSheet extends StatefulWidget {
  final LatLng location;
  final Dip? dip;
  const AddDipSheet({super.key, required this.location, this.dip});

  @override
  State<AddDipSheet> createState() => _AddDipSheetState();
}

class _AddDipSheetState extends State<AddDipSheet> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  double _rating = 3.0;
  int _temperature = 3;
  File? _imageFile;
  bool _picking = false;
  late AnimationController _buttonController;
  late Animation<double> _buttonScale;

  @override
  void initState() {
    super.initState();
    if (widget.dip != null) {
      _nameController.text = widget.dip!.name;
      _descController.text = widget.dip!.description ?? '';
      _rating = widget.dip!.rating;
      _temperature = widget.dip!.temperature;
      if (widget.dip!.photoPath != null) {
        _imageFile = File(widget.dip!.photoPath!);
      }
    }
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      lowerBound: 0.0,
      upperBound: 0.08,
    );
    _buttonScale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _buttonController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    setState(() => _picking = true);
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
    setState(() => _picking = false);
  }

  void _showSuccessFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 28),
            SizedBox(width: 12),
            Text('Dip ajouté avec succès !', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: Colors.blue[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(milliseconds: 1400),
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        elevation: 8,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 24,
                  offset: const Offset(0, -8),
                ),
              ],
              border: Border.all(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 50,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    Text(
                      'Ajouter un Dip',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                            letterSpacing: 0.5,
                          ),
                    ),
                    const SizedBox(height: 18),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: _picking ? null : _pickImage,
                        child: Ink(
                          width: double.infinity,
                          height: 160,
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.blue[200]!,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: _picking
                              ? const Center(child: CircularProgressIndicator())
                              : _imageFile != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.file(_imageFile!, fit: BoxFit.cover, width: double.infinity, height: 160),
                                    )
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_a_photo_rounded, color: Colors.blue[600], size: 38),
                                        const SizedBox(height: 8),
                                        Text('Ajouter une photo', style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _nameController,
                      style: TextStyle(color: Colors.grey[800]),
                      decoration: InputDecoration(
                        labelText: 'Nom du lieu',
                        labelStyle: TextStyle(color: Colors.grey[600]),
                        border: const OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
                        ),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Nom requis' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _descController,
                      style: TextStyle(color: Colors.grey[800]),
                      decoration: InputDecoration(
                        labelText: 'Description',
                        labelStyle: TextStyle(color: Colors.grey[600]),
                        border: const OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
                        ),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 18),
                    _buildRatingStars(),
                    const SizedBox(height: 18),
                    _buildTemperatureSelector(),
                    const SizedBox(height: 18),
                    Center(
                      child: GestureDetector(
                        onTapDown: (_) => _buttonController.forward(),
                        onTapUp: (_) => _buttonController.reverse(),
                        onTapCancel: () => _buttonController.reverse(),
                        child: ScaleTransition(
                          scale: _buttonScale,
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[700],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              icon: const Icon(Icons.check),
                              label: const Text('Ajouter'),
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  final dip = Dip(
                                    id: widget.dip?.id,
                                    name: _nameController.text,
                                    description: _descController.text,
                                    latitude: widget.location.latitude,
                                    longitude: widget.location.longitude,
                                    rating: _rating,
                                    temperature: _temperature,
                                    date: widget.dip?.date ?? DateTime.now(),
                                    photoPath: _imageFile?.path,
                                  );

                                  // Add XP and increment dips count if it's a new dip
                                  if (widget.dip == null) {
                                    await UserStatsService.instance.addXP(25);
                                    await UserStatsService.instance.incrementDips();
                                  }

                                  _showSuccessFeedback();
                                  Future.delayed(const Duration(milliseconds: 900), () {
                                    if (mounted) {
                                      Navigator.of(context).pop(dip);
                                    }
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24), // Espace supplémentaire pour le clavier
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRatingStars() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Note globale', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final starValue = index + 1;
            return IconButton(
              icon: Icon(
                _rating >= starValue ? Icons.star_rounded : _rating >= starValue - 0.5 ? Icons.star_half_rounded : Icons.star_border_rounded,
                color: Colors.amber,
                size: 36,
              ),
              onPressed: () {
                setState(() {
                  _rating = starValue.toDouble();
                });
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildTemperatureSelector() {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Température ressentie', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(5, (index) {
          return Column(
            children: [
              IconButton(
                icon: Text(TemperatureUtils.temperatureEmojis[index], style: const TextStyle(fontSize: 28)),
                  style: IconButton.styleFrom(
                    backgroundColor: _temperature == index + 1 ? Theme.of(context).colorScheme.primary.withOpacity(0.2) : Colors.transparent,
                  ),
                  onPressed: () {
                    setState(() {
                      _temperature = index + 1;
                    });
                  },
                ),
                Text(TemperatureUtils.temperatureLabels[index], style: Theme.of(context).textTheme.bodySmall)
              ],
            );
          }),
        ),
      ],
    );
  }
}