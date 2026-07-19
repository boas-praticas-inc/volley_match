class EventProgressEntity {
  const EventProgressEntity({
    required this.eventId,
    required this.name,
    required this.status,
    required this.startedAt,
    required this.teams,
    required this.matches,
    required this.currentMatch,
  });

  final int eventId;
  final String name;
  final String status;
  final DateTime startedAt;
  final List<EventTeamProgressEntity> teams;
  final List<EventMatchProgressEntity> matches;
  final EventMatchProgressEntity? currentMatch;

  int get totalTeams => teams.length;

  int get totalMatches => matches.length;

  int get finishedMatches {
    return matches.where((match) => match.status == 'finished').length;
  }

  int get totalPlayers {
    return teams.fold(0, (total, team) => total + team.playersCount);
  }
}

class EventTeamProgressEntity {
  const EventTeamProgressEntity({
    required this.id,
    required this.name,
    required this.playersCount,
    required this.matchesPlayed,
    required this.wins,
    required this.isPlaying,
    required this.waitingOrder,
  });

  final int id;
  final String name;
  final int playersCount;
  final int matchesPlayed;
  final int wins;
  final bool isPlaying;
  final int? waitingOrder;
}

class EventMatchProgressEntity {
  const EventMatchProgressEntity({
    required this.id,
    required this.status,
    required this.homeTeamId,
    required this.homeTeamName,
    required this.awayTeamId,
    required this.awayTeamName,
    required this.winnerTeamId,
    required this.winnerTeamName,
    required this.startedAt,
    required this.finishedAt,
    required this.bestOfSets,
    required this.pointsPerSet,
    required this.completedSets,
  });

  final int id;
  final String status;
  final int homeTeamId;
  final String homeTeamName;
  final int awayTeamId;
  final String awayTeamName;
  final int? winnerTeamId;
  final String? winnerTeamName;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final int bestOfSets;
  final int pointsPerSet;
  final List<EventSetProgressEntity> completedSets;

  String get scoreLabel {
    final homeSets = completedSets
        .where((set) => set.winnerTeamId == homeTeamId)
        .length;
    final awaySets = completedSets
        .where((set) => set.winnerTeamId == awayTeamId)
        .length;

    return '$homeSets x $awaySets';
  }
}

class EventSetProgressEntity {
  const EventSetProgressEntity({
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
