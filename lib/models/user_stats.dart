class UserStats {
  int xp;
  int dipsCount;
  DateTime? lastDipDate;
  List<String> badges;

  UserStats({
    this.xp = 0,
    this.dipsCount = 0,
    this.lastDipDate,
    List<String>? badges,
  }) : badges = badges ?? [];

  // Méthode pour convertir en Map pour la base de données
  Map<String, dynamic> toMap() {
    return {
      'id': 1, // Singleton ID
      'xp': xp,
      'dipsCount': dipsCount,
    };
  }

  // Méthode pour créer depuis une Map
  factory UserStats.fromMap(Map<String, dynamic> map) {
    return UserStats(
      xp: map['xp'],
      dipsCount: map['dipsCount'],
      // Badges and lastDipDate will be handled separately if needed
    );
  }
}