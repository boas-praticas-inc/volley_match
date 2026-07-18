import '../../domain/entities/scoreboard_match_entity.dart';
import '../../domain/repositories/scoreboard_repository.dart';
import '../datasources/scoreboard_local_data_source.dart';

class ScoreboardRepositoryImpl implements ScoreboardRepository {
  ScoreboardRepositoryImpl({ScoreboardLocalDataSource? localDataSource})
    : _localDataSource = localDataSource ?? ScoreboardLocalDataSource();

  final ScoreboardLocalDataSource _localDataSource;

  @override
  Future<ScoreboardMatchEntity?> getMatchScoreboard(int matchId) {
    return _localDataSource.getMatchScoreboard(matchId);
  }

  @override
  Future<ScoreboardMatchEntity?> getActiveMatchScoreboard() {
    return _localDataSource.getActiveMatchScoreboard();
  }

  @override
  Future<void> saveCompletedSet({
    required int matchId,
    required int setNumber,
    required int homeTeamId,
    required int awayTeamId,
    required int homeScore,
    required int awayScore,
    required int winnerTeamId,
    required bool isTiebreak,
  }) {
    return _localDataSource.saveCompletedSet(
      matchId: matchId,
      setNumber: setNumber,
      homeTeamId: homeTeamId,
      awayTeamId: awayTeamId,
      homeScore: homeScore,
      awayScore: awayScore,
      winnerTeamId: winnerTeamId,
      isTiebreak: isTiebreak,
    );
  }

  @override
  Future<void> finishMatch({required int matchId, required int winnerTeamId}) {
    return _localDataSource.finishMatch(
      matchId: matchId,
      winnerTeamId: winnerTeamId,
    );
  }
}
