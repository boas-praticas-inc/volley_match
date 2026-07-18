import '../entities/scoreboard_match_entity.dart';
import '../entities/live_score_entity.dart';

abstract class ScoreboardRepository {
  Future<ScoreboardMatchEntity?> getMatchScoreboard(int matchId);

  Future<ScoreboardMatchEntity?> getActiveMatchScoreboard();

  Future<LiveScoreEntity?> getLiveScore({
    required int matchId,
    required int setNumber,
  });

  Future<void> saveLiveScore(LiveScoreEntity liveScore);

  Future<void> clearLiveScore(int matchId);

  Future<void> saveCompletedSet({
    required int matchId,
    required int setNumber,
    required int homeTeamId,
    required int awayTeamId,
    required int homeScore,
    required int awayScore,
    required int winnerTeamId,
    required bool isTiebreak,
  });

  Future<void> finishMatch({required int matchId, required int winnerTeamId});
}
