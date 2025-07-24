class Dip {
  final int? id;
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final int rating;
  final String? photoPath;
  final DateTime date;

  Dip({
    this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.rating,
    this.photoPath,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'rating': rating,
      'photoPath': photoPath,
      'date': date.toIso8601String(),
    };
  }

  factory Dip.fromMap(Map<String, dynamic> map) {
    return Dip(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      rating: map['rating'],
      photoPath: map['photoPath'],
      date: DateTime.parse(map['date']),
    );
  }
}