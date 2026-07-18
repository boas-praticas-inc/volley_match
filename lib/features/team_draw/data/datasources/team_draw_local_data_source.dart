import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_tables.dart';
import '../../domain/entities/drawn_team_entity.dart';
import '../../domain/repositories/team_draw_repository.dart';

class TeamDrawLocalDataSource {
  TeamDrawLocalDataSource({AppDatabase? appDatabase})
    : _appDatabase = appDatabase ?? AppDatabase.instance;

  final AppDatabase _appDatabase;

  Future<Database> get _database async => _appDatabase.database;

  Future<TeamDrawPersistenceResult> saveDraw({
    required List<DrawnTeamEntity> teams,
    int? eventId,
  }) async {
    final db = await _database;
    final now = DateTime.now().toIso8601String();

    return db.transaction((transaction) async {
      final persistedEventId =
          eventId ?? await _insertDrawEvent(transaction, now);

      if (eventId != null) {
        await _touchDrawEvent(transaction, eventId, now);
        await _deleteEventTeams(transaction, eventId);
      }

      final persistedTeams = <DrawnTeamEntity>[];

      for (final team in teams) {
        final teamId = await transaction.insert(DatabaseTables.teams, {
          'event_id': persistedEventId,
          'name': team.name,
          'color': null,
          'origin': 'draw',
          'created_at': now,
        });

        for (var index = 0; index < team.players.length; index++) {
          await transaction.insert(DatabaseTables.playerTeams, {
            'team_id': teamId,
            'player_id': team.players[index].id,
            'is_present': 1,
            'is_captain': 0,
            'rotation_order': index + 1,
            'assigned_position': null,
            'created_at': now,
          });
        }

        persistedTeams.add(team.copyWith(id: teamId));
      }

      return TeamDrawPersistenceResult(
        eventId: persistedEventId,
        teams: persistedTeams,
      );
    });
  }

  Future<void> updateTeamName({
    required int teamId,
    required String name,
  }) async {
    final db = await _database;

    await db.update(
      DatabaseTables.teams,
      {'name': name},
      where: 'id = ?',
      whereArgs: [teamId],
    );
  }

  Future<int> _insertDrawEvent(Transaction transaction, String now) {
    return transaction.insert(DatabaseTables.events, {
      'name': 'Sorteio de times',
      'description': null,
      'event_date': now,
      'location': null,
      'status': 'in_progress',
      'created_at': now,
      'updated_at': now,
    });
  }

  Future<void> _touchDrawEvent(
    Transaction transaction,
    int eventId,
    String now,
  ) {
    return transaction.update(
      DatabaseTables.events,
      {'updated_at': now},
      where: 'id = ?',
      whereArgs: [eventId],
    );
  }

  Future<void> _deleteEventTeams(Transaction transaction, int eventId) async {
    final eventTeams = await transaction.query(
      DatabaseTables.teams,
      columns: ['id'],
      where: 'event_id = ?',
      whereArgs: [eventId],
    );

    final teamIds = eventTeams.map((team) => team['id'] as int).toList();

    if (teamIds.isNotEmpty) {
      final placeholders = List.filled(teamIds.length, '?').join(', ');

      await transaction.delete(
        DatabaseTables.playerTeams,
        where: 'team_id IN ($placeholders)',
        whereArgs: teamIds,
      );
    }

    await transaction.delete(
      DatabaseTables.teams,
      where: 'event_id = ?',
      whereArgs: [eventId],
    );
  }
}
