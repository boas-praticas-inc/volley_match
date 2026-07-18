import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_tables.dart';
import '../../domain/entities/live_score_entity.dart';

class LiveScoreLocalDataSource {
  LiveScoreLocalDataSource({AppDatabase? appDatabase})
    : _appDatabase = appDatabase ?? AppDatabase.instance;

  final AppDatabase _appDatabase;

  Future<Database> get _database async => _appDatabase.database;

  Future<LiveScoreEntity?> getLiveScore({
    required int matchId,
    required int setNumber,
  }) async {
    final db = await _database;
    final result = await db.query(
      DatabaseTables.liveSets,
      where: 'match_id = ?',
      whereArgs: [matchId],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    final liveScore = LiveScoreEntity(
      matchId: result.first['match_id'] as int,
      setNumber: result.first['set_number'] as int,
      homeScore: result.first['home_score'] as int,
      awayScore: result.first['away_score'] as int,
    );

    if (liveScore.setNumber != setNumber) {
      await clearLiveScore(matchId);
      return null;
    }

    return liveScore;
  }

  Future<void> saveLiveScore(LiveScoreEntity liveScore) async {
    final db = await _database;

    await db.insert(DatabaseTables.liveSets, {
      'match_id': liveScore.matchId,
      'set_number': liveScore.setNumber,
      'home_score': liveScore.homeScore,
      'away_score': liveScore.awayScore,
      'updated_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> clearLiveScore(int matchId) async {
    final db = await _database;

    await db.delete(
      DatabaseTables.liveSets,
      where: 'match_id = ?',
      whereArgs: [matchId],
    );
  }
}
