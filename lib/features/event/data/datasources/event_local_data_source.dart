import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_tables.dart';
import '../../domain/entities/event_match_configuration_entity.dart';
import '../../domain/entities/event_progress_entity.dart';
import '../../domain/entities/recent_event_entity.dart';

class EventLocalDataSource {
  EventLocalDataSource({AppDatabase? appDatabase})
    : _appDatabase = appDatabase ?? AppDatabase.instance;

  final AppDatabase _appDatabase;

  Future<Database> get _database async => _appDatabase.database;

  Future<int> startEventMatch(
    EventMatchConfigurationEntity configuration,
  ) async {
    final db = await _database;
    final now = DateTime.now().toIso8601String();

    return db.transaction((transaction) async {
      await transaction.update(
        DatabaseTables.events,
        {'status': 'in_progress', 'updated_at': now},
        where: 'id = ?',
        whereArgs: [configuration.eventId],
      );

      final matchId = await transaction.insert(DatabaseTables.matches, {
        'event_id': configuration.eventId,
        'scheduled_at': now,
        'started_at': now,
        'finished_at': null,
        'status': 'in_progress',
        'winner_team_id': null,
        'sets_to_win': configuration.setsToWin,
        'best_of_sets': configuration.bestOfSets,
        'points_per_set': configuration.pointsPerSet,
        'notes': null,
        'created_at': now,
        'updated_at': now,
      });

      await transaction.insert(DatabaseTables.matchTeams, {
        'match_id': matchId,
        'team_id': configuration.homeTeamId,
        'side': 'home',
        'draw_order': 1,
      });

      await transaction.insert(DatabaseTables.matchTeams, {
        'match_id': matchId,
        'team_id': configuration.awayTeamId,
        'side': 'away',
        'draw_order': 2,
      });

      return matchId;
    });
  }

  Future<EventProgressEntity?> getActiveEventProgress() async {
    final db = await _database;
    final event = await _getActiveEvent(db);

    if (event == null) {
      return null;
    }

    return _buildEventProgress(db, event);
  }

  Future<EventProgressEntity?> getEventProgress(int eventId) async {
    final db = await _database;
    final events = await db.query(
      DatabaseTables.events,
      where: 'id = ?',
      whereArgs: [eventId],
      limit: 1,
    );

    if (events.isEmpty) {
      return null;
    }

    return _buildEventProgress(db, events.first);
  }

  Future<List<RecentEventEntity>> getEvents() async {
    final db = await _database;
    final events = await db.query(
      DatabaseTables.events,
      orderBy: 'datetime(updated_at) DESC, id DESC',
    );

    return _recentEventsFromRows(db, events);
  }

  Future<List<RecentEventEntity>> getRecentEvents({int limit = 5}) async {
    final db = await _database;
    final events = await db.query(
      DatabaseTables.events,
      where: 'status = ?',
      whereArgs: ['finished'],
      orderBy: 'datetime(updated_at) DESC, id DESC',
      limit: limit,
    );

    return _recentEventsFromRows(db, events);
  }

  Future<List<RecentEventEntity>> _recentEventsFromRows(
    DatabaseExecutor db,
    List<Map<String, Object?>> events,
  ) async {
    final recentEvents = <RecentEventEntity>[];

    for (final event in events) {
      final eventId = event['id'] as int;
      final counters = await _getEventCounters(db, eventId);
      final championTeamName = await _getEventChampionTeamName(db, eventId);

      recentEvents.add(
        RecentEventEntity(
          id: eventId,
          name: event['name'] as String,
          date: _dateTimeFrom(event['event_date']),
          status: event['status'] as String,
          totalTeams: counters.teams,
          totalMatches: counters.matches,
          championTeamName: championTeamName,
        ),
      );
    }

    return recentEvents;
  }

  Future<void> updateEventName({
    required int eventId,
    required String name,
  }) async {
    final db = await _database;

    await db.update(
      DatabaseTables.events,
      {'name': name, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [eventId],
    );
  }

  Future<void> finishEvent(int eventId) async {
    final db = await _database;
    final now = DateTime.now().toIso8601String();

    await db.transaction((transaction) async {
      final eventMatches = await transaction.query(
        DatabaseTables.matches,
        columns: ['id'],
        where: 'event_id = ?',
        whereArgs: [eventId],
      );

      final matchIds = eventMatches.map((match) => match['id'] as int).toList();

      if (matchIds.isNotEmpty) {
        final placeholders = List.filled(matchIds.length, '?').join(', ');

        await transaction.delete(
          DatabaseTables.liveSets,
          where: 'match_id IN ($placeholders)',
          whereArgs: matchIds,
        );
      }

      await transaction.update(
        DatabaseTables.matches,
        {'status': 'finished', 'finished_at': now, 'updated_at': now},
        where: 'event_id = ? AND status != ?',
        whereArgs: [eventId, 'finished'],
      );

      await transaction.update(
        DatabaseTables.events,
        {'status': 'finished', 'updated_at': now},
        where: 'id = ?',
        whereArgs: [eventId],
      );
    });
  }

  Future<void> deleteEvent(int eventId) async {
    final db = await _database;

    await db.transaction((transaction) async {
      final eventMatches = await transaction.query(
        DatabaseTables.matches,
        columns: ['id'],
        where: 'event_id = ?',
        whereArgs: [eventId],
      );

      final matchIds = eventMatches.map((match) => match['id'] as int).toList();

      if (matchIds.isNotEmpty) {
        final placeholders = List.filled(matchIds.length, '?').join(', ');

        await transaction.delete(
          DatabaseTables.liveSets,
          where: 'match_id IN ($placeholders)',
          whereArgs: matchIds,
        );
      }

      await transaction.delete(
        DatabaseTables.events,
        where: 'id = ?',
        whereArgs: [eventId],
      );
    });
  }

  Future<Map<String, Object?>?> _getActiveEvent(DatabaseExecutor db) async {
    final activeMatchEvents = await db.rawQuery(
      '''
      SELECT events.*
      FROM ${DatabaseTables.matches} matches
      INNER JOIN ${DatabaseTables.events} events ON events.id = matches.event_id
      WHERE matches.status = ?
      ORDER BY datetime(matches.started_at) DESC, matches.id DESC
      LIMIT 1
      ''',
      ['in_progress'],
    );

    if (activeMatchEvents.isNotEmpty) {
      return activeMatchEvents.first;
    }

    final activeEvents = await db.query(
      DatabaseTables.events,
      where: 'status = ?',
      whereArgs: ['in_progress'],
      orderBy: 'datetime(updated_at) DESC, id DESC',
      limit: 1,
    );

    if (activeEvents.isEmpty) {
      return null;
    }

    return activeEvents.first;
  }

  Future<_EventCounters> _getEventCounters(
    DatabaseExecutor db,
    int eventId,
  ) async {
    final teamCounter = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM ${DatabaseTables.teams} WHERE event_id = ?',
        [eventId],
      ),
    );
    final matchCounter = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM ${DatabaseTables.matches} WHERE event_id = ?',
        [eventId],
      ),
    );

    return _EventCounters(teams: teamCounter ?? 0, matches: matchCounter ?? 0);
  }

  Future<String?> _getEventChampionTeamName(
    DatabaseExecutor db,
    int eventId,
  ) async {
    final result = await db.rawQuery(
      '''
      SELECT teams.name
      FROM ${DatabaseTables.matches} matches
      INNER JOIN ${DatabaseTables.teams} teams
        ON teams.id = matches.winner_team_id
      WHERE matches.event_id = ?
        AND matches.winner_team_id IS NOT NULL
      ORDER BY datetime(COALESCE(matches.finished_at, matches.updated_at, matches.started_at)) DESC,
        matches.id DESC
      LIMIT 1
      ''',
      [eventId],
    );

    if (result.isEmpty) {
      return null;
    }

    return result.first['name'] as String;
  }

  Future<EventProgressEntity> _buildEventProgress(
    DatabaseExecutor db,
    Map<String, Object?> event,
  ) async {
    final eventId = event['id'] as int;
    final matches = await _getEventMatches(db, eventId);
    final currentMatch = _currentMatchFrom(matches);
    final teams = await _getEventTeams(
      db,
      eventId: eventId,
      matches: matches,
      currentMatch: currentMatch,
    );

    return EventProgressEntity(
      eventId: eventId,
      name: event['name'] as String,
      status: event['status'] as String,
      startedAt: _dateTimeFrom(event['event_date']),
      teams: teams,
      matches: matches,
      currentMatch: currentMatch,
    );
  }

  EventMatchProgressEntity? _currentMatchFrom(
    List<EventMatchProgressEntity> matches,
  ) {
    for (final match in matches.reversed) {
      if (match.status == 'in_progress') {
        return match;
      }
    }

    return null;
  }

  Future<List<EventTeamProgressEntity>> _getEventTeams(
    DatabaseExecutor db, {
    required int eventId,
    required List<EventMatchProgressEntity> matches,
    required EventMatchProgressEntity? currentMatch,
  }) async {
    final teamRows = await db.rawQuery(
      '''
      SELECT
        teams.id,
        teams.name,
        COUNT(player_teams.id) AS players_count
      FROM ${DatabaseTables.teams} teams
      LEFT JOIN ${DatabaseTables.playerTeams} player_teams
        ON player_teams.team_id = teams.id
      WHERE teams.event_id = ?
      GROUP BY teams.id, teams.name
      ORDER BY teams.id ASC
      ''',
      [eventId],
    );

    final playingTeamIds = <int>{};

    if (currentMatch != null) {
      playingTeamIds.addAll([currentMatch.homeTeamId, currentMatch.awayTeamId]);
    }

    final matchesPlayedByTeam = <int, int>{};
    final winsByTeam = <int, int>{};
    final lastMatchByTeam = <int, int>{};

    for (final match in matches) {
      for (final teamId in [match.homeTeamId, match.awayTeamId]) {
        matchesPlayedByTeam[teamId] = (matchesPlayedByTeam[teamId] ?? 0) + 1;
        lastMatchByTeam[teamId] = match.id;
      }

      final winnerTeamId = match.winnerTeamId;

      if (winnerTeamId != null) {
        winsByTeam[winnerTeamId] = (winsByTeam[winnerTeamId] ?? 0) + 1;
      }
    }

    final waitingTeamIds =
        teamRows
            .map((team) => team['id'] as int)
            .where((teamId) => !playingTeamIds.contains(teamId))
            .toList()
          ..sort((firstTeamId, secondTeamId) {
            final firstLastMatch = lastMatchByTeam[firstTeamId];
            final secondLastMatch = lastMatchByTeam[secondTeamId];

            if (firstLastMatch == null && secondLastMatch != null) {
              return -1;
            }

            if (firstLastMatch != null && secondLastMatch == null) {
              return 1;
            }

            final lastMatchComparison = (firstLastMatch ?? 0).compareTo(
              secondLastMatch ?? 0,
            );

            if (lastMatchComparison != 0) {
              return lastMatchComparison;
            }

            return firstTeamId.compareTo(secondTeamId);
          });

    final waitingOrderByTeam = <int, int>{};

    for (var index = 0; index < waitingTeamIds.length; index++) {
      waitingOrderByTeam[waitingTeamIds[index]] = index + 1;
    }

    return teamRows.map((team) {
      final teamId = team['id'] as int;

      return EventTeamProgressEntity(
        id: teamId,
        name: team['name'] as String,
        playersCount: team['players_count'] as int,
        matchesPlayed: matchesPlayedByTeam[teamId] ?? 0,
        wins: winsByTeam[teamId] ?? 0,
        isPlaying: playingTeamIds.contains(teamId),
        waitingOrder: waitingOrderByTeam[teamId],
      );
    }).toList();
  }

  Future<List<EventMatchProgressEntity>> _getEventMatches(
    DatabaseExecutor db,
    int eventId,
  ) async {
    final matchRows = await db.query(
      DatabaseTables.matches,
      where: 'event_id = ?',
      whereArgs: [eventId],
      orderBy: 'datetime(COALESCE(started_at, scheduled_at, created_at)) ASC',
    );

    final matches = <EventMatchProgressEntity>[];

    for (final match in matchRows) {
      final teams = await _getMatchTeams(db, match['id'] as int);

      if (teams.length < 2) {
        continue;
      }

      final sets = await _getMatchSets(db, match['id'] as int);
      final winnerTeamId = match['winner_team_id'] as int?;

      matches.add(
        EventMatchProgressEntity(
          id: match['id'] as int,
          status: match['status'] as String,
          homeTeamId: teams[0].id,
          homeTeamName: teams[0].name,
          awayTeamId: teams[1].id,
          awayTeamName: teams[1].name,
          winnerTeamId: winnerTeamId,
          winnerTeamName: _winnerNameFrom(teams, winnerTeamId),
          startedAt: _dateTimeFrom(
            match['started_at'] ?? match['scheduled_at'] ?? match['created_at'],
          ),
          finishedAt: _nullableDateTimeFrom(match['finished_at']),
          bestOfSets: match['best_of_sets'] as int,
          pointsPerSet: match['points_per_set'] as int,
          completedSets: sets,
        ),
      );
    }

    return matches;
  }

  Future<List<_EventMatchTeamRow>> _getMatchTeams(
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

    return result.map((team) {
      return _EventMatchTeamRow(
        id: team['id'] as int,
        name: team['name'] as String,
      );
    }).toList();
  }

  Future<List<EventSetProgressEntity>> _getMatchSets(
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
      return EventSetProgressEntity(
        number: set['set_number'] as int,
        homeScore: set['home_score'] as int,
        awayScore: set['away_score'] as int,
        winnerTeamId: set['winner_team_id'] as int,
      );
    }).toList();
  }

  String? _winnerNameFrom(List<_EventMatchTeamRow> teams, int? winnerTeamId) {
    if (winnerTeamId == null) {
      return null;
    }

    for (final team in teams) {
      if (team.id == winnerTeamId) {
        return team.name;
      }
    }

    return null;
  }

  DateTime _dateTimeFrom(Object? value) {
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }

    return DateTime.now();
  }

  DateTime? _nullableDateTimeFrom(Object? value) {
    if (value is! String) {
      return null;
    }

    return DateTime.tryParse(value);
  }
}

class _EventMatchTeamRow {
  const _EventMatchTeamRow({required this.id, required this.name});

  final int id;
  final String name;
}

class _EventCounters {
  const _EventCounters({required this.teams, required this.matches});

  final int teams;
  final int matches;
}
