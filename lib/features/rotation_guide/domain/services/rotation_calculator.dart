import '../../../scoreboard/domain/entities/live_score_entity.dart';
import '../../../scoreboard/domain/entities/scoreboard_match_entity.dart';
import '../../../scoreboard/domain/services/point_event_normalizer.dart';
import '../entities/rotation_system_entity.dart';

class RotationCalculator {
  RotationCalculator({PointEventNormalizer? pointEventNormalizer})
    : _pointEventNormalizer =
          pointEventNormalizer ?? const PointEventNormalizer();

  static const List<int> _sixZeroRotationPath = [2, 6, 5, 1, 4];

  final PointEventNormalizer _pointEventNormalizer;

  RotationCourtStateEntity build({
    required ScoreboardMatchEntity match,
    required RotationSystem system,
    required LiveScoreEntity? liveScore,
    required int currentSetNumber,
  }) {
    final normalizedEvents = _pointEventNormalizer
        .normalizedPointScoringTeamIds(
          match: match,
          currentSetNumber: currentSetNumber,
          liveScore: liveScore,
        );
    final rotationCount = _rotationCountFromEvents(
      match: match,
      currentSetNumber: currentSetNumber,
      pointScoringTeamIds: normalizedEvents,
    );

    return RotationCourtStateEntity(
      matchTitle: '${match.homeTeam.name} x ${match.awayTeam.name}',
      currentSetNumber: currentSetNumber,
      system: system,
      homeScore: liveScore?.homeScore ?? 0,
      awayScore: liveScore?.awayScore ?? 0,
      homeTeam: _buildTeamState(
        team: match.homeTeam,
        rotationTurns: rotationCount.homeRotationTurns,
        isServing: rotationCount.servingTeamId == match.homeTeam.id,
      ),
      awayTeam: _buildTeamState(
        team: match.awayTeam,
        rotationTurns: rotationCount.awayRotationTurns,
        isServing: rotationCount.servingTeamId == match.awayTeam.id,
      ),
    );
  }

  _RotationCount _rotationCountFromEvents({
    required ScoreboardMatchEntity match,
    required int currentSetNumber,
    required List<int> pointScoringTeamIds,
  }) {
    var servingTeamId = _pointEventNormalizer.initialServingTeamId(
      match: match,
      currentSetNumber: currentSetNumber,
    );
    var homeRotationTurns = 0;
    var awayRotationTurns = 0;

    for (final scoringTeamId in pointScoringTeamIds) {
      final isKnownTeam =
          scoringTeamId == match.homeTeam.id ||
          scoringTeamId == match.awayTeam.id;

      if (!isKnownTeam || scoringTeamId == servingTeamId) {
        continue;
      }

      servingTeamId = scoringTeamId;

      if (scoringTeamId == match.homeTeam.id) {
        homeRotationTurns += 1;
      } else {
        awayRotationTurns += 1;
      }
    }

    return _RotationCount(
      servingTeamId: servingTeamId,
      homeRotationTurns: homeRotationTurns,
      awayRotationTurns: awayRotationTurns,
    );
  }

  RotationTeamStateEntity _buildTeamState({
    required ScoreboardTeamEntity team,
    required int rotationTurns,
    required bool isServing,
  }) {
    final initialLineup = _initialLineup(team.players);
    final currentPositions = <int, RotationCourtPlayerEntity?>{};

    for (final entry in initialLineup.entries) {
      final player = entry.value;

      if (player == null) {
        continue;
      }

      final zone = player.isSetter
          ? 3
          : _rotatedZone(initialZone: entry.key, rotationTurns: rotationTurns);

      currentPositions[zone] = player;
    }

    return RotationTeamStateEntity(
      id: team.id,
      name: team.name,
      isServing: isServing,
      rotationTurns: rotationTurns,
      positions: List.generate(6, (index) {
        final zone = index + 1;

        return RotationCourtPositionEntity(
          zone: zone,
          player: currentPositions[zone],
        );
      }),
    );
  }

  int _rotatedZone({required int initialZone, required int rotationTurns}) {
    final initialIndex = _sixZeroRotationPath.indexOf(initialZone);

    if (initialIndex == -1) {
      return initialZone;
    }

    return _sixZeroRotationPath[(initialIndex + rotationTurns) %
        _sixZeroRotationPath.length];
  }

  Map<int, RotationCourtPlayerEntity?> _initialLineup(
    List<ScoreboardPlayerEntity> players,
  ) {
    final available = _orderedPlayers(
      players,
    ).map(_courtPlayerFromScoreboardPlayer).toList();

    return _sixZeroInitialLineup(available);
  }

  Map<int, RotationCourtPlayerEntity?> _sixZeroInitialLineup(
    List<RotationCourtPlayerEntity> available,
  ) {
    final setter =
        _takeByPosition(available, const ['Levantador']) ??
        _takeAny(available)?.copyWith(role: 'Levantador', isSetter: true);
    final lineup = <int, RotationCourtPlayerEntity?>{
      1: _takeByPosition(available, const ['Ponteiro']),
      2: _takeByPosition(available, const ['Central']),
      3: setter,
      4: _takeByPosition(available, const ['Oposto', 'Ponteiro']),
      5: _takeByPosition(available, const ['Ponteiro', 'Líbero']),
      6: _takeByPosition(available, const ['Líbero', 'Central']),
    };

    return _fillOpenZones(lineup, available);
  }

  Map<int, RotationCourtPlayerEntity?> _fillOpenZones(
    Map<int, RotationCourtPlayerEntity?> lineup,
    List<RotationCourtPlayerEntity> available,
  ) {
    for (final zone in const [1, 2, 3, 4, 5, 6]) {
      lineup[zone] ??= _takeAny(available);
    }

    return lineup;
  }

  List<ScoreboardPlayerEntity> _orderedPlayers(
    List<ScoreboardPlayerEntity> players,
  ) {
    final orderedPlayers = [...players];

    orderedPlayers.sort((left, right) {
      final leftRotationOrder = left.rotationOrder;
      final rightRotationOrder = right.rotationOrder;

      if (leftRotationOrder != null && rightRotationOrder == null) {
        return -1;
      }

      if (leftRotationOrder == null && rightRotationOrder != null) {
        return 1;
      }

      final rotationComparison = (leftRotationOrder ?? 0).compareTo(
        rightRotationOrder ?? 0,
      );

      if (rotationComparison != 0) {
        return rotationComparison;
      }

      return left.name.toLowerCase().compareTo(right.name.toLowerCase());
    });

    return orderedPlayers.take(6).toList();
  }

  RotationCourtPlayerEntity _courtPlayerFromScoreboardPlayer(
    ScoreboardPlayerEntity player,
  ) {
    final isSetter = _matchesPosition(player.position, 'Levantador');

    return RotationCourtPlayerEntity(
      id: player.id,
      name: player.name,
      role: player.position,
      isSetter: isSetter,
      photoPath: player.photoPath,
    );
  }

  RotationCourtPlayerEntity? _takeByPosition(
    List<RotationCourtPlayerEntity> available,
    List<String> positionPriority,
  ) {
    for (final position in positionPriority) {
      final index = available.indexWhere(
        (player) => _matchesPosition(player.role, position),
      );

      if (index != -1) {
        return available.removeAt(index);
      }
    }

    return null;
  }

  RotationCourtPlayerEntity? _takeAny(
    List<RotationCourtPlayerEntity> available,
  ) {
    if (available.isEmpty) {
      return null;
    }

    return available.removeAt(0);
  }

  bool _matchesPosition(String value, String expected) {
    return _normalizePosition(value) == _normalizePosition(expected);
  }

  String _normalizePosition(String position) {
    return position.trim().toLowerCase().replaceAll('í', 'i');
  }
}

class RotationCourtStateEntity {
  const RotationCourtStateEntity({
    required this.matchTitle,
    required this.currentSetNumber,
    required this.system,
    required this.homeScore,
    required this.awayScore,
    required this.homeTeam,
    required this.awayTeam,
  });

  final String matchTitle;
  final int currentSetNumber;
  final RotationSystem system;
  final int homeScore;
  final int awayScore;
  final RotationTeamStateEntity homeTeam;
  final RotationTeamStateEntity awayTeam;
}

class RotationTeamStateEntity {
  const RotationTeamStateEntity({
    required this.id,
    required this.name,
    required this.isServing,
    required this.rotationTurns,
    required this.positions,
  });

  final int id;
  final String name;
  final bool isServing;
  final int rotationTurns;
  final List<RotationCourtPositionEntity> positions;
}

class RotationCourtPositionEntity {
  const RotationCourtPositionEntity({required this.zone, required this.player});

  final int zone;
  final RotationCourtPlayerEntity? player;
}

class RotationCourtPlayerEntity {
  const RotationCourtPlayerEntity({
    required this.id,
    required this.name,
    required this.role,
    required this.isSetter,
    this.photoPath,
  });

  final int id;
  final String name;
  final String role;
  final bool isSetter;
  final String? photoPath;

  RotationCourtPlayerEntity copyWith({
    String? role,
    bool? isSetter,
    String? photoPath,
  }) {
    return RotationCourtPlayerEntity(
      id: id,
      name: name,
      role: role ?? this.role,
      isSetter: isSetter ?? this.isSetter,
      photoPath: photoPath ?? this.photoPath,
    );
  }
}

class _RotationCount {
  const _RotationCount({
    required this.servingTeamId,
    required this.homeRotationTurns,
    required this.awayRotationTurns,
  });

  final int servingTeamId;
  final int homeRotationTurns;
  final int awayRotationTurns;
}
