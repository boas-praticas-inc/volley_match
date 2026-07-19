import 'package:flutter/foundation.dart';

import '../../../players/data/repositories/players_repository_impl.dart';
import '../../../players/domain/entities/player_entity.dart';
import '../../../players/domain/repositories/players_repository.dart';

class TeamDrawViewModel extends ChangeNotifier {
  TeamDrawViewModel({PlayersRepository? repository})
    : _repository = repository ?? PlayersRepositoryImpl();

  static const int minimumPlayersPerTeam = 2;
  static const int maximumPlayersPerTeam = 6;
  static const int minimumSelectedPlayers = minimumPlayersPerTeam * 2;
  static const allPositions = [
    'Todos',
    'Ponteiro',
    'Levantador',
    'Central',
    'Oposto',
    'Líbero',
  ];

  final PlayersRepository _repository;

  List<PlayerEntity> _allPlayers = [];
  final Set<int> _selectedPlayerIds = {};
  String _searchQuery = '';
  String _selectedPosition = 'Todos';
  bool _isLoading = false;
  String? _errorMessage;

  String get selectedPosition => _selectedPosition;
  List<String> get positions => allPositions;
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

  List<PlayerEntity> get selectedPlayers {
    return _allPlayers
        .where((player) => _selectedPlayerIds.contains(player.id))
        .toList();
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get totalPlayersCount => _allPlayers.length;
  int get selectedPlayersCount => _selectedPlayerIds.length;
  bool get hasMinimumPlayersSelected =>
      selectedPlayersCount >= minimumSelectedPlayers;
  bool get hasPlayersPerTeamOption => playersPerTeamOptions.isNotEmpty;
  bool get isSelectionValid =>
      hasMinimumPlayersSelected && hasPlayersPerTeamOption;
  bool get canDrawTeams => isSelectionValid;
  String? get selectionValidationMessage {
    if (selectedPlayersCount == 0) {
      return 'Selecione jogadores presentes para continuar.';
    }

    if (!hasMinimumPlayersSelected) {
      return 'Selecione pelo menos 4 jogadores para formar 2 times.';
    }

    if (!hasPlayersPerTeamOption) {
      return 'Não há configuração possível entre 2 e 6 jogadores por time.';
    }

    return null;
  }

  List<int> get playersPerTeamOptions {
    if (!hasMinimumPlayersSelected) {
      return [];
    }

    return List<int>.generate(
      maximumPlayersPerTeam - minimumPlayersPerTeam + 1,
      (index) => index + minimumPlayersPerTeam,
    ).where((teamSize) {
      final teamsCount = selectedPlayersCount ~/ teamSize;

      return teamSize <= maximumPlayersPerTeam &&
          selectedPlayersCount % teamSize == 0 &&
          teamsCount >= 2;
    }).toList();
  }

  Future<void> loadPlayers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allPlayers = await _repository.getPlayers();
      _selectedPlayerIds.clear();
    } catch (_) {
      _errorMessage = 'Não foi possível carregar os jogadores.';
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
}
