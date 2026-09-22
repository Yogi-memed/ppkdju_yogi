import 'dart:developer';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/catatan_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'catatan.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE catatan (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            judul TEXT NOT NULL,
            isi TEXT NOT NULL,
            tanggal TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<int> tambahCatatan(CatatanModel catatan) async {
    final db = await database;

    try {
      return await db.insert('catatan', catatan.toMap());
    } catch (e) {
      log('Error tambahCatatan: $e');
      return -1;
    }
  }

  Future<List<CatatanModel>> semuaCatatan() async {
    final db = await database;

    final results = await db.query('catatan', orderBy: 'id DESC');

    return results.map((map) => CatatanModel.fromMap(map)).toList();
  }

  Future<int> updateCatatan(CatatanModel catatan) async {
    final db = await database;

    try {
      return await db.update(
        'catatan',
        catatan.toMap(),
        where: 'id = ?',
        whereArgs: [catatan.id],
      );
    } catch (e) {
      log('Error updateCatatan: $e');
      return 0;
    }
  }

  Future<void> hapusCatatan(int id) async {
    final db = await database;

    await db.delete('catatan', where: 'id = ?', whereArgs: [id]);
  }
}

// import 'dart:developer';

// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';

// import '../../tugas_12_13/models/catatan_model.dart';

// class DatabaseHelper {
//   static final DatabaseHelper _instance = DatabaseHelper._internal();
//   factory DatabaseHelper() => _instance;
//   DatabaseHelper._internal();

//   static Database? _database;

//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDB();
//     return _database!;
//   }

//   Future<Database> _initDB() async {
//     final dbPath = await getDatabasesPath();
//     final path = join(dbPath, 'catatan.db');

//     return await openDatabase(
//       path,
//       version: 1,
//       onCreate: (db, version) async {
//         await db.execute('''
//           CREATE TABLE catatan (
//             id      INTEGER PRIMARY KEY AUTOINCREMENT,
//             judul   TEXT NOT NULL,
//             isi     TEXT NOT NULL,
//             tanggal TEXT NOT NULL
//           )
//         ''');
//       },
//     );
//   }

//   Future<int> tambahCatatan(CatatanModel catatan) async {
//     final db = await database;
//     try {
//       return await db.insert('catatan', catatan.toMap());
//     } catch (e) {
//       log('Error tambahCatatan: $e');
//       return -1;
//     }
//   }

//   Future<List<CatatanModel>> semuaCatatan() async {
//     final db = await database;
//     final List<Map<String, dynamic>> results = await db.query(
//       'catatan',
//       orderBy: 'id DESC',
//     );
//     return results.map((map) => CatatanModel.fromMap(map)).toList();
//   }

//   Future<int> updateCatatan(CatatanModel catatan) async {
//     final db = await database;
//     try {
//       return await db.update(
//         'catatan',
//         catatan.toMap(),
//         where: 'id = ?',
//         whereArgs: [catatan.id],
//       );
//     } catch (e) {
//       log('Error updateCatatan: $e');
//       return 0;
//     }
//   }

//   Future<void> hapusCatatan(int id) async {
//     final db = await database;
//     await db.delete('catatan', where: 'id = ?', whereArgs: [id]);
//   }
// }
