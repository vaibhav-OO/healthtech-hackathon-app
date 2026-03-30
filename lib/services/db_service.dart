// import 'package:flutter/material.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import '../models/user.dart';
// import '../models/disease.dart';
//
// class DbService {
//   static Database? _db;
//
//   Future<Database> get db async{
//     if (_db != null) return _db!;
//     _db = await initDB();
//     return _db!;
//   }
//
//   initDB() async{
//     String path = join(await getDatabasesPath(), "symptom_sense.db");
//     return await openDatabase(
//       path,
//       version: 1,
//       onCreate: (db, version) async {
//         await db.execute('''
//         CREATE TABLE users(
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         email TEXT UNIQUE,
//         password TEXT)
//         ''');
//
//         await db.execute('''
//         CREATE TABLE reports(
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         user_id INTEGER,
//         symptoms TEXT,
//         result TEXT,
//         percent INTEGER,
//         timestamp TEXT)
//         ''');
//
//       }
//     );
//   }
//
//   //USER METHODS
//   Future<int> registerUser(UserModel user) async{
//     final dbClient = await db;
//     return  await dbClient.insert('users', user.toMap());
//   }
//
//   Future<UserModel?> loginUser(String email, String password) async{
//     final dbClient = await db;
//     final res = await dbClient.query(
//         'users',
//         where: 'email = ? AND password = ?',
//         whereArgs: [email, password],
//     );
//
//     if (res.isNotEmpty) {
//       return UserModel.fromMap(res.first);
//     }
//     return  null;
//
//   }
//
//
//   //REPORT METHODS
// Future<int> saveReport(int userId, String symptoms, String result, int percent)
//   async{
//     final dbClient = await db;
//     return await dbClient.insert('reports', {
//       "user_id": userId,
//       "symptoms": symptoms,
//       "result": result,
//       "percent": percent,
//       "timestamp": DateTime.now().toString(),
//
//     });
//   }
//
//
//
//
// }




import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/report.dart';

class DBService {
  DBService._privateConstructor();
  static final DBService instance = DBService._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize SQLite database
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'healthtech.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Create tables
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE reports(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        symptoms TEXT NOT NULL,
        disease TEXT NOT NULL,
        advice TEXT NOT NULL,
        date TEXT NOT NULL,
        FOREIGN KEY(userId) REFERENCES users(id)
      )
    ''');
  }

  //=====================Admin Method========================
  
  Future<int> getTotalUsers() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM users');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getTotalReports() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM reports');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  //normal app use
  Future<List<ReportModel>> getAllReports() async {
    final db = await database;
    final result = await db.query('reports', orderBy: 'id DESC');
    return result.map((map) => ReportModel.fromMap(map)).toList();
  }

  //admin dashboard
  Future<List<Map<String, dynamic>>> getAllReportsRaw() async {
    final db = await database;
    return await db.query('reports', orderBy: 'id DESC');
  }



  // ================= User Methods =================

  Future<int> registerUser(UserModel user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<UserModel?> loginUser(String email, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (result.isNotEmpty) {
      return UserModel.fromMap(result.first);
    } else {
      return null;
    }
  }

  Future<UserModel?> getUserById(int id) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) return UserModel.fromMap(result.first);
    return null;
  }

  // ================= Report Methods =================

  Future<int> saveReport(ReportModel report) async {
    final db = await database;
    return await db.insert('reports', report.toMap());
  }

  Future<List<ReportModel>> getReportsForUser(int userId) async {
    final db = await database;
    final result = await db.query(
      'reports',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'id DESC',
    );
    return result.map((map) => ReportModel.fromMap(map)).toList();
  }
}
