import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io' as io;
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:sql_project/models/notes.dart';

class DbHelper {
  static Database? _db;

  Future<Database?> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDatabase();
    return _db;
  }

  Future<Database> initDatabase() async {
    io.Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, 'flutter.sql');

    // Check if the database exists
    bool dbExists = await io.File(path).exists();

    if (!dbExists) {
      // If it doesn't exist, copy it from the assets
      await _copyDatabaseFromAssets(path);
    }

    // Open the database
    var db = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    return db;
  }

  Future<void> _copyDatabaseFromAssets(String path) async {
    ByteData data = await rootBundle.load('assets/flutter.sql');
    List<int> bytes =
    data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await io.File(path).writeAsBytes(bytes);
  }

  void _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        date DATETIME NOT NULL
      )
    ''');
  }

  void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
          'ALTER TABLE notes ADD COLUMN date DATETIME NOT NULL DEFAULT ""');
    }
  }

  Future<int?> insert(NotesModel notesModel) async {
    try {
      var dbClient = await db;
      return await dbClient!.insert('notes', notesModel.toMap());
    } catch (e) {
      print("Error inserting note: $e");
      return null;
    }
  }

  Future<List<NotesModel>> getNotesList() async {
    try {
      var dbClient = await db;
      final List<Map<String, Object?>> queryResult =
      await dbClient!.query('notes');
      return queryResult.map((e) => NotesModel.fromMap(e)).toList();
    } catch (e) {
      print("Error fetching notes: $e");
      return [];
    }
  }

  Future<int?> delete(int id) async {
    try {
      var dbClient = await db;
      return await dbClient!.delete('notes', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      print("Error deleting note: $e");
      return null;
    }
  }

  Future<int?> update(NotesModel notesModel) async {
    try {
      var dbClient = await db;
      return await dbClient!.update('notes', notesModel.toMap(),
          where: 'id = ?', whereArgs: [notesModel.id]);
    } catch (e) {
      print("Error updating note: $e");
      return null;
    }
  }
}
