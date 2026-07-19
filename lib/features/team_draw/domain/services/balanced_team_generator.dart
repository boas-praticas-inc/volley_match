import 'dart:math';

import '../../../players/domain/entities/player_entity.dart';

class BalancedTeamGenerator {
  List<List<PlayerEntity>> call({
    required List<PlayerEntity> players,
    required int teamsCount,
    required int playersPerTeam,
    Random? random,
  }) {
    final randomizer = random ?? Random();
    final shuffledPlayers = [...players]..shuffle(randomizer);
    shuffledPlayers.sort(
      (left, right) => right.skillRating.compareTo(left.skillRating),
    );

    final generatedTeams = List.generate(teamsCount, (_) => <PlayerEntity>[]);

    var playerIndex = 0;
    final startsForward = randomizer.nextBool();

    for (var round = 0; round < playersPerTeam; round++) {
      final movesForward = round.isEven ? startsForward : !startsForward;
      final teamIndexes = movesForward
          ? List.generate(teamsCount, (index) => index)
          : List.generate(teamsCount, (index) => teamsCount - 1 - index);

      for (final teamIndex in teamIndexes) {
        generatedTeams[teamIndex].add(shuffledPlayers[playerIndex]);
        playerIndex += 1;
      }
    }

    return generatedTeams;
  }
}
