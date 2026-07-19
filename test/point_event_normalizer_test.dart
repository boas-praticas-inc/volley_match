import 'package:flutter_test/flutter_test.dart';
import 'package:volley_match/features/scoreboard/domain/entities/live_score_entity.dart';
import 'package:volley_match/features/scoreboard/domain/entities/scoreboard_match_entity.dart';
import 'package:volley_match/features/scoreboard/domain/services/point_event_normalizer.dart';

void main() {
  group('PointEventNormalizer', () {
    test('keeps point events when count matches score', () {
      const normalizer = PointEventNormalizer();
      final match = _match();

      final events = normalizer.normalizedPointScoringTeamIds(
        match: match,
        currentSetNumber: 1,
        liveScore: LiveScoreEntity(
          matchId: match.matchId,
          setNumber: 1,
          homeScore: 2,
          awayScore: 1,
          pointScoringTeamIds: [match.homeTeam.id, match.awayTeam.id, 999],
        ),
      );

      expect(events, [match.homeTeam.id, match.awayTeam.id, 999]);
    });

    test(
      'rebuilds missing point events starting with away team on odd sets',
      () {
        const normalizer = PointEventNormalizer();
        final match = _match();

        final events = normalizer.normalizedPointScoringTeamIds(
          match: match,
          currentSetNumber: 1,
          liveScore: LiveScoreEntity(
            matchId: match.matchId,
            setNumber: 1,
            homeScore: 2,
            awayScore: 1,
          ),
        );

        expect(events, [
          match.awayTeam.id,
          match.homeTeam.id,
          match.homeTeam.id,
        ]);
      },
    );

    test(
      'rebuilds missing point events starting with home team on even sets',
      () {
        const normalizer = PointEventNormalizer();
        final match = _match();

        final events = normalizer.normalizedPointScoringTeamIds(
          match: match,
          currentSetNumber: 2,
          liveScore: LiveScoreEntity(
            matchId: match.matchId,
            setNumber: 2,
            homeScore: 1,
            awayScore: 2,
          ),
        );

        expect(events, [
          match.homeTeam.id,
          match.awayTeam.id,
          match.awayTeam.id,
        ]);
      },
    );

    test('creates an empty live score when no live score exists', () {
      const normalizer = PointEventNormalizer();
      final match = _match();

      final liveScore = normalizer.normalizedLiveScore(
        match: match,
        currentSetNumber: 2,
        liveScore: null,
      );

      expect(liveScore.matchId, match.matchId);
      expect(liveScore.setNumber, 2);
      expect(liveScore.homeScore, 0);
      expect(liveScore.awayScore, 0);
      expect(liveScore.pointScoringTeamIds, isEmpty);
    });
  });
}

ScoreboardMatchEntity _match() {
  return ScoreboardMatchEntity(
    matchId: 10,
    eventId: 20,
    homeTeam: const ScoreboardTeamEntity(id: 1, name: 'Home'),
    awayTeam: const ScoreboardTeamEntity(id: 2, name: 'Away'),
    startedAt: DateTime(2026),
    finishedAt: null,
    bestOfSets: 3,
    setsToWin: 2,
    pointsPerSet: 25,
    status: 'in_progress',
    completedSets: const [],
  );
}
