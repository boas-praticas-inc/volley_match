import 'package:flutter_test/flutter_test.dart';
import 'package:volley_match/features/rotation_guide/domain/entities/rotation_system_entity.dart';
import 'package:volley_match/features/rotation_guide/domain/services/rotation_calculator.dart';
import 'package:volley_match/features/scoreboard/domain/entities/live_score_entity.dart';
import 'package:volley_match/features/scoreboard/domain/entities/scoreboard_match_entity.dart';

void main() {
  group('RotationCalculator', () {
    test('starts 6x0 with setters fixed in P3 and away team serving', () {
      final match = _match();
      final state = RotationCalculator().build(
        match: match,
        system: RotationSystem.sixZero,
        liveScore: null,
        currentSetNumber: 1,
      );

      expect(state.homeTeam.isServing, isFalse);
      expect(state.awayTeam.isServing, isTrue);
      expect(_playerNameAt(state.homeTeam, 3), 'Home Setter');
      expect(_playerNameAt(state.awayTeam, 3), 'Away Setter');
    });

    test('rotates only the team that wins a side-out in 6x0', () {
      final match = _match();
      final state = RotationCalculator().build(
        match: match,
        system: RotationSystem.sixZero,
        liveScore: LiveScoreEntity(
          matchId: match.matchId,
          setNumber: 1,
          homeScore: 1,
          awayScore: 0,
          pointScoringTeamIds: [match.homeTeam.id],
        ),
        currentSetNumber: 1,
      );

      expect(state.homeTeam.isServing, isTrue);
      expect(state.awayTeam.isServing, isFalse);
      expect(state.homeTeam.rotationTurns, 1);
      expect(state.awayTeam.rotationTurns, 0);
      expect(_playerNameAt(state.homeTeam, 3), 'Home Setter');
      expect(_playerNameAt(state.homeTeam, 6), 'Home Middle');
      expect(_playerNameAt(state.awayTeam, 3), 'Away Setter');
    });

    test('keeps setter fixed in P3 for 6x0', () {
      final match = _match();
      final state = RotationCalculator().build(
        match: match,
        system: RotationSystem.sixZero,
        liveScore: LiveScoreEntity(
          matchId: match.matchId,
          setNumber: 1,
          homeScore: 2,
          awayScore: 1,
          pointScoringTeamIds: [
            match.homeTeam.id,
            match.awayTeam.id,
            match.homeTeam.id,
          ],
        ),
        currentSetNumber: 1,
      );

      expect(_playerNameAt(state.homeTeam, 3), 'Home Setter');
      expect(_playerNameAt(state.awayTeam, 3), 'Away Setter');
    });
  });
}

String? _playerNameAt(RotationTeamStateEntity team, int zone) {
  return team.positions
      .firstWhere((position) => position.zone == zone)
      .player
      ?.name;
}

ScoreboardMatchEntity _match() {
  return ScoreboardMatchEntity(
    matchId: 10,
    eventId: 20,
    homeTeam: ScoreboardTeamEntity(
      id: 1,
      name: 'Home',
      players: _players('Home'),
    ),
    awayTeam: ScoreboardTeamEntity(
      id: 2,
      name: 'Away',
      players: _players('Away'),
    ),
    startedAt: DateTime(2026),
    finishedAt: null,
    bestOfSets: 3,
    setsToWin: 2,
    pointsPerSet: 25,
    status: 'in_progress',
    completedSets: const [],
  );
}

List<ScoreboardPlayerEntity> _players(String prefix) {
  return [
    ScoreboardPlayerEntity(
      id: prefix == 'Home' ? 1 : 11,
      name: '$prefix Setter',
      position: 'Levantador',
      rotationOrder: 1,
    ),
    ScoreboardPlayerEntity(
      id: prefix == 'Home' ? 2 : 12,
      name: '$prefix Opposite',
      position: 'Oposto',
      rotationOrder: 2,
    ),
    ScoreboardPlayerEntity(
      id: prefix == 'Home' ? 3 : 13,
      name: '$prefix Middle',
      position: 'Central',
      rotationOrder: 3,
    ),
    ScoreboardPlayerEntity(
      id: prefix == 'Home' ? 4 : 14,
      name: '$prefix Outside A',
      position: 'Ponteiro',
      rotationOrder: 4,
    ),
    ScoreboardPlayerEntity(
      id: prefix == 'Home' ? 5 : 15,
      name: '$prefix Outside B',
      position: 'Ponteiro',
      rotationOrder: 5,
    ),
    ScoreboardPlayerEntity(
      id: prefix == 'Home' ? 6 : 16,
      name: '$prefix Libero',
      position: 'Libero',
      rotationOrder: 6,
    ),
  ];
}
