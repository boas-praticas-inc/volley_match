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
      pointScoringTeamIds: await _getPointScoringTeamIds(
        matchId: matchId,
        setNumber: setNumber,
      ),
    );

    if (liveScore.setNumber != setNumber) {
      await clearLiveScore(matchId);
      return null;
    }

    return liveScore;
  }

  Future<void> saveLiveScore(LiveScoreEntity liveScore) async {
    final db = await _database;

    await db.transaction((transaction) async {
      final now = DateTime.now().toIso8601String();

      await transaction.insert(DatabaseTables.liveSets, {
        'match_id': liveScore.matchId,
        'set_number': liveScore.setNumber,
        'home_score': liveScore.homeScore,
        'away_score': liveScore.awayScore,
        'updated_at': now,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      await transaction.delete(
        DatabaseTables.pointEvents,
        where: 'match_id = ? AND set_number = ?',
        whereArgs: [liveScore.matchId, liveScore.setNumber],
      );

      for (
        var index = 0;
        index < liveScore.pointScoringTeamIds.length;
        index++
      ) {
        await transaction.insert(DatabaseTables.pointEvents, {
          'match_id': liveScore.matchId,
          'set_number': liveScore.setNumber,
          'sequence': index + 1,
          'scoring_team_id': liveScore.pointScoringTeamIds[index],
          'created_at': now,
        });
      }
    });
  }

  Future<void> clearLiveScore(int matchId) async {
    final db = await _database;

    await db.transaction((transaction) async {
      await transaction.delete(
        DatabaseTables.liveSets,
        where: 'match_id = ?',
        whereArgs: [matchId],
      );

      await transaction.delete(
        DatabaseTables.pointEvents,
        where: 'match_id = ?',
        whereArgs: [matchId],
      );
    });
  }

  Future<List<int>> _getPointScoringTeamIds({
    required int matchId,
    required int setNumber,
  }) async {
    final db = await _database;
    final events = await db.query(
      DatabaseTables.pointEvents,
      columns: ['scoring_team_id'],
      where: 'match_id = ? AND set_number = ?',
      whereArgs: [matchId, setNumber],
      orderBy: 'sequence ASC',
    );

    return events.map((event) => event['scoring_team_id'] as int).toList();
  }
}
