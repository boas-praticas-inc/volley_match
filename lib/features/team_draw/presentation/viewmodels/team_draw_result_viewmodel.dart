import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../../players/domain/entities/player_entity.dart';
import '../../data/repositories/team_draw_repository_impl.dart';
import '../../domain/entities/drawn_team_entity.dart';
import '../../domain/repositories/team_draw_repository.dart';
import '../../domain/usecases/generate_balanced_teams_usecase.dart';
import '../../domain/usecases/save_draw_teams_usecase.dart';

class TeamDrawResultViewModel extends ChangeNotifier {
  TeamDrawResultViewModel({
    required List<PlayerEntity> players,
    required int teamsCount,
    required int playersPerTeam,
    GenerateBalancedTeamsUseCase? generateBalancedTeamsUseCase,
    TeamDrawRepository? teamDrawRepository,
    Random? random,
  }) : _generateBalancedTeamsUseCase =
           generateBalancedTeamsUseCase ?? GenerateBalancedTeamsUseCase(),
       _teamDrawRepository = teamDrawRepository ?? TeamDrawRepositoryImpl(),
       _random = random ?? Random() {
    _players = players;
    _teamsCount = teamsCount;
    _playersPerTeam = playersPerTeam;
    _saveDrawTeamsUseCase = SaveDrawTeamsUseCase(_teamDrawRepository);
  }

  late final List<PlayerEntity> _players;
  late final int _teamsCount;
  late final int _playersPerTeam;
  final GenerateBalancedTeamsUseCase _generateBalancedTeamsUseCase;
  final TeamDrawRepository _teamDrawRepository;
  final Random _random;
  late final SaveDrawTeamsUseCase _saveDrawTeamsUseCase;

  List<DrawnTeamEntity> _drawnTeams = [];
  int? _eventId;
  bool _isPersisting = false;
  String _searchQuery = '';
  String? _errorMessage;
  bool _isInitialized = false;
  bool _isDisposed = false;

  List<DrawnTeamEntity> get drawnTeams => List.unmodifiable(_drawnTeams);
  int? get eventId => _eventId;
  bool get isPersisting => !_isInitialized || _isPersisting;
  String? get errorMessage => _errorMessage;

  bool get canStartMatch {
    return !_isPersisting &&
        _eventId != null &&
        _drawnTeams.every((team) => team.id != null);
  }

  List<TeamDrawResultItem> get filteredTeams {
    final allTeams = List.generate(
      _drawnTeams.length,
      (index) => TeamDrawResultItem(
        index: index,
        title: _drawnTeams[index].name,
        players: _drawnTeams[index].players,
      ),
    );

    final normalizedQuery = _searchQuery.trim().toLowerCase();

    if (normalizedQuery.isEmpty) {
      return allTeams;
    }

    return allTeams
        .where((team) => team.title.toLowerCase().contains(normalizedQuery))
        .toList();
  }

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    _isInitialized = true;
    _drawnTeams = _buildDrawnTeams();
    _notifyListeners();

    await persistCurrentDraw();
  }

  void updateSearchQuery(String value) {
    _searchQuery = value;
    _notifyListeners();
  }

  Future<void> regenerateDraw() async {
    final preservedNames = _drawnTeams.map((team) => team.name).toList();
    _drawnTeams = _buildDrawnTeams(preservedNames: preservedNames);
    _notifyListeners();

    await persistCurrentDraw();
  }

  Future<void> updateTeamName({
    required int teamIndex,
    required String name,
  }) async {
    final updatedName = name.trim();

    if (updatedName.isEmpty ||
        teamIndex < 0 ||
        teamIndex >= _drawnTeams.length) {
      return;
    }

    final team = _drawnTeams[teamIndex];
    _drawnTeams[teamIndex] = team.copyWith(name: updatedName);
    _notifyListeners();

    if (team.id == null) {
      await persistCurrentDraw();
      return;
    }

    try {
      await _teamDrawRepository.updateTeamName(
        teamId: team.id!,
        name: updatedName,
      );
      _errorMessage = null;
    } catch (_) {
      _errorMessage = 'Não foi possível salvar o nome do time.';
    } finally {
      _notifyListeners();
    }
  }

  Future<void> ensureCurrentDrawPersisted() async {
    if (canStartMatch) {
      return;
    }

    await persistCurrentDraw();
  }

  Future<void> persistCurrentDraw() async {
    if (_isPersisting) {
      return;
    }

    _isPersisting = true;
    _errorMessage = null;
    _notifyListeners();

    try {
      final result = await _saveDrawTeamsUseCase(
        teams: _drawnTeams,
        eventId: _eventId,
      );

      _eventId = result.eventId;
      _drawnTeams = result.teams;
    } catch (_) {
      _errorMessage = 'Não foi possível salvar o sorteio.';
    } finally {
      _isPersisting = false;
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

  List<DrawnTeamEntity> _buildDrawnTeams({List<String>? preservedNames}) {
    final generatedTeams = _generateBalancedTeamsUseCase(
      players: _players,
      teamsCount: _teamsCount,
      playersPerTeam: _playersPerTeam,
      random: _random,
    );

    return List.generate(generatedTeams.length, (index) {
      final name = preservedNames != null && index < preservedNames.length
          ? preservedNames[index]
          : 'Time ${String.fromCharCode(65 + index)}';

      return DrawnTeamEntity(name: name, players: generatedTeams[index]);
    });
  }
}

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
