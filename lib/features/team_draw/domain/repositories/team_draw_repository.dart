import '../entities/drawn_team_entity.dart';

class TeamDrawPersistenceResult {
  const TeamDrawPersistenceResult({required this.eventId, required this.teams});

  final int eventId;
  final List<DrawnTeamEntity> teams;
}

abstract class TeamDrawRepository {
  Future<TeamDrawPersistenceResult> saveDraw({
    required List<DrawnTeamEntity> teams,
    int? eventId,
  });

  Future<void> updateTeamName({required int teamId, required String name});
}
