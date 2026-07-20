import '../entities/player_entity.dart';

abstract class PlayersRepository {
  Future<List<PlayerEntity>> getPlayers();

  Future<void> addPlayer(PlayerEntity player);

  Future<void> updatePlayer(PlayerEntity player);

  Future<void> removePlayer(int playerId);
}
