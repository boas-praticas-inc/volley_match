import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/repositories/scoreboard_repository_impl.dart';
import '../../domain/entities/scoreboard_match_entity.dart';
import '../../domain/repositories/scoreboard_repository.dart';

class ScoreboardViewModel extends ChangeNotifier {
  ScoreboardViewModel({required this.matchId, ScoreboardRepository? repository})
    : _repository = repository ?? ScoreboardRepositoryImpl();

  final int? matchId;
  final ScoreboardRepository _repository;

  ScoreboardMatchEntity? _match;
  int _homeScore = 0;
  int _awayScore = 0;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  Timer? _elapsedTimer;

  ScoreboardMatchEntity? get match => _match;
  int get homeScore => _homeScore;
  int get awayScore => _awayScore;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  bool get hasMatch => _match != null;

  int get currentSetNumber => (_match?.completedSets.length ?? 0) + 1;

  String get formattedElapsedTime {
    final activeMatch = _match;

    if (activeMatch == null) {
      return '00:00';
    }

    final elapsed = DateTime.now().difference(activeMatch.startedAt);
    final hours = elapsed.inHours;
    final minutes = elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:$minutes:$seconds';
    }

    return '$minutes:$seconds';
  }

  int get homeSetsWon {
    final activeMatch = _match;
    if (activeMatch == null) {
      return 0;
    }

    return activeMatch.completedSets
        .where((set) => set.winnerTeamId == activeMatch.homeTeam.id)
        .length;
  }

  int get awaySetsWon {
    final activeMatch = _match;
    if (activeMatch == null) {
      return 0;
    }

    return activeMatch.completedSets
        .where((set) => set.winnerTeamId == activeMatch.awayTeam.id)
        .length;
  }

  int? get matchWinnerTeamId {
    final activeMatch = _match;
    if (activeMatch == null) {
      return null;
    }

    if (homeSetsWon >= activeMatch.setsToWin) {
      return activeMatch.homeTeam.id;
    }

    if (awaySetsWon >= activeMatch.setsToWin) {
      return activeMatch.awayTeam.id;
    }

    return null;
  }

  String? get winnerName {
    final activeMatch = _match;
    final winnerTeamId = matchWinnerTeamId;

    if (activeMatch == null || winnerTeamId == null) {
      return null;
    }

    return winnerTeamId == activeMatch.homeTeam.id
        ? activeMatch.homeTeam.name
        : activeMatch.awayTeam.name;
  }

  bool get canCloseSet {
    final activeMatch = _match;
    if (activeMatch == null || matchWinnerTeamId != null || _isSaving) {
      return false;
    }

    final highestScore = _homeScore > _awayScore ? _homeScore : _awayScore;
    final scoreDifference = (_homeScore - _awayScore).abs();

    return highestScore >= activeMatch.pointsPerSet && scoreDifference >= 2;
  }

  bool get canFinishMatch {
    final activeMatch = _match;
    return activeMatch != null &&
        activeMatch.status != 'finished' &&
        matchWinnerTeamId != null &&
        !_isSaving;
  }

  Future<void> loadMatch() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _match = matchId == null
          ? await _repository.getActiveMatchScoreboard()
          : await _repository.getMatchScoreboard(matchId!);

      if (_match == null) {
        _errorMessage = 'Nenhuma partida em andamento encontrada.';
      } else {
        _startElapsedTimer();
      }
    } catch (_) {
      _errorMessage = 'Nao foi possivel carregar o placar.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void incrementHomeScore() {
    _homeScore += 1;
    notifyListeners();
  }

  void decrementHomeScore() {
    if (_homeScore == 0) {
      return;
    }

    _homeScore -= 1;
    notifyListeners();
  }

  void incrementAwayScore() {
    _awayScore += 1;
    notifyListeners();
  }

  void decrementAwayScore() {
    if (_awayScore == 0) {
      return;
    }

    _awayScore -= 1;
    notifyListeners();
  }

  Future<void> closeCurrentSet() async {
    final activeMatch = _match;

    if (activeMatch == null || !canCloseSet) {
      return;
    }

    _isSaving = true;
    notifyListeners();

    final winnerTeamId = _homeScore > _awayScore
        ? activeMatch.homeTeam.id
        : activeMatch.awayTeam.id;

    try {
      await _repository.saveCompletedSet(
        matchId: activeMatch.matchId,
        setNumber: currentSetNumber,
        homeTeamId: activeMatch.homeTeam.id,
        awayTeamId: activeMatch.awayTeam.id,
        homeScore: _homeScore,
        awayScore: _awayScore,
        winnerTeamId: winnerTeamId,
        isTiebreak: currentSetNumber == activeMatch.bestOfSets,
      );

      _homeScore = 0;
      _awayScore = 0;
      _match = await _repository.getMatchScoreboard(activeMatch.matchId);
    } catch (_) {
      _errorMessage = 'Nao foi possivel salvar o set.';
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> finishMatch() async {
    final activeMatch = _match;
    final winnerTeamId = matchWinnerTeamId;

    if (activeMatch == null || winnerTeamId == null || !canFinishMatch) {
      return;
    }

    _isSaving = true;
    notifyListeners();

    try {
      await _repository.finishMatch(
        matchId: activeMatch.matchId,
        winnerTeamId: winnerTeamId,
      );
      _match = await _repository.getMatchScoreboard(activeMatch.matchId);
      _elapsedTimer?.cancel();
    } catch (_) {
      _errorMessage = 'Nao foi possivel encerrar a partida.';
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void _startElapsedTimer() {
    _elapsedTimer?.cancel();
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _elapsedTimer?.cancel();
    super.dispose();
  }
}
