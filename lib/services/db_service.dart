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

class DBService {
  static final DBService instance = DBService._internal();
  static Database? _database;

  DBService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('symptom_sense.db');
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
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE,
        password TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE reports (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        symptoms TEXT,
        result TEXT,
        percent INTEGER,
        timestamp TEXT
      )
    ''');
  }

  Future<int> registerUser(UserModel user) async {
    final db = await instance.database;
    return await db.insert('users', user.toMap());
  }

  Future<UserModel?> loginUser(String email, String password) async {
    final db = await instance.database;

    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (result.isNotEmpty) {
      return UserModel.fromMap(result.first);
    }
    return null;
  }

  Future<int> saveReport({
    required int userId,
    required String symptoms,
    required String result,
    required int percent,
  }) async {
    final db = await instance.database;

    return await db.insert('reports', {
      'user_id': userId,
      'symptoms': symptoms,
      'result': result,
      'percent': percent,
      'timestamp': DateTime.now().toString(),
    });
  }

  Future<List<Map<String, dynamic>>> getReports(int userId) async {
    final db = await instance.database;

    return await db.query(
      'reports',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'id DESC',
    );
  }
}