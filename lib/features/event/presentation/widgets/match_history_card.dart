import 'package:flutter/material.dart';
import 'package:volley_match/core/theme/app_colors.dart';

import '../../domain/entities/event_progress_entity.dart';

class MatchHistoryCard extends StatelessWidget {
  const MatchHistoryCard({super.key, required this.match, required this.onTap});

  final EventMatchProgressEntity match;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isActive = match.status == 'in_progress';
    final statusColor = isActive ? AppColors.success : AppColors.textMuted;
    final statusBackground = isActive
        ? AppColors.successBackground
        : AppColors.surfaceMuted;

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
            border: Border.all(
              color: isActive
                  ? AppColors.success.withValues(alpha: 0.32)
                  : AppColors.borderLight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${match.homeTeamName} x ${match.awayTeamName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusBackground,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      isActive ? 'Atual' : 'Finalizada',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.visibility_outlined,
                      color: AppColors.primary,
                      size: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Sets ${match.scoreLabel}${match.winnerTeamName == null ? '' : ' | venceu ${match.winnerTeamName}'}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (match.completedSets.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: match.completedSets.map((set) {
                    return _SetScorePill(set: set);
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SetScorePill extends StatelessWidget {
  const _SetScorePill({required this.set});

  final EventSetProgressEntity set;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'S${set.number} ${set.homeScore}-${set.awayScore}',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class EmptyHistoryCard extends StatelessWidget {
  const EmptyHistoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Text(
        'As partidas do evento vão aparecer aqui.',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: AppColors.textMuted,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
