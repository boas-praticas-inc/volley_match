import 'package:flutter/foundation.dart';

import '../../data/repositories/players_repository_impl.dart';
import '../../data/services/player_photo_storage.dart';
import '../../domain/entities/player_entity.dart';
import '../../domain/repositories/players_repository.dart';

class PlayersViewModel extends ChangeNotifier {
  PlayersViewModel({PlayersRepository? repository})
    : _repository = repository ?? PlayersRepositoryImpl();

  static const allPositions = [
    'Todos',
    'Ponteiro',
    'Levantador',
    'Central',
    'Oposto',
    'Líbero',
  ];

  final PlayersRepository _repository;
  final PlayerPhotoStorage _photoStorage = PlayerPhotoStorage();

  List<PlayerEntity> _allPlayers = [];

  String _searchQuery = '';
  String _selectedPosition = 'Todos';
  bool _isLoading = false;
  String? _errorMessage;

  String get selectedPosition => _selectedPosition;
  List<String> get positions => allPositions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<PlayerEntity> get players {
    return _allPlayers.where((player) {
      final matchesSearch = player.name.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );

      final matchesPosition =
          _selectedPosition == 'Todos' ||
          _normalizePosition(player.position) ==
              _normalizePosition(_selectedPosition);

      return matchesSearch && matchesPosition;
    }).toList();
  }

  int get totalPlayersCount => _allPlayers.length;

  int get nextPlayerId {
    if (_allPlayers.isEmpty) {
      return 1;
    }

    final maxId = _allPlayers
        .map((player) => player.id)
        .reduce((current, next) => current > next ? current : next);

    return maxId + 1;
  }

  Future<void> loadPlayers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allPlayers = await _repository.getPlayers();
    } catch (_) {
      _errorMessage = 'Não foi possível carregar os jogadores.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addPlayer(PlayerEntity player) async {
    try {
      await _repository.addPlayer(player);
      _allPlayers = await _repository.getPlayers();
      _errorMessage = null;
      notifyListeners();
    } catch (_) {
      _errorMessage = 'Não foi possível adicionar o jogador.';
      notifyListeners();
    }
  }

  Future<void> updatePlayer(PlayerEntity updatedPlayer) async {
    final playerIndex = _allPlayers.indexWhere(
      (player) => player.id == updatedPlayer.id,
    );

    if (playerIndex == -1) {
      return;
    }

    try {
      final previousPhotoPath = _allPlayers[playerIndex].photoPath;

      await _repository.updatePlayer(updatedPlayer);

      if (previousPhotoPath != updatedPlayer.photoPath) {
        await _deletePhotoSafely(previousPhotoPath);
      }

      _allPlayers = await _repository.getPlayers();
      _errorMessage = null;
      notifyListeners();
    } catch (_) {
      _errorMessage = 'Não foi possível atualizar o jogador.';
      notifyListeners();
    }
  }

  Future<void> removePlayer(int playerId) async {
    try {
      PlayerEntity? playerToRemove;

      for (final player in _allPlayers) {
        if (player.id == playerId) {
          playerToRemove = player;
          break;
        }
      }

      await _repository.removePlayer(playerId);

      await _deletePhotoSafely(playerToRemove?.photoPath);

      _allPlayers = await _repository.getPlayers();
      _errorMessage = null;
      notifyListeners();
    } catch (_) {
      _errorMessage = 'Não foi possível remover o jogador.';
      notifyListeners();
    }
  }

  void updateSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void selectPosition(String position) {
    _selectedPosition = position;
    notifyListeners();
  }

  String _normalizePosition(String position) {
    return position.trim().toLowerCase().replaceAll('í', 'i');
  }

  Future<void> _deletePhotoSafely(String? photoPath) async {
    try {
      await _photoStorage.deletePhoto(photoPath);
    } catch (_) {
      // Removing stale local files should not invalidate a saved player change.
    }
  }
}
