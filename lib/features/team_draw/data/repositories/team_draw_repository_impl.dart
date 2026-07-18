import '../../domain/entities/drawn_team_entity.dart';
import '../../domain/repositories/team_draw_repository.dart';
import '../datasources/team_draw_local_data_source.dart';

class TeamDrawRepositoryImpl implements TeamDrawRepository {
  TeamDrawRepositoryImpl({TeamDrawLocalDataSource? localDataSource})
    : _localDataSource = localDataSource ?? TeamDrawLocalDataSource();

  final TeamDrawLocalDataSource _localDataSource;

  @override
  Future<TeamDrawPersistenceResult> saveDraw({
    required List<DrawnTeamEntity> teams,
    int? eventId,
  }) {
    return _localDataSource.saveDraw(teams: teams, eventId: eventId);
  }

  @override
  Future<void> updateTeamName({required int teamId, required String name}) {
    return _localDataSource.updateTeamName(teamId: teamId, name: name);
  }
}
