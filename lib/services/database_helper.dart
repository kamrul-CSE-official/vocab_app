import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import '../models/word_entry.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _db;
  static bool _factoryReady = false;

  /// sqflite only talks to Android/iOS natively. On web it needs the
  /// sqlite3-wasm factory; on Windows/Linux/macOS desktop it needs the
  /// FFI factory. Android/iOS keep the default sqflite factory as-is.
  void _ensureFactory() {
    if (_factoryReady) return;
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    } else if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    _factoryReady = true;
  }

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    _ensureFactory();
    final path = kIsWeb
        ? 'vocab_app.db'
        : join(await getDatabasesPath(), 'vocab_app.db');
    return databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE words (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              word TEXT NOT NULL,
              banglaMeaning TEXT NOT NULL,
              synonyms TEXT,
              antonyms TEXT,
              exampleSentence TEXT,
              createdAt TEXT NOT NULL
            )
          ''');
          await db.execute('CREATE INDEX idx_word ON words(word)');
        },
      ),
    );
  }

  Future<int> insertWord(WordEntry entry) async {
    final db = await database;
    final map = entry.toMap()..remove('id');
    return db.insert('words', map);
  }

  Future<int> updateWord(WordEntry entry) async {
    final db = await database;
    return db.update(
      'words',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> deleteWord(int id) async {
    final db = await database;
    return db.delete('words', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<WordEntry>> getAllWords({String orderBy = 'word ASC'}) async {
    final db = await database;
    final maps = await db.query('words', orderBy: orderBy);
    return maps.map((m) => WordEntry.fromMap(m)).toList();
  }

  Future<List<WordEntry>> searchWords(String query) async {
    final db = await database;
    final maps = await db.query(
      'words',
      where: 'word LIKE ? OR banglaMeaning LIKE ? OR synonyms LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'word ASC',
    );
    return maps.map((m) => WordEntry.fromMap(m)).toList();
  }

  Future<int> wordCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) AS count FROM words');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
