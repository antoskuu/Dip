import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/dip.dart';

class DipPreviewSheet extends StatefulWidget {
  final Dip dip;
  const DipPreviewSheet({super.key, required this.dip});

  @override
  State<DipPreviewSheet> createState() => _DipPreviewSheetState();
}

class _DipPreviewSheetState extends State<DipPreviewSheet> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnim = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _opacityAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Blur du fond
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _opacityAnim,
            builder: (context, child) => BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8 * _opacityAnim.value, sigmaY: 8 * _opacityAnim.value),
              child: Container(
                color: Colors.black.withValues(alpha: 0.13 * _opacityAnim.value),
              ),
            ),
          ),
        ),
        DraggableScrollableSheet(
          initialChildSize: 0.38,
          minChildSize: 0.25,
          maxChildSize: 0.7,
          builder: (context, scrollController) {
            return AnimatedBuilder(
              animation: _scaleAnim,
              builder: (context, child) => AnimatedPadding(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
                padding: EdgeInsets.only(top: 40 * (1 - _scaleAnim.value)),
                child: Transform.scale(
                  scale: _scaleAnim.value,
                  child: Opacity(
                    opacity: _opacityAnim.value,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.97),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 24,
                            offset: Offset(0, -8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Center(
                              child: Container(
                                width: 40,
                                height: 4,
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Hero(
                                  tag: 'dip_${widget.dip.id ?? widget.dip.name}_${widget.dip.latitude}_${widget.dip.longitude}',
                                  child: widget.dip.photoPath != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(20),
                                          child: Image.file(
                                            File(widget.dip.photoPath!),
                                            width: 90,
                                            height: 90,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Container(
                                          width: 90,
                                          height: 90,
                                          decoration: BoxDecoration(
                                            color: Colors.blue[50],
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: const Icon(Icons.place, color: Colors.blue, size: 48),
                                        ),
                                ),
                                const SizedBox(width: 18),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.dip.name,
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue[800],
                                            ),
                                        textAlign: TextAlign.left,
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Icon(Icons.star_rounded, color: Colors.amber[600], size: 22),
                                          const SizedBox(width: 4),
                                          Text('${widget.dip.rating}/5', style: const TextStyle(fontWeight: FontWeight.w600)),
                                          const SizedBox(width: 12),
                                          Icon(Icons.calendar_today_rounded, size: 18, color: Colors.grey[400]),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${widget.dip.date.day.toString().padLeft(2, '0')}/${widget.dip.date.month.toString().padLeft(2, '0')}/${widget.dip.date.year}',
                                            style: const TextStyle(fontSize: 13, color: Colors.black54),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            if (widget.dip.description.isNotEmpty)
                              Center(
                                child: Text(
                                  widget.dip.description,
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.blue[900]),
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            if (widget.dip.description.isEmpty)
                              Center(
                                child: Text(
                                  'Aucune description',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[400]),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}