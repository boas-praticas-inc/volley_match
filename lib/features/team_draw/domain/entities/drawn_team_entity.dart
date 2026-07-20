import '../../../players/domain/entities/player_entity.dart';

class DrawnTeamEntity {
  const DrawnTeamEntity({this.id, required this.name, required this.players});

  final int? id;
  final String name;
  final List<PlayerEntity> players;

  DrawnTeamEntity copyWith({
    int? id,
    String? name,
    List<PlayerEntity>? players,
  }) {
    return DrawnTeamEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      players: players ?? this.players,
    );
  }
}
