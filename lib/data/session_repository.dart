import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/session_result.dart';

class SessionRepository {
  static Database? _database;
  static const String _webPrefsKey = 'web_sessions_cache';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('sessions.db');
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

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        exerciseId TEXT NOT NULL,
        validReps INTEGER NOT NULL,
        formBreaks INTEGER NOT NULL,
        accuracy REAL NOT NULL,
        durationSeconds INTEGER NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertSession(SessionResult session) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final List<String> cached = prefs.getStringList(_webPrefsKey) ?? [];
      
      final map = session.toMap();
      map['id'] = DateTime.now().millisecondsSinceEpoch; // Fake ID for web
      cached.add(jsonEncode(map));
      
      await prefs.setStringList(_webPrefsKey, cached);
      return map['id'] as int;
    } else {
      final db = await database;
      final map = session.toMap();
      map.remove('id'); 
      return await db.insert('sessions', map);
    }
  }

  Future<List<SessionResult>> getAllSessions() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final List<String> cached = prefs.getStringList(_webPrefsKey) ?? [];
      
      final sessions = cached
          .map((s) => SessionResult.fromMap(jsonDecode(s) as Map<String, dynamic>))
          .toList();
          
      sessions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return sessions;
    } else {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'sessions',
        orderBy: 'timestamp DESC',
      );
      return maps.map((map) => SessionResult.fromMap(map)).toList();
    }
  }

  Future<List<SessionResult>> getSessionsForExercise(String exerciseId) async {
    if (kIsWeb) {
      final sessions = await getAllSessions();
      return sessions.where((s) => s.exerciseId == exerciseId).toList().reversed.toList();
    } else {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'sessions',
        where: 'exerciseId = ?',
        whereArgs: [exerciseId],
        orderBy: 'timestamp ASC',
      );
      return maps.map((map) => SessionResult.fromMap(map)).toList();
    }
  }
}
