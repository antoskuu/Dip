import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/dip.dart';

class DipDatabase {
  static final DipDatabase instance = DipDatabase._init();
  static Database? _database;

  DipDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('dips.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE dips (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        rating INTEGER NOT NULL,
        photoPath TEXT,
        date TEXT NOT NULL
      )
    ''');
  }

  Future<int> createDip(Dip dip) async {
    final db = await instance.database;
    return await db.insert('dips', dip.toMap());
  }

  Future<List<Dip>> getAllDips() async {
    final db = await instance.database;
    final result = await db.query('dips');
    return result.map((map) => Dip.fromMap(map)).toList();
  }

  Future<int> updateDip(Dip dip) async {
    final db = await instance.database;
    return await db.update(
      'dips',
      dip.toMap(),
      where: 'id = ?',
      whereArgs: [dip.id],
    );
  }

  Future<int> deleteDip(int id) async {
    final db = await instance.database;
    return await db.delete(
      'dips',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}