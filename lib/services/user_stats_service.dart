import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_stats.dart';

class UserStatsService {
  // Notifier to broadcast stats updates across the app
  final ValueNotifier<UserStats?> statsNotifier = ValueNotifier<UserStats?>(null);

  static final UserStatsService instance = UserStatsService._init();
  static Database? _database;

  UserStatsService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('user_stats.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user_stats(
        id INTEGER PRIMARY KEY,
        xp INTEGER NOT NULL,
        dipsCount INTEGER NOT NULL
      )
    ''');
    // Insert initial stats
    await db.insert('user_stats', {'id': 1, 'xp': 0, 'dipsCount': 0});
  }

  Future<UserStats> getStats() async {
    if (statsNotifier.value != null) return statsNotifier.value!;
    final db = await instance.database;
    final maps = await db.query('user_stats', where: 'id = ?', whereArgs: [1]);
    if (maps.isNotEmpty) {
      final stats = UserStats.fromMap(maps.first);
    statsNotifier.value = stats;
    return stats;
    } else {
      // This should not happen if _createDB is correct
      return UserStats(xp: 0, dipsCount: 0);
    }
  }

  Future<void> updateStats(UserStats stats) async {
    final db = await instance.database;
    await db.update(
      'user_stats',
      stats.toMap(),
      where: 'id = ?',
      whereArgs: [1],
    );
    statsNotifier.value = stats;
  }

  Future<void> addXP(int amount) async {
    final stats = await getStats();
    stats.xp += amount;
    if (stats.xp < 0) stats.xp = 0;
    await updateStats(stats);
  }

  Future<void> incrementDips() async {
    final stats = await getStats();
    stats.dipsCount += 1;
    await updateStats(stats);
  }

  Future<void> decrementDips() async {
    final stats = await getStats();
    if (stats.dipsCount > 0) stats.dipsCount -= 1;
    await updateStats(stats);
  }

  // Badges can be stored in a separate table or as a serialized string if needed
  // For now, we keep it simple
}