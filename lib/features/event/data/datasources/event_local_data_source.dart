import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_tables.dart';
import '../../domain/entities/event_match_configuration_entity.dart';

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
}
