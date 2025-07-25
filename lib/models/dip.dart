class Dip {
  final int? id;
  final String name;
  final String? description;
  final double latitude;
  final double longitude;
  final double rating;
  final int temperature;
  final String? photoPath;
  final DateTime date;

  Dip({
    this.id,
    required this.name,
    this.description,
    required this.latitude,
    required this.longitude,
    required this.rating,
    required this.temperature,
    this.photoPath,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'rating': rating,
      'temperature': temperature,
      'photoPath': photoPath,
      'date': date.toIso8601String(),
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory Dip.fromMap(Map<String, dynamic> map) {
    return Dip(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      rating: (map['rating'] as num).toDouble(),
      temperature: map['temperature'] ?? 3, // Default to neutral if not present
      photoPath: map['photoPath'],
      date: DateTime.parse(map['date']),
    );
  }
}