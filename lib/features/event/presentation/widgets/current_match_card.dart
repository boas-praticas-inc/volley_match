import 'package:flutter/material.dart';
import 'package:volley_match/core/theme/app_colors.dart';

import '../../domain/entities/event_progress_entity.dart';

class CurrentMatchCard extends StatelessWidget {
  const CurrentMatchCard({
    super.key,
    required this.match,
    required this.homeTeam,
    required this.awayTeam,
    required this.onTeamTap,
  });

  final EventMatchProgressEntity? match;
  final EventTeamProgressEntity? homeTeam;
  final EventTeamProgressEntity? awayTeam;
  final ValueChanged<EventTeamProgressEntity> onTeamTap;

  @override
  Widget build(BuildContext context) {
    final currentMatch = match;

    if (currentMatch == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Text(
          'Nenhuma partida ativa neste evento.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.successBackground,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Em quadra',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'Melhor de ${currentMatch.bestOfSets}',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _CurrentTeamName(
                  name: currentMatch.homeTeamName,
                  color: AppColors.primary,
                  alignment: TextAlign.left,
                  onTap: homeTeam == null ? null : () => onTeamTap(homeTeam!),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.textPrimary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  currentMatch.scoreLabel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Expanded(
                child: _CurrentTeamName(
                  name: currentMatch.awayTeamName,
                  color: AppColors.danger,
                  alignment: TextAlign.right,
                  onTap: awayTeam == null ? null : () => onTeamTap(awayTeam!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${currentMatch.pointsPerSet} pontos por set',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentTeamName extends StatelessWidget {
  const _CurrentTeamName({
    required this.name,
    required this.color,
    required this.alignment,
    required this.onTap,
  });

  final String name;
  final Color color;
  final TextAlign alignment;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: alignment == TextAlign.right
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              Flexible(
                child: Text(
                  name,
                  textAlign: alignment,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: 5),
                Icon(Icons.groups_2_outlined, color: color, size: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
