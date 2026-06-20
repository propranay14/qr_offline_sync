import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../model/candidate_sync_response_model.dart';
import '../model/student_model.dart';

class LocalDb {
  static final LocalDb instance = LocalDb._init();
  static Database? _database;

  LocalDb._init();

  Future<Database> get database async {
    _database ??= await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), "students.db");

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE students(
          id INTEGER PRIMARY KEY,
          firstName TEXT,
          fatherName TEXT,
          lastName TEXT,
          profilePhoto TEXT,
          applicationNumber TEXT,
          biometricData TEXT
        )
        ''');
      },
    );
  }

  Future<void> insertCandidates(List<CandidateModel> candidates) async {
    final db = await database;

    final batch = db.batch();

    for (final candidate in candidates) {
      batch.insert(
        "students",
        candidate.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }
  Future<void> insertDummyStudents() async {
    final db = await database;

    final existing = await db.query("students");
    if (existing.isNotEmpty) return;

    for (int i = 1; i <= 100; i++) {
      await db.insert(
        "students",
        StudentModel(
          id: i,
          firstName: "Student$i",
          fatherName: "Father$i",
          lastName: "Last$i",
          profilePhoto: "",
          applicationNumber: "APP$i",
          biometricData: "BIO$i",
        ).toMap(),
      );
    }
  }

  Future<List<StudentModel>> searchStudent(String query) async {
    final db = await database;

    final result = await db.query(
      "students",
      where: '''
      applicationNumber LIKE ? OR
      firstName LIKE ?
      ''',
      whereArgs: ['%$query%', '%$query%'],
    );

    return result.map((e) => StudentModel.fromMap(e)).toList();
  }

  Future<StudentModel?> getStudentByApplicationNumber(String appNo) async {
    final db = await database;

    final result = await db.query(
      "students",
      where: "applicationNumber = ?",
      whereArgs: [appNo],
    );

    if (result.isEmpty) return null;

    return StudentModel.fromMap(result.first);
  }
}