import 'package:flutter_test/flutter_test.dart';
import 'package:volley_match/features/scoreboard/domain/services/match_queue_service.dart';

void main() {
  group('MatchQueueService', () {
    test('keeps home winner at home and brings least recently used team', () {
      const service = MatchQueueService();

      final nextMatch = service.nextMatch(
        eventTeamIds: const [1, 2, 3],
        eventParticipations: const [
          MatchQueueTeamParticipation(
            matchId: 10,
            teamId: 1,
            side: MatchQueueSide.home,
          ),
          MatchQueueTeamParticipation(
            matchId: 10,
            teamId: 2,
            side: MatchQueueSide.away,
          ),
        ],
        currentMatchParticipations: const [
          MatchQueueTeamParticipation(
            matchId: 10,
            teamId: 1,
            side: MatchQueueSide.home,
          ),
          MatchQueueTeamParticipation(
            matchId: 10,
            teamId: 2,
            side: MatchQueueSide.away,
          ),
        ],
        winnerTeamId: 1,
      );

      expect(nextMatch?.homeTeamId, 1);
      expect(nextMatch?.awayTeamId, 3);
    });

    test('keeps away winner at away and brings next team to home', () {
      const service = MatchQueueService();

      final nextMatch = service.nextMatch(
        eventTeamIds: const [1, 2, 3],
        eventParticipations: const [
          MatchQueueTeamParticipation(
            matchId: 10,
            teamId: 1,
            side: MatchQueueSide.home,
          ),
          MatchQueueTeamParticipation(
            matchId: 10,
            teamId: 2,
            side: MatchQueueSide.away,
          ),
        ],
        currentMatchParticipations: const [
          MatchQueueTeamParticipation(
            matchId: 10,
            teamId: 1,
            side: MatchQueueSide.home,
          ),
          MatchQueueTeamParticipation(
            matchId: 10,
            teamId: 2,
            side: MatchQueueSide.away,
          ),
        ],
        winnerTeamId: 2,
      );

      expect(nextMatch?.homeTeamId, 3);
      expect(nextMatch?.awayTeamId, 2);
    });

    test('does not create next match when event has only two teams', () {
      const service = MatchQueueService();

      final nextMatch = service.nextMatch(
        eventTeamIds: const [1, 2],
        eventParticipations: const [
          MatchQueueTeamParticipation(
            matchId: 10,
            teamId: 1,
            side: MatchQueueSide.home,
          ),
          MatchQueueTeamParticipation(
            matchId: 10,
            teamId: 2,
            side: MatchQueueSide.away,
          ),
        ],
        currentMatchParticipations: const [
          MatchQueueTeamParticipation(
            matchId: 10,
            teamId: 1,
            side: MatchQueueSide.home,
          ),
          MatchQueueTeamParticipation(
            matchId: 10,
            teamId: 2,
            side: MatchQueueSide.away,
          ),
        ],
        winnerTeamId: 1,
      );

      expect(nextMatch, isNull);
    });

    test('chooses team with oldest last match when all teams have played', () {
      const service = MatchQueueService();

      final nextMatch = service.nextMatch(
        eventTeamIds: const [1, 2, 3, 4],
        eventParticipations: const [
          MatchQueueTeamParticipation(
            matchId: 1,
            teamId: 3,
            side: MatchQueueSide.home,
          ),
          MatchQueueTeamParticipation(
            matchId: 1,
            teamId: 4,
            side: MatchQueueSide.away,
          ),
          MatchQueueTeamParticipation(
            matchId: 2,
            teamId: 1,
            side: MatchQueueSide.home,
          ),
          MatchQueueTeamParticipation(
            matchId: 2,
            teamId: 4,
            side: MatchQueueSide.away,
          ),
          MatchQueueTeamParticipation(
            matchId: 3,
            teamId: 1,
            side: MatchQueueSide.home,
          ),
          MatchQueueTeamParticipation(
            matchId: 3,
            teamId: 2,
            side: MatchQueueSide.away,
          ),
        ],
        currentMatchParticipations: const [
          MatchQueueTeamParticipation(
            matchId: 3,
            teamId: 1,
            side: MatchQueueSide.home,
          ),
          MatchQueueTeamParticipation(
            matchId: 3,
            teamId: 2,
            side: MatchQueueSide.away,
          ),
        ],
        winnerTeamId: 1,
      );

      expect(nextMatch?.homeTeamId, 1);
      expect(nextMatch?.awayTeamId, 3);
    });
  });
}
