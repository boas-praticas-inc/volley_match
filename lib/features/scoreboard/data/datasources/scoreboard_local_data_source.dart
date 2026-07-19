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

    return _scoreboardFromMatch(db, matches.first);
  }

  Future<ScoreboardMatchEntity?> getActiveMatchScoreboard() async {
    final db = await _database;
    final matches = await db.query(
      DatabaseTables.matches,
      where: 'status = ?',
      whereArgs: ['in_progress'],
      orderBy: 'datetime(started_at) DESC, id DESC',
      limit: 1,
    );

    if (matches.isEmpty) {
      return null;
    }

    return _scoreboardFromMatch(db, matches.first);
  }

  Future<ScoreboardMatchEntity?> _scoreboardFromMatch(
    DatabaseExecutor db,
    Map<String, Object?> match,
  ) async {
    final matchId = match['id'] as int;
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
      finishedAt: _nullableDateTimeFrom(match['finished_at']),
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

  DateTime? _nullableDateTimeFrom(Object? value) {
    if (value is! String) {
      return null;
    }

    return DateTime.tryParse(value);
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

  Future<ScoreboardMatchEntity?> finishMatch({
    required int matchId,
    required int winnerTeamId,
  }) async {
    final db = await _database;
    final now = DateTime.now().toIso8601String();

    return db.transaction((transaction) async {
      final currentMatches = await transaction.query(
        DatabaseTables.matches,
        where: 'id = ?',
        whereArgs: [matchId],
        limit: 1,
      );

      if (currentMatches.isEmpty) {
        return null;
      }

      final currentMatch = currentMatches.first;

      await transaction.update(
        DatabaseTables.matches,
        {
          'status': 'finished',
          'winner_team_id': winnerTeamId,
          'finished_at': now,
          'updated_at': now,
        },
        where: 'id = ?',
        whereArgs: [matchId],
      );

      final nextMatchId = await _createNextMatchIfNeeded(
        transaction,
        currentMatch: currentMatch,
        winnerTeamId: winnerTeamId,
        now: now,
      );

      if (nextMatchId != null) {
        final nextMatches = await transaction.query(
          DatabaseTables.matches,
          where: 'id = ?',
          whereArgs: [nextMatchId],
          limit: 1,
        );

        return _scoreboardFromMatch(transaction, nextMatches.first);
      }

      final finishedMatches = await transaction.query(
        DatabaseTables.matches,
        where: 'id = ?',
        whereArgs: [matchId],
        limit: 1,
      );

      return _scoreboardFromMatch(transaction, finishedMatches.first);
    });
  }

  Future<List<ScoreboardTeamEntity>> _getMatchTeams(
    DatabaseExecutor db,
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

    final teams = <ScoreboardTeamEntity>[];

    for (final team in result) {
      teams.add(
        ScoreboardTeamEntity(
          id: team['id'] as int,
          name: team['name'] as String,
          players: await _getTeamPlayers(db, team['id'] as int),
        ),
      );
    }

    return teams;
  }

  Future<List<ScoreboardPlayerEntity>> _getTeamPlayers(
    DatabaseExecutor db,
    int teamId,
  ) async {
    final result = await db.rawQuery(
      '''
      SELECT
        players.id,
        players.name,
        players.position,
        player_teams.rotation_order
      FROM ${DatabaseTables.playerTeams} player_teams
      INNER JOIN ${DatabaseTables.players} players
        ON players.id = player_teams.player_id
      WHERE player_teams.team_id = ?
        AND player_teams.is_present = 1
      ORDER BY
        CASE WHEN player_teams.rotation_order IS NULL THEN 1 ELSE 0 END ASC,
        player_teams.rotation_order ASC,
        players.name COLLATE NOCASE ASC
      ''',
      [teamId],
    );

    return result.map((player) {
      return ScoreboardPlayerEntity(
        id: player['id'] as int,
        name: player['name'] as String,
        position: player['position'] as String,
        rotationOrder: player['rotation_order'] as int?,
      );
    }).toList();
  }

  Future<List<ScoreboardSetEntity>> _getCompletedSets(
    DatabaseExecutor db,
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

  Future<int?> _createNextMatchIfNeeded(
    DatabaseExecutor db, {
    required Map<String, Object?> currentMatch,
    required int winnerTeamId,
    required String now,
  }) async {
    final eventId = currentMatch['event_id'] as int;
    final eventTeams = await db.query(
      DatabaseTables.teams,
      columns: ['id'],
      where: 'event_id = ?',
      whereArgs: [eventId],
      orderBy: 'id ASC',
    );

    if (eventTeams.length <= 2) {
      return null;
    }

    final currentMatchId = currentMatch['id'] as int;
    final currentMatchTeams = await db.query(
      DatabaseTables.matchTeams,
      where: 'match_id = ?',
      whereArgs: [currentMatchId],
      orderBy: 'draw_order ASC',
    );

    if (currentMatchTeams.length < 2) {
      return null;
    }

    Map<String, Object?>? winnerMatchTeam;

    for (final matchTeam in currentMatchTeams) {
      if (matchTeam['team_id'] == winnerTeamId) {
        winnerMatchTeam = matchTeam;
        break;
      }
    }

    if (winnerMatchTeam == null) {
      return null;
    }

    final nextTeamId = await _getNextQueuedTeamId(
      db,
      eventId: eventId,
      winnerTeamId: winnerTeamId,
    );

    if (nextTeamId == null) {
      return null;
    }

    final nextMatchId = await db.insert(DatabaseTables.matches, {
      'event_id': eventId,
      'scheduled_at': now,
      'started_at': now,
      'finished_at': null,
      'status': 'in_progress',
      'winner_team_id': null,
      'sets_to_win': currentMatch['sets_to_win'],
      'best_of_sets': currentMatch['best_of_sets'],
      'points_per_set': currentMatch['points_per_set'],
      'notes': null,
      'created_at': now,
      'updated_at': now,
    });

    final winnerSide = winnerMatchTeam['side'] as String;

    if (winnerSide == 'home') {
      await _insertMatchTeam(
        db,
        matchId: nextMatchId,
        teamId: winnerTeamId,
        side: 'home',
        drawOrder: 1,
      );
      await _insertMatchTeam(
        db,
        matchId: nextMatchId,
        teamId: nextTeamId,
        side: 'away',
        drawOrder: 2,
      );
    } else {
      await _insertMatchTeam(
        db,
        matchId: nextMatchId,
        teamId: nextTeamId,
        side: 'home',
        drawOrder: 1,
      );
      await _insertMatchTeam(
        db,
        matchId: nextMatchId,
        teamId: winnerTeamId,
        side: 'away',
        drawOrder: 2,
      );
    }

    return nextMatchId;
  }

  Future<int?> _getNextQueuedTeamId(
    DatabaseExecutor db, {
    required int eventId,
    required int winnerTeamId,
  }) async {
    final result = await db.rawQuery(
      '''
      SELECT
        teams.id,
        (
          SELECT MAX(match_teams.match_id)
          FROM ${DatabaseTables.matchTeams} match_teams
          INNER JOIN ${DatabaseTables.matches} matches
            ON matches.id = match_teams.match_id
          WHERE match_teams.team_id = teams.id
            AND matches.event_id = ?
        ) AS last_match_id
      FROM ${DatabaseTables.teams} teams
      WHERE teams.event_id = ?
        AND teams.id != ?
      ORDER BY
        CASE WHEN last_match_id IS NULL THEN 0 ELSE 1 END ASC,
        last_match_id ASC,
        teams.id ASC
      LIMIT 1
      ''',
      [eventId, eventId, winnerTeamId],
    );

    if (result.isEmpty) {
      return null;
    }

    return result.first['id'] as int;
  }

  Future<void> _insertMatchTeam(
    DatabaseExecutor db, {
    required int matchId,
    required int teamId,
    required String side,
    required int drawOrder,
  }) {
    return db.insert(DatabaseTables.matchTeams, {
      'match_id': matchId,
      'team_id': teamId,
      'side': side,
      'draw_order': drawOrder,
    });
  }
}
