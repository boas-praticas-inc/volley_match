import 'package:flutter/material.dart';
import 'package:volley_match/core/theme/app_colors.dart';

import '../../../players/domain/entities/player_entity.dart';
import 'player_avatar.dart';
import 'team_draw_widget_constants.dart';

class GeneratedTeamCard extends StatelessWidget {
  const GeneratedTeamCard({
    super.key,
    required this.onEditName,
    required this.title,
    required this.players,
  });

  final VoidCallback onEditName;
  final String title;
  final List<PlayerEntity> players;

  double get averageSkillRating {
    if (players.isEmpty) {
      return 0;
    }

    final totalSkillRating = players.fold(
      0,
      (total, player) => total + player.skillRating,
    );

    return totalSkillRating / players.length;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F101828),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(22),
                topRight: Radius.circular(22),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: onEditName,
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit_outlined,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
                  ),
                  child: Text(
                    'Média ${averageSkillRating.toStringAsFixed(1)}',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 2),
            child: Column(
              children: players
                  .map(
                    (player) => Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: _GeneratedTeamPlayerRow(player: player),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _GeneratedTeamPlayerRow extends StatelessWidget {
  const _GeneratedTeamPlayerRow({required this.player});

  final PlayerEntity player;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        PlayerAvatar(
          player: player,
          size: 44,
          colors: teamDrawAvatarColors,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                player.name,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                player.position,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Row(
          children: List.generate(
            10,
            (index) => Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: index < player.skillRating
                      ? AppColors.primary
                      : AppColors.borderDisabled,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
