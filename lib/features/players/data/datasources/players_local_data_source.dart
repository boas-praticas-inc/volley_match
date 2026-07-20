import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_tables.dart';
import '../models/player_model.dart';

class PlayersLocalDataSource {
  PlayersLocalDataSource({AppDatabase? appDatabase})
    : _appDatabase = appDatabase ?? AppDatabase.instance;

  final AppDatabase _appDatabase;

  Future<Database> get _database async => _appDatabase.database;

  Future<List<PlayerModel>> getPlayers() async {
    final db = await _database;
    final result = await db.query(
      DatabaseTables.players,
      orderBy: 'name COLLATE NOCASE ASC',
    );

    return result.map(PlayerModel.fromMap).toList();
  }

  Future<void> insertPlayer(PlayerModel player) async {
    final db = await _database;
    await db.insert(
      DatabaseTables.players,
      player.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updatePlayer(PlayerModel player) async {
    final db = await _database;
    await db.update(
      DatabaseTables.players,
      player.toMap(),
      where: 'id = ?',
      whereArgs: [player.id],
    );
  }

  Future<void> deletePlayer(int playerId) async {
    final db = await _database;
    await db.delete(
      DatabaseTables.players,
      where: 'id = ?',
      whereArgs: [playerId],
    );
  }
}
