import 'package:flutter/material.dart';
import 'localization.dart';

class TemperatureUtils {
  static const List<String> temperatureEmojis = [
    '🥶', // 1 - Glaciale/Freezing
    '❄️', // 2 - Froide/Cold  
    '😊', // 3 - Bonne/Good
    '☀️', // 4 - Chaude/Warm
    '🔥', // 5 - Brûlante/Hot
  ];

  // Static fallback labels (French)
  static const List<String> _fallbackLabels = [
    'Glaciale',
    'Froide', 
    'Bonne',
    'Chaude',
    'Brûlante',
  ];

  // Get localized labels
  static List<String> getLocalizedLabels(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return localizations?.temperatureLabels ?? _fallbackLabels;
  }

  // Legacy getter for backward compatibility
  static List<String> get temperatureLabels => _fallbackLabels;

  static String getTemperatureEmoji(int temperature) {
    if (temperature >= 1 && temperature <= 5) {
      return temperatureEmojis[temperature - 1];
    }
    return temperatureEmojis[2]; // Par défaut "Bonne" (😊)
  }

  static String getTemperatureLabel(int temperature) {
    if (temperature >= 1 && temperature <= 5) {
      return temperatureLabels[temperature - 1];
    }
    return temperatureLabels[2]; // Par défaut "Bonne"
  }
}
