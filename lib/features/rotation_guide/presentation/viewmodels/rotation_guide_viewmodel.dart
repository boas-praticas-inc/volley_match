import 'package:flutter/foundation.dart';

import '../../../scoreboard/data/repositories/scoreboard_repository_impl.dart';
import '../../../scoreboard/domain/entities/live_score_entity.dart';
import '../../../scoreboard/domain/entities/scoreboard_match_entity.dart';
import '../../../scoreboard/domain/repositories/scoreboard_repository.dart';
import '../../domain/entities/rotation_system_entity.dart';
import '../../domain/services/rotation_calculator.dart';

class RotationGuideViewModel extends ChangeNotifier {
  RotationGuideViewModel({
    ScoreboardRepository? scoreboardRepository,
    RotationCalculator? rotationCalculator,
  }) : _scoreboardRepository =
           scoreboardRepository ?? ScoreboardRepositoryImpl(),
       _rotationCalculator = rotationCalculator ?? RotationCalculator();

  final ScoreboardRepository _scoreboardRepository;
  final RotationCalculator _rotationCalculator;

  ScoreboardMatchEntity? _match;
  LiveScoreEntity? _liveScore;
  RotationCourtStateEntity? _courtState;
  bool _isLoading = false;
  bool _isSavingScore = false;
  String? _errorMessage;

  ScoreboardMatchEntity? get match => _match;
  LiveScoreEntity? get liveScore => _liveScore;
  RotationCourtStateEntity? get courtState => _courtState;
  bool get isLoading => _isLoading;
  bool get isSavingScore => _isSavingScore;
  String? get errorMessage => _errorMessage;
  bool get hasMatch => _match != null;
  bool get isRotationAvailable => hasMatch && _hasSixPlayersPerTeam;
  bool get canEditScore =>
      isRotationAvailable && _match?.status == 'in_progress' && !_isSavingScore;

  int get currentSetNumber => (_match?.completedSets.length ?? 0) + 1;

  bool get _hasSixPlayersPerTeam {
    final activeMatch = _match;

    if (activeMatch == null) {
      return false;
    }

    return activeMatch.homeTeam.players.length == 6 &&
        activeMatch.awayTeam.players.length == 6;
  }

  Future<void> load({int? matchId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _match = matchId == null
          ? await _scoreboardRepository.getActiveMatchScoreboard()
          : await _scoreboardRepository.getMatchScoreboard(matchId);

      final activeMatch = _match;

      if (activeMatch == null) {
        _liveScore = null;
        _courtState = null;
        _errorMessage = 'Nenhuma partida em andamento encontrada.';
        return;
      }

      if (!_hasSixPlayersPerTeam) {
        _liveScore = null;
        _courtState = null;
        _errorMessage =
            'Modo rotação disponível somente para partidas com 6 jogadores em cada time.';
        return;
      }

      _liveScore = await _scoreboardRepository.getLiveScore(
        matchId: activeMatch.matchId,
        setNumber: currentSetNumber,
      );
      _rebuildCourtState();
    } catch (_) {
      _errorMessage = 'Não foi possível carregar as rotações.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    final activeMatch = _match;
    await load(matchId: activeMatch?.matchId);
  }

  Future<void> incrementHomeScore() {
    return _changeScore(isHomeTeam: true, delta: 1);
  }

  Future<void> decrementHomeScore() {
    return _changeScore(isHomeTeam: true, delta: -1);
  }

  Future<void> incrementAwayScore() {
    return _changeScore(isHomeTeam: false, delta: 1);
  }

  Future<void> decrementAwayScore() {
    return _changeScore(isHomeTeam: false, delta: -1);
  }

  Future<void> _changeScore({
    required bool isHomeTeam,
    required int delta,
  }) async {
    final activeMatch = _match;

    if (activeMatch == null || !canEditScore) {
      return;
    }

    final currentLiveScore = _effectiveLiveScore(activeMatch);
    final scoringTeamId = isHomeTeam
        ? activeMatch.homeTeam.id
        : activeMatch.awayTeam.id;
    var homeScore = currentLiveScore.homeScore;
    var awayScore = currentLiveScore.awayScore;
    final pointScoringTeamIds = [...currentLiveScore.pointScoringTeamIds];

    if (delta > 0) {
      if (isHomeTeam) {
        homeScore += 1;
      } else {
        awayScore += 1;
      }

      pointScoringTeamIds.add(scoringTeamId);
    } else {
      if (isHomeTeam && homeScore == 0) {
        return;
      }

      if (!isHomeTeam && awayScore == 0) {
        return;
      }

      if (isHomeTeam) {
        homeScore -= 1;
      } else {
        awayScore -= 1;
      }

      _removeLastPointForTeam(pointScoringTeamIds, scoringTeamId);
    }

    final updatedLiveScore = LiveScoreEntity(
      matchId: activeMatch.matchId,
      setNumber: currentSetNumber,
      homeScore: homeScore,
      awayScore: awayScore,
      pointScoringTeamIds: List<int>.unmodifiable(pointScoringTeamIds),
    );

    _liveScore = updatedLiveScore;
    _rebuildCourtState();
    _isSavingScore = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _scoreboardRepository.saveLiveScore(updatedLiveScore);
    } catch (_) {
      _errorMessage = 'Não foi possível salvar o placar parcial.';
      await refresh();
    } finally {
      _isSavingScore = false;
      notifyListeners();
    }
  }

  LiveScoreEntity _effectiveLiveScore(ScoreboardMatchEntity activeMatch) {
    final liveScore = _liveScore;

    if (liveScore == null) {
      return LiveScoreEntity(
        matchId: activeMatch.matchId,
        setNumber: currentSetNumber,
        homeScore: 0,
        awayScore: 0,
      );
    }

    final expectedEventsCount = liveScore.homeScore + liveScore.awayScore;

    if (liveScore.pointScoringTeamIds.length == expectedEventsCount) {
      return liveScore;
    }

    return LiveScoreEntity(
      matchId: liveScore.matchId,
      setNumber: liveScore.setNumber,
      homeScore: liveScore.homeScore,
      awayScore: liveScore.awayScore,
      pointScoringTeamIds: _syntheticPointScoringTeamIds(
        activeMatch: activeMatch,
        homeScore: liveScore.homeScore,
        awayScore: liveScore.awayScore,
      ),
    );
  }

  void _removeLastPointForTeam(List<int> pointScoringTeamIds, int teamId) {
    for (var index = pointScoringTeamIds.length - 1; index >= 0; index--) {
      if (pointScoringTeamIds[index] == teamId) {
        pointScoringTeamIds.removeAt(index);
        return;
      }
    }
  }

  List<int> _syntheticPointScoringTeamIds({
    required ScoreboardMatchEntity activeMatch,
    required int homeScore,
    required int awayScore,
  }) {
    final events = <int>[];
    var remainingHomeScore = homeScore;
    var remainingAwayScore = awayScore;
    var nextTeamId = currentSetNumber.isOdd
        ? activeMatch.awayTeam.id
        : activeMatch.homeTeam.id;

    while (remainingHomeScore > 0 || remainingAwayScore > 0) {
      if (nextTeamId == activeMatch.homeTeam.id && remainingHomeScore > 0) {
        events.add(activeMatch.homeTeam.id);
        remainingHomeScore -= 1;
      } else if (nextTeamId == activeMatch.awayTeam.id &&
          remainingAwayScore > 0) {
        events.add(activeMatch.awayTeam.id);
        remainingAwayScore -= 1;
      } else if (remainingHomeScore >= remainingAwayScore &&
          remainingHomeScore > 0) {
        events.add(activeMatch.homeTeam.id);
        remainingHomeScore -= 1;
      } else {
        events.add(activeMatch.awayTeam.id);
        remainingAwayScore -= 1;
      }

      nextTeamId = nextTeamId == activeMatch.homeTeam.id
          ? activeMatch.awayTeam.id
          : activeMatch.homeTeam.id;
    }

    return events;
  }

  void _rebuildCourtState() {
    final activeMatch = _match;

    if (activeMatch == null) {
      _courtState = null;
      return;
    }

    _courtState = _rotationCalculator.build(
      match: activeMatch,
      system: RotationSystem.sixZero,
      liveScore: _liveScore,
      currentSetNumber: currentSetNumber,
    );
  }
}
