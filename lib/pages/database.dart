import 'package:expensem_app/pages/info.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'info_v2.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE info(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        des TEXT,
        qty INTEGER NOT NULL,
        amt REAL NOT NULL
        
      )
      ''');
  }

  Future<List<Info>> getinfos() async {
    Database db = await instance.database;
    var infos = await db.query('info', orderBy: 'name');
    List<Info> infoList = infos.isNotEmpty
        ? infos.map((c) => Info.fromMap(c)).toList()
        : [];
    return infoList;
  }

  Future<int> add(Info info) async {
    try {
      Database db = await instance.database;
      return await db.insert('info', info.toMap());
    } catch (e) {
      print('DB Insert Error: $e');
      return -1;
    }
  }

  Future<int> update(Info info) async {
    try {
      final db = await instance.database;
      return await db.update(
        'info',
        info.toMap(),
        where: 'id = ?',
        whereArgs: [info.id],
      );
    } catch (e) {
      print('DB Update Error: $e');
      return -1;
    }
  }

  Future<int> delete(int id) async {
    try {
      final db = await instance.database;
      return await db.delete('info', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      print('DB Delete Error: $e');
      return -1;
    }
  }

  Future<int> getTotalItemsPurchased() async {
    Database db = await instance.database;
    final result = await db.rawQuery('SELECT SUM(qty) as total FROM info');
    final total = result.first['total'];
    if (total == null) return 0;
    if (total is int) return total;
    if (total is double) return total.toInt();
    return 0;
  }

  Future<double> getTotalAmountSpent() async {
    Database db = await instance.database;
    final result = await db.rawQuery('SELECT SUM(amt) as total FROM info');
    final total = result.first['total'];
    if (total == null) return 0.0;
    if (total is double) return total;
    if (total is int) return total.toDouble();
    return 0.0;
  }

  Future<double> getTotalAmountSpentExcluding(int? excludeId) async {
    final db = await instance.database;
    String query = 'SELECT SUM(amt) as total FROM info';
    List<dynamic> args = [];

    if (excludeId != null) {
      query += ' WHERE id != ?';
      args.add(excludeId);
    }

    final result = await db.rawQuery(query, args);
    final total = result.first['total'] as num?;
    return total?.toDouble() ?? 0.0;
  }

  Future<void> clearDatabase(Database db) async {
    await db.delete('info');
  }
}
