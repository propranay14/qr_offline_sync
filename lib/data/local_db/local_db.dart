import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../model/fetch_candidates_response_model.dart';

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
      version: 7,
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
        roll_number TEXT,
        application_number TEXT,
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
        updated_by TEXT,
        created_at TEXT,
        updated_at TEXT,
        updated INTEGER,
        photo_path TEXT,
        fingerprint_data TEXT,
        is_synced INTEGER DEFAULT 0,
        remarks TEXT,
        capture_time TEXT,
        device_id TEXT
      )
    ''');
  }

  Future<void> insertCandidates(List<CandidateModel> candidates) async {
    final db = await database;

    final batch = db.batch();

    for (final candidate in candidates) {
      batch.insert("candidates", candidate.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit(noResult: true);
  }

  Future<List<CandidateModel>> searchCandidate(String query) async {
    final db = await database;

    if (query.trim().isEmpty) return [];

    final result = await db.query("candidates", where: "application_number = ?", whereArgs: [query.trim()]);

    return result.map((e) => CandidateModel.fromMap(e)).toList();
  }

  Future<CandidateModel?> getCandidateByApplicationID(String applicationID) async {
    final db = await database;

    final result = await db.query("candidates", where: "application_number = ?", whereArgs: [applicationID.trim()]);

    if (result.isEmpty) return null;

    return CandidateModel.fromMap(result.first);
  }

  Future<void> updateCandidatePhoto(int id, String photoPath, String operatorId) async {
    final db = await database;

    final rows = await db.update(
      "candidates",
      {"photo_path": photoPath, "updated_by": operatorId, "capture_time": DateTime.now().toIso8601String(), "updated": 1},
      where: "id = ?",
      whereArgs: [id],
    );

    debugPrint("Updated rows: $rows");
    debugPrint("Saved photo path: $photoPath");
  }

  Future<void> updateCandidateFingerprint(int id, String fingerprintPath, String operatorId) async {
    final db = await database;

    await db.update(
      "candidates",
      {"fingerprint_data": fingerprintPath, "updated_by": operatorId, "capture_time": DateTime.now().toIso8601String(), "updated": 1},
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<List<CandidateModel>> getPendingCandidates() async {
    final db = await database;

    final result = await db.query(
      "candidates",
      where: '''
      updated = 1
      AND (
        photo_path IS NOT NULL AND photo_path != ''
        OR
        fingerprint_data IS NOT NULL AND fingerprint_data != ''
      )
    ''',
    );

    return result.map((e) => CandidateModel.fromMap(e)).toList();
  }

  Future<void> markCandidateSynced(int id) async {
    final db = await database;

    await db.update("candidates", {"is_synced": 1, "updated": 0}, where: "id = ?", whereArgs: [id]);
  }

  Future<void> clearCandidates() async {
    final db = await database;
    await db.delete("candidates");
  }
}
