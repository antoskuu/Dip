import '../models/user_stats.dart';

class UserStatsService {
  static final UserStatsService instance = UserStatsService._init();
  UserStats? _stats;

  UserStatsService._init();

  Future<UserStats> getStats() async {
    _stats ??= UserStats(
      xp: 0,
      dipsCount: 0,
      dailyChallengeStreak: 0,
      badges: [],
      dailyChallenges: [
        DailyChallenge(description: "Baignade dans un nouveau lieu aujourd'hui !"),
        DailyChallenge(description: "Ajoute une photo à ton Dip du jour !"),
      ],
    );
    return _stats!;
  }

  Future<void> addXP(int amount) async {
    final stats = await getStats();
    stats.xp += amount;
  }

  Future<void> addBadge(String badge) async {
    final stats = await getStats();
    if (!stats.badges.contains(badge)) {
      stats.badges.add(badge);
    }
  }

  Future<void> completeChallenge(int index) async {
    final stats = await getStats();
    if (index >= 0 && index < stats.dailyChallenges.length) {
      stats.dailyChallenges[index] = DailyChallenge(
        description: stats.dailyChallenges[index].description,
        completed: true,
      );
    }
  }

  Future<void> incrementDips() async {
    final stats = await getStats();
    stats.dipsCount += 1;
    stats.lastDipDate = DateTime.now();
  }
}