import '../../domain/entities/player_entity.dart';
import '../../domain/repositories/players_repository.dart';
import '../datasources/players_local_data_source.dart';
import '../models/player_model.dart';

class PlayersRepositoryImpl implements PlayersRepository {
  PlayersRepositoryImpl({PlayersLocalDataSource? localDataSource})
    : _localDataSource = localDataSource ?? PlayersLocalDataSource();

  final PlayersLocalDataSource _localDataSource;

  @override
  Future<List<PlayerEntity>> getPlayers() {
    return _localDataSource.getPlayers();
  }

  @override
  Future<void> addPlayer(PlayerEntity player) {
    return _localDataSource.insertPlayer(PlayerModel.fromEntity(player));
  }

  @override
  Future<void> updatePlayer(PlayerEntity player) {
    return _localDataSource.updatePlayer(PlayerModel.fromEntity(player));
  }

  @override
  Future<void> removePlayer(int playerId) {
    return _localDataSource.deletePlayer(playerId);
  }
}
