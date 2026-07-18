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
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await _createSchema(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createTeamDrawSchema(db);
        }
      },
    );
  }

  Future<void> _createSchema(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseTables.players} (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        position TEXT NOT NULL,
        skill_rating INTEGER NOT NULL,
        photo_path TEXT
      )
    ''');

    await _createTeamDrawSchema(db);
  }

  Future<void> _createTeamDrawSchema(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DatabaseTables.events} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        event_date TEXT NOT NULL,
        location TEXT,
        status TEXT NOT NULL DEFAULT 'scheduled',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DatabaseTables.teams} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        event_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        color TEXT,
        origin TEXT NOT NULL DEFAULT 'draw',
        created_at TEXT NOT NULL,
        FOREIGN KEY (event_id) REFERENCES ${DatabaseTables.events}(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DatabaseTables.playerTeams} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        team_id INTEGER NOT NULL,
        player_id INTEGER NOT NULL,
        is_present INTEGER NOT NULL DEFAULT 1,
        is_captain INTEGER NOT NULL DEFAULT 0,
        rotation_order INTEGER,
        assigned_position TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (team_id) REFERENCES ${DatabaseTables.teams}(id) ON DELETE CASCADE,
        FOREIGN KEY (player_id) REFERENCES ${DatabaseTables.players}(id) ON DELETE RESTRICT,
        UNIQUE (team_id, player_id)
      )
    ''');

    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_teams_event_id ON ${DatabaseTables.teams}(event_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_player_teams_team_id ON ${DatabaseTables.playerTeams}(team_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_player_teams_player_id ON ${DatabaseTables.playerTeams}(player_id)',
    );
  }
}
