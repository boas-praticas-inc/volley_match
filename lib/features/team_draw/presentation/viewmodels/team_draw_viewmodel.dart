import 'package:flutter/foundation.dart';

import '../../../players/data/repositories/players_repository_impl.dart';
import '../../../players/domain/entities/player_entity.dart';
import '../../../players/domain/repositories/players_repository.dart';

class TeamDrawViewModel extends ChangeNotifier {
  TeamDrawViewModel({PlayersRepository? repository})
    : _repository = repository ?? PlayersRepositoryImpl();

  final PlayersRepository _repository;

  List<PlayerEntity> _players = [];
  final Set<int> _selectedPlayerIds = {};
  bool _isLoading = false;
  String? _errorMessage;

  List<PlayerEntity> get players => List.unmodifiable(_players);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get totalPlayersCount => _players.length;
  int get selectedPlayersCount => _selectedPlayerIds.length;
  bool get canDrawTeams => _selectedPlayerIds.isNotEmpty;

  Future<void> loadPlayers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _players = await _repository.getPlayers();
      _selectedPlayerIds
        ..clear()
        ..addAll(_players.map((player) => player.id));
    } catch (_) {
      _errorMessage = 'Nao foi possivel carregar os jogadores.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isPlayerSelected(int playerId) {
    return _selectedPlayerIds.contains(playerId);
  }

  void togglePlayerSelection(int playerId) {
    if (_selectedPlayerIds.contains(playerId)) {
      _selectedPlayerIds.remove(playerId);
    } else {
      _selectedPlayerIds.add(playerId);
    }

    notifyListeners();
  }
}
