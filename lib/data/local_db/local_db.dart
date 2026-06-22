import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../model/candidate_sync_response_model.dart';

class LocalDb {
  static final LocalDb instance = LocalDb._init();
  static Database? _database;

  LocalDb._init();

  Future<Database> get database async {
    _database ??= await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), "candidates.db");

    return await openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await _createTable(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await db.execute("DROP TABLE IF EXISTS candidates");
        await _createTable(db);
      },
    );
  }

  Future<void> _createTable(Database db) async {
    await db.execute('''
      CREATE TABLE candidates(
        id INTEGER PRIMARY KEY,
        candidate_id TEXT,
        application_id TEXT,
        candidate_name TEXT,
        father_name TEXT,
        mother_name TEXT,
        gender TEXT,
        dob TEXT,
        mobile_no TEXT,
        email TEXT,
        address_line1 TEXT,
        address_line2 TEXT,
        village_city TEXT,
        district TEXT,
        state TEXT,
        pincode TEXT,
        biometric_status TEXT,
        profile_photo TEXT,
        fingerprint_template TEXT,
        face_status TEXT,
        fingerprint_status TEXT,
        updated_by INTEGER,
        created_at TEXT,
        updated_at TEXT,
        updated INTEGER,
        photo_path TEXT,
        fingerprint_data TEXT
      )
    ''');
  }

  Future<void> insertCandidate(CandidateModel candidate) async {
    final db = await database;

    await db.insert("candidates", candidate.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertCandidates(List<CandidateModel> candidates) async {
    final db = await database;

    final batch = db.batch();

    for (final candidate in candidates) {
      batch.insert("candidates", candidate.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit(noResult: true);
  }

  Future<int> getLastCandidateId() async {
    final db = await database;

    final result = await db.rawQuery("SELECT MAX(id) as last_id FROM candidates");

    if (result.isNotEmpty && result.first["last_id"] != null) {
      return result.first["last_id"] as int;
    }

    return 0;
  }

  Future<List<CandidateModel>> searchCandidate(String query) async {
    final db = await database;

    final result = await db.query(
      "candidates",
      where: '''
      application_id LIKE ? OR
      candidate_name LIKE ? OR
      candidate_id LIKE ?
      ''',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
    );

    return result.map((e) => CandidateModel.fromMap(e)).toList();
  }

  Future<CandidateModel?> getCandidateByApplicationID(String applicationID) async {
    final db = await database;

    final result = await db.query("candidates", where: "application_id = ?", whereArgs: [applicationID]);

    if (result.isEmpty) return null;

    return CandidateModel.fromMap(result.first);
  }

  Future<void> clearCandidates() async {
    final db = await database;
    await db.delete("candidates");
  }
}
