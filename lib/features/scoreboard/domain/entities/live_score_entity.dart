class LiveScoreEntity {
  const LiveScoreEntity({
    required this.matchId,
    required this.setNumber,
    required this.homeScore,
    required this.awayScore,
    this.pointScoringTeamIds = const [],
  });

  final int matchId;
  final int setNumber;
  final int homeScore;
  final int awayScore;
  final List<int> pointScoringTeamIds;
}
