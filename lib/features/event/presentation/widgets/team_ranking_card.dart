import 'package:flutter/material.dart';
import 'package:volley_match/core/theme/app_colors.dart';

import '../../domain/entities/event_progress_entity.dart';

class TeamRankingCard extends StatelessWidget {
  const TeamRankingCard({
    super.key,
    required this.team,
    required this.position,
    required this.onTap,
  });

  final EventTeamProgressEntity team;
  final int position;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isLeader = position == 1;
    final rankColor = isLeader ? AppColors.success : AppColors.primary;
    final rankBackground = isLeader
        ? AppColors.successBackground
        : AppColors.primary.withValues(alpha: 0.10);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: rankBackground,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$position',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: rankColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      team.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${team.playersCount} jogadores | ${team.matchesPlayed} jogos | ${team.wins} vitórias',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: rankBackground,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isLeader
                          ? Icons.emoji_events_outlined
                          : Icons.groups_2_outlined,
                      color: rankColor,
                      size: 16,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${team.wins}V',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: rankColor,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
