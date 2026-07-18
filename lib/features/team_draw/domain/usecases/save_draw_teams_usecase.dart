import '../entities/drawn_team_entity.dart';
import '../repositories/team_draw_repository.dart';

class SaveDrawTeamsUseCase {
  const SaveDrawTeamsUseCase(this._repository);

  final TeamDrawRepository _repository;

  Future<TeamDrawPersistenceResult> call({
    required List<DrawnTeamEntity> teams,
    int? eventId,
  }) {
    return _repository.saveDraw(teams: teams, eventId: eventId);
  }
}
