import 'package:flutter/foundation.dart';

import '../../domain/entities/player_entity.dart';

class PlayersViewModel extends ChangeNotifier {
  static const allPositions = [
    'Todos',
    'Ponteiro',
    'Levantador',
    'Central',
    'Oposto',
    'Libero',
  ];

  final List<PlayerEntity> _allPlayers = [
    PlayerEntity(
      id: 1,
      name: 'Matheus',
      skillRating: 8,
      position: 'Levantador',
    ),
    PlayerEntity(
      id: 2,
      name: 'Bruno',
      skillRating: 7,
      position: 'Ponteiro',
    ),
    PlayerEntity(
      id: 3,
      name: 'Caio',
      skillRating: 9,
      position: 'Central',
    ),
    PlayerEntity(
      id: 4,
      name: 'Rafael',
      skillRating: 6,
      position: 'Libero',
    ),
  ];

  String _searchQuery = '';
  String _selectedPosition = 'Todos';

  String get selectedPosition => _selectedPosition;
  List<String> get positions => allPositions;

  List<PlayerEntity> get players {
    return _allPlayers.where((player) {
      final matchesSearch = player.name.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );

      final matchesPosition =
          _selectedPosition == 'Todos' || player.position == _selectedPosition;

      return matchesSearch && matchesPosition;
    }).toList();
  }

  int get totalPlayersCount => _allPlayers.length;
  int get nextPlayerId => _allPlayers.length + 1;

  void addPlayer(PlayerEntity player) {
    _allPlayers.add(player);
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
}
