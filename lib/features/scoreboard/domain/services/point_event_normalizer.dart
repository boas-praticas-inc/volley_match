import '../entities/live_score_entity.dart';
import '../entities/scoreboard_match_entity.dart';

class PointEventNormalizer {
  const PointEventNormalizer();

  LiveScoreEntity normalizedLiveScore({
    required ScoreboardMatchEntity match,
    required int currentSetNumber,
    required LiveScoreEntity? liveScore,
  }) {
    if (liveScore == null) {
      return LiveScoreEntity(
        matchId: match.matchId,
        setNumber: currentSetNumber,
        homeScore: 0,
        awayScore: 0,
      );
    }

    return LiveScoreEntity(
      matchId: liveScore.matchId,
      setNumber: liveScore.setNumber,
      homeScore: liveScore.homeScore,
      awayScore: liveScore.awayScore,
      pointScoringTeamIds: normalizedPointScoringTeamIds(
        match: match,
        currentSetNumber: currentSetNumber,
        liveScore: liveScore,
      ),
    );
  }

  List<int> normalizedPointScoringTeamIds({
    required ScoreboardMatchEntity match,
    required int currentSetNumber,
    required LiveScoreEntity? liveScore,
  }) {
    if (liveScore == null) {
      return [];
    }

    final expectedEventsCount = liveScore.homeScore + liveScore.awayScore;

    if (liveScore.pointScoringTeamIds.length == expectedEventsCount) {
      return [...liveScore.pointScoringTeamIds];
    }

    return _syntheticPointScoringTeamIds(
      match: match,
      currentSetNumber: currentSetNumber,
      homeScore: liveScore.homeScore,
      awayScore: liveScore.awayScore,
    );
  }

  List<int> _syntheticPointScoringTeamIds({
    required ScoreboardMatchEntity match,
    required int currentSetNumber,
    required int homeScore,
    required int awayScore,
  }) {
    final events = <int>[];
    var remainingHomeScore = homeScore;
    var remainingAwayScore = awayScore;
    var nextTeamId = initialServingTeamId(
      match: match,
      currentSetNumber: currentSetNumber,
    );

    while (remainingHomeScore > 0 || remainingAwayScore > 0) {
      if (nextTeamId == match.homeTeam.id && remainingHomeScore > 0) {
        events.add(match.homeTeam.id);
        remainingHomeScore -= 1;
      } else if (nextTeamId == match.awayTeam.id && remainingAwayScore > 0) {
        events.add(match.awayTeam.id);
        remainingAwayScore -= 1;
      } else if (remainingHomeScore >= remainingAwayScore &&
          remainingHomeScore > 0) {
        events.add(match.homeTeam.id);
        remainingHomeScore -= 1;
      } else {
        events.add(match.awayTeam.id);
        remainingAwayScore -= 1;
      }

      nextTeamId = nextTeamId == match.homeTeam.id
          ? match.awayTeam.id
          : match.homeTeam.id;
    }

    return events;
  }

  int initialServingTeamId({
    required ScoreboardMatchEntity match,
    required int currentSetNumber,
  }) {
    return currentSetNumber.isOdd ? match.awayTeam.id : match.homeTeam.id;
  }
}
