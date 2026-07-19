class MatchQueueService {
  const MatchQueueService();

  NextMatchConfiguration? nextMatch({
    required List<int> eventTeamIds,
    required List<MatchQueueTeamParticipation> eventParticipations,
    required List<MatchQueueTeamParticipation> currentMatchParticipations,
    required int winnerTeamId,
  }) {
    if (eventTeamIds.length <= 2 || currentMatchParticipations.length < 2) {
      return null;
    }

    final winnerParticipation = _winnerParticipation(
      currentMatchParticipations: currentMatchParticipations,
      winnerTeamId: winnerTeamId,
    );

    if (winnerParticipation == null) {
      return null;
    }

    final nextTeamId = _nextQueuedTeamId(
      eventTeamIds: eventTeamIds,
      eventParticipations: eventParticipations,
      winnerTeamId: winnerTeamId,
    );

    if (nextTeamId == null) {
      return null;
    }

    if (winnerParticipation.side == MatchQueueSide.home) {
      return NextMatchConfiguration(
        homeTeamId: winnerTeamId,
        awayTeamId: nextTeamId,
      );
    }

    return NextMatchConfiguration(
      homeTeamId: nextTeamId,
      awayTeamId: winnerTeamId,
    );
  }

  MatchQueueTeamParticipation? _winnerParticipation({
    required List<MatchQueueTeamParticipation> currentMatchParticipations,
    required int winnerTeamId,
  }) {
    for (final participation in currentMatchParticipations) {
      if (participation.teamId == winnerTeamId) {
        return participation;
      }
    }

    return null;
  }

  int? _nextQueuedTeamId({
    required List<int> eventTeamIds,
    required List<MatchQueueTeamParticipation> eventParticipations,
    required int winnerTeamId,
  }) {
    final lastMatchByTeamId = <int, int>{};

    for (final participation in eventParticipations) {
      final lastMatchId = lastMatchByTeamId[participation.teamId];

      if (lastMatchId == null || participation.matchId > lastMatchId) {
        lastMatchByTeamId[participation.teamId] = participation.matchId;
      }
    }

    final waitingTeamIds =
        eventTeamIds.where((teamId) => teamId != winnerTeamId).toList()
          ..sort((firstTeamId, secondTeamId) {
            final firstLastMatch = lastMatchByTeamId[firstTeamId];
            final secondLastMatch = lastMatchByTeamId[secondTeamId];

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

    if (waitingTeamIds.isEmpty) {
      return null;
    }

    return waitingTeamIds.first;
  }
}

class NextMatchConfiguration {
  const NextMatchConfiguration({
    required this.homeTeamId,
    required this.awayTeamId,
  });

  final int homeTeamId;
  final int awayTeamId;
}

class MatchQueueTeamParticipation {
  const MatchQueueTeamParticipation({
    required this.matchId,
    required this.teamId,
    required this.side,
  });

  final int matchId;
  final int teamId;
  final MatchQueueSide side;
}

enum MatchQueueSide {
  home,
  away;

  static MatchQueueSide? fromValue(String value) {
    return switch (value) {
      'home' => MatchQueueSide.home,
      'away' => MatchQueueSide.away,
      _ => null,
    };
  }
}
