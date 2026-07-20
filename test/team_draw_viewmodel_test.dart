import 'package:flutter_test/flutter_test.dart';
import 'package:volley_match/features/players/domain/entities/player_entity.dart';
import 'package:volley_match/features/players/domain/repositories/players_repository.dart';
import 'package:volley_match/features/team_draw/presentation/viewmodels/team_draw_viewmodel.dart';

class _FakePlayersRepository implements PlayersRepository {
  _FakePlayersRepository(this.players);

  final List<PlayerEntity> players;

  @override
  Future<List<PlayerEntity>> getPlayers() async => players;

  @override
  Future<void> addPlayer(PlayerEntity player) async {}

  @override
  Future<void> updatePlayer(PlayerEntity player) async {}

  @override
  Future<void> removePlayer(int playerId) async {}
}

void main() {
  test('loadPlayers keeps available players unselected by default', () async {
    final viewModel = TeamDrawViewModel(
      repository: _FakePlayersRepository(const [
        PlayerEntity(id: 1, name: 'Ana', skillRating: 8, position: 'Ponteiro'),
        PlayerEntity(id: 2, name: 'Bruno', skillRating: 7, position: 'Central'),
      ]),
    );

    await viewModel.loadPlayers();

    expect(viewModel.totalPlayersCount, 2);
    expect(viewModel.selectedPlayersCount, 0);
    expect(viewModel.selectedPlayers, isEmpty);
    expect(viewModel.isPlayerSelected(1), isFalse);
    expect(viewModel.isPlayerSelected(2), isFalse);
  });
}
