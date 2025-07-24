import 'package:flutter/material.dart';

class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Fonctionnalités à venir',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.cyan[700],
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}