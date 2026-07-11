import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'database_config.dart';
import 'database_tables.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, DatabaseConfig.databaseName);

    return openDatabase(
      path,
      version: DatabaseConfig.version,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE ${DatabaseTables.players} (
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            position TEXT NOT NULL,
            skill_rating INTEGER NOT NULL,
            photo_path TEXT
          )
        ''');
      },
    );
  }
}