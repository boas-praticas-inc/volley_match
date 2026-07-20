import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:volley_match/core/theme/app_colors.dart';
import 'package:volley_match/shared/widgets/player_photo_avatar.dart';

import '../../domain/services/rotation_calculator.dart';

class RotationCourtBoard extends StatelessWidget {
  const RotationCourtBoard({super.key, required this.state});

  final RotationCourtStateEntity state;

  static const _courtColor = Color(0xFFFF5A00);
  static const _lineColor = Color(0xFF2E7DFF);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boardWidth = constraints.maxWidth;
        final boardHeight = constraints.maxHeight;
        final ratioWidth = boardHeight * 3.35;
        final width = math.min(boardWidth, ratioWidth);
        final height = width / 3.35;

        return Center(
          child: SizedBox(
            width: width,
            height: height,
            child: Container(
              decoration: BoxDecoration(
                color: _courtColor,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: _lineColor, width: 2),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  const Positioned.fill(
                    child: CustomPaint(painter: _CourtPainter()),
                  ),
                  ..._spotsForTeam(state.homeTeam, isHome: true).map((
                    renderedSpot,
                  ) {
                    return _PositionedPlayerBadge(
                      spot: renderedSpot,
                      boardWidth: width,
                      boardHeight: height,
                    );
                  }),
                  ..._spotsForTeam(state.awayTeam, isHome: false).map((
                    renderedSpot,
                  ) {
                    return _PositionedPlayerBadge(
                      spot: renderedSpot,
                      boardWidth: width,
                      boardHeight: height,
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<_RenderedSpot> _spotsForTeam(
    RotationTeamStateEntity team, {
    required bool isHome,
  }) {
    return team.positions.map((position) {
      return _RenderedSpot(
        position: position,
        offset: _zoneOffset(position.zone, isHome: isHome),
        isHome: isHome,
      );
    }).toList();
  }

  Offset _zoneOffset(int zone, {required bool isHome}) {
    final homeOffsets = <int, Offset>{
      1: const Offset(0.15, 0.55),
      2: const Offset(0.36, 0.21),
      3: const Offset(0.36, 0.55),
      4: const Offset(0.15, 0.21),
      5: const Offset(0.15, 0.86),
      6: const Offset(0.36, 0.86),
    };

    final homeOffset = homeOffsets[zone] ?? Offset.zero;

    if (isHome) {
      return homeOffset;
    }

    return Offset(1 - homeOffset.dx, 1 - homeOffset.dy);
  }
}

class _PositionedPlayerBadge extends StatelessWidget {
  const _PositionedPlayerBadge({
    required this.spot,
    required this.boardWidth,
    required this.boardHeight,
  });

  final _RenderedSpot spot;
  final double boardWidth;
  final double boardHeight;

  @override
  Widget build(BuildContext context) {
    final badgeWidth = (boardWidth * 0.12).clamp(82.0, 124.0);
    const badgeHeight = 48.0;

    return Positioned(
      left: (spot.offset.dx * boardWidth) - (badgeWidth / 2),
      top: (spot.offset.dy * boardHeight) - (badgeHeight / 2),
      width: badgeWidth,
      child: _PlayerBadge(
        position: spot.position,
        accentColor: spot.isHome ? AppColors.primary : AppColors.danger,
      ),
    );
  }
}

class _PlayerBadge extends StatelessWidget {
  const _PlayerBadge({required this.position, required this.accentColor});

  final RotationCourtPositionEntity position;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final player = position.player;
    final role = player?.role ?? 'P${position.zone}';
    final name = player?.name ?? 'Livre';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          role,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 10,
            height: 1,
          ),
        ),
        const SizedBox(height: 3),
        _PlayerNamePill(player: player, name: name, accentColor: accentColor),
      ],
    );
  }
}

class _PlayerNamePill extends StatelessWidget {
  const _PlayerNamePill({
    required this.player,
    required this.name,
    required this.accentColor,
  });

  final RotationCourtPlayerEntity? player;
  final String name;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final courtPlayer = player;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(4, 4, 7, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2A101828),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PlayerPhotoAvatar(
            name: name,
            size: 24,
            photoPath: courtPlayer?.photoPath,
            backgroundColor: courtPlayer == null
                ? AppColors.textSubtle
                : courtPlayer.isSetter
                ? AppColors.secondary
                : accentColor,
            icon: courtPlayer == null ? Icons.person_outline : null,
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.left,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: const Color(0xFF0E1A2D),
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CourtPainter extends CustomPainter {
  const _CourtPainter();

  static const _lineColor = Color(0xFF2E7DFF);

  @override
  void paint(Canvas canvas, Size size) {
    final solidPaint = Paint()
      ..color = _lineColor
      ..strokeWidth = 2;
    final dashPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.86)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final centerX = size.width / 2;

    canvas.drawLine(
      Offset(centerX, 0),
      Offset(centerX, size.height),
      solidPaint,
    );
    _drawDashedLine(
      canvas,
      Offset(size.width * 0.30, 0),
      Offset(size.width * 0.30, size.height),
      dashPaint,
    );
    _drawDashedLine(
      canvas,
      Offset(size.width * 0.72, 0),
      Offset(size.width * 0.72, size.height),
      dashPaint,
    );
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashHeight = 7.0;
    const dashSpace = 10.0;
    var y = start.dy;

    while (y < end.dy) {
      canvas.drawLine(
        Offset(start.dx, y),
        Offset(start.dx, math.min(y + dashHeight, end.dy)),
        paint,
      );
      y += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class _RenderedSpot {
  const _RenderedSpot({
    required this.position,
    required this.offset,
    required this.isHome,
  });

  final RotationCourtPositionEntity position;
  final Offset offset;
  final bool isHome;
}
