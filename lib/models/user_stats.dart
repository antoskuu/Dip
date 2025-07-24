class UserStats {
  int xp;
  int dipsCount;
  int dailyChallengeStreak;
  DateTime? lastDipDate;
  List<String> badges;
  List<DailyChallenge> dailyChallenges;

  UserStats({
    this.xp = 0,
    this.dipsCount = 0,
    this.dailyChallengeStreak = 0,
    this.lastDipDate,
    List<String>? badges,
    List<DailyChallenge>? dailyChallenges,
  })  : badges = badges ?? [],
        dailyChallenges = dailyChallenges ?? [];
}

class DailyChallenge {
  final String description;
  final bool completed;

  DailyChallenge({required this.description, this.completed = false});
}