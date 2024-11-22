import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;

  DBHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'performance.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
              return db.execute('''
                CREATE TABLE performances (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        discipline TEXT,
        category TEXT,
        age_category TEXT,
        age_range TEXT,
        performance TEXT,
        date TEXT
);
        ''');
      },
    );
  }

  Future<void> insertPerformance(Map<String, dynamic> performance) async {
    final db = await database;
    final id = await db.insert('performances', performance);
    print("Performance insérée avec l'ID : $id"); // Log de l'ID inséré
  }

  Future<List<Map<String, dynamic>>> getPerformances() async {
    final db = await database;
    return await db.query('performances', orderBy: "date DESC");
  }

  Future<void> deletePerformance(int id) async {
    final db = await database;
    await db.delete('performances', where: 'id = ?', whereArgs: [id]);
  }
}
