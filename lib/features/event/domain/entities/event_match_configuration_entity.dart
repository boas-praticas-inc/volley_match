class EventMatchConfigurationEntity {
  const EventMatchConfigurationEntity({
    required this.eventId,
    required this.homeTeamId,
    required this.awayTeamId,
    required this.bestOfSets,
    required this.setsToWin,
    required this.pointsPerSet,
  });

  final int eventId;
  final int homeTeamId;
  final int awayTeamId;
  final int bestOfSets;
  final int setsToWin;
  final int pointsPerSet;
}
