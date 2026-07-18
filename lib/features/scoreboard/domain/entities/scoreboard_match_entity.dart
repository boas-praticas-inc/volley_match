class ScoreboardMatchEntity {
  const ScoreboardMatchEntity({
    required this.matchId,
    required this.eventId,
    required this.homeTeam,
    required this.awayTeam,
    required this.bestOfSets,
    required this.setsToWin,
    required this.pointsPerSet,
    required this.status,
    required this.completedSets,
  });

  final int matchId;
  final int eventId;
  final ScoreboardTeamEntity homeTeam;
  final ScoreboardTeamEntity awayTeam;
  final int bestOfSets;
  final int setsToWin;
  final int pointsPerSet;
  final String status;
  final List<ScoreboardSetEntity> completedSets;
}

class ScoreboardTeamEntity {
  const ScoreboardTeamEntity({required this.id, required this.name});

  final int id;
  final String name;
}

class ScoreboardSetEntity {
  const ScoreboardSetEntity({
    required this.number,
    required this.homeScore,
    required this.awayScore,
    required this.winnerTeamId,
  });

  final int number;
  final int homeScore;
  final int awayScore;
  final int winnerTeamId;
}
