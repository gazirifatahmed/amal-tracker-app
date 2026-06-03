import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;
  
  final List<Map<String, dynamic>> _webDatabaseLog = [];
  final List<Map<String, dynamic>> _webCustomTasks = [];

  Future<Database?> get database async {
    if (kIsWeb) return null;
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'amal_tracker.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await _createAmalLogsTable(db);
        await _createCustomTasksTable(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createCustomTasksTable(db);
        }
      },
    );
  }

  static Future<void> _createAmalLogsTable(Database db) async {
    await db.execute('''
      CREATE TABLE amal_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT,
        task_id TEXT,
        is_completed INTEGER
      )
    ''');
  }

  static Future<void> _createCustomTasksTable(Database db) async {
    await db.execute('''
      CREATE TABLE custom_tasks (
        id TEXT PRIMARY KEY,
        title TEXT,
        start_time TEXT,
        end_time TEXT,
        date TEXT
      )
    ''');
  }

  // আপডেট করা মেথড: প্যারামিটার সিকোয়েন্স কন্ট্রোলারের সাথে ম্যাচ করা হয়েছে
  Future<void> insertCustomTask(String id, String title, String date, String startTime, String endTime) async {
    if (kIsWeb) {
      _webCustomTasks.add({
        'id': id,
        'title': title,
        'date': date,
        'start_time': startTime,
        'end_time': endTime,
      });
      return;
    }
    final db = await database;
    if (db != null) {
      await db.insert('custom_tasks', {
        'id': id,
        'title': title,
        'date': date,
        'start_time': startTime,
        'end_time': endTime,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<List<Map<String, dynamic>>> getCustomTasksByDate(String date) async {
    if (kIsWeb) {
      return _webCustomTasks.where((task) => task['date'] == date).toList();
    }
    final db = await database;
    if (db == null) return [];
    return await db.query('custom_tasks', where: 'date = ?', whereArgs: [date]);
  }

  Future<List<Map<String, dynamic>>> getLogsByDate(String date) async {
    if (kIsWeb) {
      return _webDatabaseLog.where((log) => log['date'] == date).toList();
    }
    final db = await database;
    if (db == null) return [];
    return await db.query('amal_logs', where: 'date = ?', whereArgs: [date]);
  }

  Future<void> insertOrUpdateLog(String date, String taskId, int isCompleted) async {
    if (kIsWeb) {
      _webDatabaseLog.removeWhere((log) => log['date'] == date && log['task_id'] == taskId);
      _webDatabaseLog.add({
        'date': date,
        'task_id': taskId,
        'is_completed': isCompleted,
      });
      return;
    }

    final db = await database;
    if (db == null) throw Exception('Database initialization failed');

    List<Map<String, dynamic>> maps = await db.query(
      'amal_logs',
      where: 'date = ? AND task_id = ?',
      whereArgs: [date, taskId],
    );

    if (maps.isNotEmpty) {
      await db.update(
        'amal_logs',
        {'is_completed': isCompleted},
        where: 'date = ? AND task_id = ?',
        whereArgs: [date, taskId],
      );
    } else {
      await db.insert('amal_logs', {
        'date': date,
        'task_id': taskId,
        'is_completed': isCompleted,
      });
    }
  }
}