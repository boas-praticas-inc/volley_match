import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/repositories/scoreboard_repository_impl.dart';
import '../../domain/entities/live_score_entity.dart';
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
  Future<void> _liveScoreSaveQueue = Future.value();
  bool _isPaused = false;
  DateTime? _pausedAt;
  Duration _totalPausedDuration = Duration.zero;

  ScoreboardMatchEntity? get match => _match;
  int get homeScore => _homeScore;
  int get awayScore => _awayScore;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get isPaused => _isPaused;
  String? get errorMessage => _errorMessage;
  bool get hasMatch => _match != null;

  int get currentSetNumber => (_match?.completedSets.length ?? 0) + 1;

  String get formattedElapsedTime {
    final activeMatch = _match;

    if (activeMatch == null) {
      return '00:00';
    }

    final elapsed = _currentElapsedDuration(activeMatch);
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
    if (activeMatch == null ||
        matchWinnerTeamId != null ||
        _isSaving ||
        _isPaused) {
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
        !_isSaving &&
        !_isPaused;
  }

  bool get canTogglePause {
    final activeMatch = _match;
    return activeMatch != null &&
        activeMatch.status != 'finished' &&
        !_isSaving &&
        matchWinnerTeamId == null;
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
        await _restoreLiveScore();
        _resetPauseState();
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
    if (_isSaving || _isPaused || matchWinnerTeamId != null) {
      return;
    }

    _homeScore += 1;
    _enqueueLiveScoreSave();
    notifyListeners();
  }

  void decrementHomeScore() {
    if (_homeScore == 0 ||
        _isSaving ||
        _isPaused ||
        matchWinnerTeamId != null) {
      return;
    }

    _homeScore -= 1;
    _enqueueLiveScoreSave();
    notifyListeners();
  }

  void incrementAwayScore() {
    if (_isSaving || _isPaused || matchWinnerTeamId != null) {
      return;
    }

    _awayScore += 1;
    _enqueueLiveScoreSave();
    notifyListeners();
  }

  void decrementAwayScore() {
    if (_awayScore == 0 ||
        _isSaving ||
        _isPaused ||
        matchWinnerTeamId != null) {
      return;
    }

    _awayScore -= 1;
    _enqueueLiveScoreSave();
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

      await _liveScoreSaveQueue;
      await _repository.clearLiveScore(activeMatch.matchId);
      _homeScore = 0;
      _awayScore = 0;
      _match = await _repository.getMatchScoreboard(activeMatch.matchId);
      _resetPauseState();
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
      final nextMatch = await _repository.finishMatch(
        matchId: activeMatch.matchId,
        winnerTeamId: winnerTeamId,
      );
      await _liveScoreSaveQueue;
      await _repository.clearLiveScore(activeMatch.matchId);
      _homeScore = 0;
      _awayScore = 0;
      _resetPauseState();
      _match =
          nextMatch ??
          await _repository.getMatchScoreboard(activeMatch.matchId);

      if (_match?.status == 'in_progress') {
        _startElapsedTimer();
      } else {
        _elapsedTimer?.cancel();
      }
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

  void togglePause() {
    if (!canTogglePause) {
      return;
    }

    if (_isPaused) {
      final pausedAt = _pausedAt;

      if (pausedAt != null) {
        _totalPausedDuration += DateTime.now().difference(pausedAt);
      }

      _isPaused = false;
      _pausedAt = null;
      _startElapsedTimer();
    } else {
      _isPaused = true;
      _pausedAt = DateTime.now();
      _elapsedTimer?.cancel();
    }

    notifyListeners();
  }

  Future<void> _restoreLiveScore() async {
    final activeMatch = _match;

    if (activeMatch == null) {
      return;
    }

    final liveScore = await _repository.getLiveScore(
      matchId: activeMatch.matchId,
      setNumber: currentSetNumber,
    );

    if (liveScore == null) {
      return;
    }

    _homeScore = liveScore.homeScore;
    _awayScore = liveScore.awayScore;
  }

  Future<void> _saveLiveScore() async {
    final activeMatch = _match;

    if (activeMatch == null) {
      return;
    }

    try {
      await _repository.saveLiveScore(
        LiveScoreEntity(
          matchId: activeMatch.matchId,
          setNumber: currentSetNumber,
          homeScore: _homeScore,
          awayScore: _awayScore,
        ),
      );
    } catch (_) {
      _errorMessage = 'Nao foi possivel salvar o placar parcial.';
    }
  }

  void _enqueueLiveScoreSave() {
    _liveScoreSaveQueue = _liveScoreSaveQueue.then((_) => _saveLiveScore());
    unawaited(_liveScoreSaveQueue);
  }

  Duration _currentElapsedDuration(ScoreboardMatchEntity activeMatch) {
    final now = _isPaused && _pausedAt != null ? _pausedAt! : DateTime.now();
    final elapsed =
        now.difference(activeMatch.startedAt) - _totalPausedDuration;

    if (elapsed.isNegative) {
      return Duration.zero;
    }

    return elapsed;
  }

  void _resetPauseState() {
    _isPaused = false;
    _pausedAt = null;
    _totalPausedDuration = Duration.zero;
  }

  @override
  void dispose() {
    _elapsedTimer?.cancel();
    super.dispose();
  }
}
