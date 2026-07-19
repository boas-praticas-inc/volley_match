import 'package:flutter/foundation.dart';

import '../../../team_draw/domain/entities/drawn_team_entity.dart';
import '../../data/repositories/event_repository_impl.dart';
import '../../domain/entities/event_match_configuration_entity.dart';
import '../../domain/repositories/event_repository.dart';

class EventConfigurationViewModel extends ChangeNotifier {
  EventConfigurationViewModel({
    required this.eventId,
    required List<DrawnTeamEntity> teams,
    EventRepository? repository,
  }) : teams = List.unmodifiable(teams),
       _repository = repository ?? EventRepositoryImpl() {
    _selectedTeamIds.addAll(
      teams.where((team) => team.id != null).take(2).map((team) => team.id!),
    );
  }

  static const bestOfSetsOptions = [1, 3, 5];
  static const pointsPerSetOptions = [15, 21, 25];

  final int eventId;
  final List<DrawnTeamEntity> teams;
  final EventRepository _repository;

  final List<int> _selectedTeamIds = [];
  int _selectedBestOfSets = 3;
  int _selectedPointsPerSet = 25;
  bool _isStarting = false;
  String? _errorMessage;
  bool _isDisposed = false;

  int get selectedBestOfSets => _selectedBestOfSets;
  int get selectedPointsPerSet => _selectedPointsPerSet;
  int get selectedTeamsCount => _selectedTeamIds.length;
  bool get isStarting => _isStarting;
  String? get errorMessage => _errorMessage;

  int get setsToWin => (_selectedBestOfSets ~/ 2) + 1;

  bool get canStartEvent {
    return _selectedTeamIds.length == 2 && !_isStarting;
  }

  String get eventRuleMessage {
    if (teams.length == 2) {
      return 'Com 2 times, eles permanecem jogando durante o evento.';
    }

    return 'Vencedor permanece em quadra, perdedor sai e o próximo time entra.';
  }

  bool isTeamSelected(DrawnTeamEntity team) {
    final teamId = team.id;
    return teamId != null && _selectedTeamIds.contains(teamId);
  }

  int? selectedOrderForTeam(DrawnTeamEntity team) {
    final teamId = team.id;

    if (teamId == null) {
      return null;
    }

    final index = _selectedTeamIds.indexOf(teamId);

    if (index == -1) {
      return null;
    }

    return index + 1;
  }

  void toggleStartingTeam(DrawnTeamEntity team) {
    final teamId = team.id;

    if (teamId == null || _isStarting) {
      return;
    }

    if (_selectedTeamIds.contains(teamId)) {
      _selectedTeamIds.remove(teamId);
      _notifyListeners();
      return;
    }

    if (_selectedTeamIds.length == 2) {
      _selectedTeamIds.removeAt(0);
    }

    _selectedTeamIds.add(teamId);
    _notifyListeners();
  }

  void selectBestOfSets(int bestOfSets) {
    if (!bestOfSetsOptions.contains(bestOfSets)) {
      return;
    }

    _selectedBestOfSets = bestOfSets;
    _notifyListeners();
  }

  void selectPointsPerSet(int pointsPerSet) {
    if (!pointsPerSetOptions.contains(pointsPerSet)) {
      return;
    }

    _selectedPointsPerSet = pointsPerSet;
    _notifyListeners();
  }

  Future<int?> startEvent() async {
    if (!canStartEvent) {
      return null;
    }

    _isStarting = true;
    _errorMessage = null;
    _notifyListeners();

    try {
      return await _repository.startEventMatch(
        EventMatchConfigurationEntity(
          eventId: eventId,
          homeTeamId: _selectedTeamIds[0],
          awayTeamId: _selectedTeamIds[1],
          bestOfSets: _selectedBestOfSets,
          setsToWin: setsToWin,
          pointsPerSet: _selectedPointsPerSet,
        ),
      );
    } catch (_) {
      _errorMessage = 'Não foi possível iniciar o evento.';
      return null;
    } finally {
      _isStarting = false;
      _notifyListeners();
    }
  }

  void clearErrorMessage() {
    if (_errorMessage == null) {
      return;
    }

    _errorMessage = null;
    _notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _notifyListeners() {
    if (_isDisposed) {
      return;
    }

    notifyListeners();
  }
}
