import '../../../players/domain/entities/player_entity.dart';

class TeamDrawResultItem {
  const TeamDrawResultItem({
    required this.index,
    required this.title,
    required this.players,
  });

  final int index;
  final String title;
  final List<PlayerEntity> players;
}
