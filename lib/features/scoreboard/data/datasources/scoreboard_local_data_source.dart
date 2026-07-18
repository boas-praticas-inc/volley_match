import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_tables.dart';
import '../../domain/entities/scoreboard_match_entity.dart';

class ScoreboardLocalDataSource {
  ScoreboardLocalDataSource({AppDatabase? appDatabase})
    : _appDatabase = appDatabase ?? AppDatabase.instance;

  final AppDatabase _appDatabase;

  Future<Database> get _database async => _appDatabase.database;

  Future<ScoreboardMatchEntity?> getMatchScoreboard(int matchId) async {
    final db = await _database;
    final matches = await db.query(
      DatabaseTables.matches,
      where: 'id = ?',
      whereArgs: [matchId],
      limit: 1,
    );

    if (matches.isEmpty) {
      return null;
    }

    final match = matches.first;
    final teams = await _getMatchTeams(db, matchId);

    if (teams.length < 2) {
      return null;
    }

    final completedSets = await _getCompletedSets(db, matchId);

    return ScoreboardMatchEntity(
      matchId: matchId,
      eventId: match['event_id'] as int,
      homeTeam: teams[0],
      awayTeam: teams[1],
      startedAt: _dateTimeFromMatch(match),
      bestOfSets: match['best_of_sets'] as int,
      setsToWin: match['sets_to_win'] as int,
      pointsPerSet: match['points_per_set'] as int,
      status: match['status'] as String,
      completedSets: completedSets,
    );
  }

  DateTime _dateTimeFromMatch(Map<String, Object?> match) {
    final rawDate =
        match['started_at'] ?? match['scheduled_at'] ?? match['created_at'];

    if (rawDate is String) {
      return DateTime.tryParse(rawDate) ?? DateTime.now();
    }

    return DateTime.now();
  }

  Future<void> saveCompletedSet({
    required int matchId,
    required int setNumber,
    required int homeTeamId,
    required int awayTeamId,
    required int homeScore,
    required int awayScore,
    required int winnerTeamId,
    required bool isTiebreak,
  }) async {
    final db = await _database;

    await db.insert(DatabaseTables.sets, {
      'match_id': matchId,
      'set_number': setNumber,
      'home_team_id': homeTeamId,
      'away_team_id': awayTeamId,
      'home_score': homeScore,
      'away_score': awayScore,
      'winner_team_id': winnerTeamId,
      'is_tiebreak': isTiebreak ? 1 : 0,
      'finished_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> finishMatch({
    required int matchId,
    required int winnerTeamId,
  }) async {
    final db = await _database;

    await db.update(
      DatabaseTables.matches,
      {
        'status': 'finished',
        'winner_team_id': winnerTeamId,
        'finished_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [matchId],
    );
  }

  Future<List<ScoreboardTeamEntity>> _getMatchTeams(
    Database db,
    int matchId,
  ) async {
    final result = await db.rawQuery(
      '''
      SELECT teams.id, teams.name
      FROM ${DatabaseTables.matchTeams} match_teams
      INNER JOIN ${DatabaseTables.teams} teams ON teams.id = match_teams.team_id
      WHERE match_teams.match_id = ?
      ORDER BY match_teams.draw_order ASC
      ''',
      [matchId],
    );

    return result.map((team) {
      return ScoreboardTeamEntity(
        id: team['id'] as int,
        name: team['name'] as String,
      );
    }).toList();
  }

  Future<List<ScoreboardSetEntity>> _getCompletedSets(
    Database db,
    int matchId,
  ) async {
    final result = await db.query(
      DatabaseTables.sets,
      where: 'match_id = ?',
      whereArgs: [matchId],
      orderBy: 'set_number ASC',
    );

    return result.map((set) {
      return ScoreboardSetEntity(
        number: set['set_number'] as int,
        homeScore: set['home_score'] as int,
        awayScore: set['away_score'] as int,
        winnerTeamId: set['winner_team_id'] as int,
      );
    }).toList();
  }
}
