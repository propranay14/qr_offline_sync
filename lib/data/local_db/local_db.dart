import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../model/attendance_model.dart';

class LocalDb {
  static final LocalDb instance = LocalDb._init();
  static Database? _database;

  LocalDb._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('attendance.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE attendance(
        id TEXT PRIMARY KEY,
        studentId TEXT,
        studentName TEXT,
        className TEXT,
        photoPath TEXT,
        fingerprintTemplate TEXT,
        synced INTEGER
      )
    ''');
  }

  Future<void> insertAttendance(AttendanceModel model) async {
    final db = await database;

    await db.insert('attendance', model.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<List<Map<String, dynamic>>> getUnsynced() async {
    final db = await database;

    return db.query('attendance', where: 'synced = ?', whereArgs: [0]);
  }

  Future<void> markSynced(String id) async {
    final db = await database;

    await db.update('attendance', {'synced': 1}, where: 'id = ?', whereArgs: [id]);
  }
}
