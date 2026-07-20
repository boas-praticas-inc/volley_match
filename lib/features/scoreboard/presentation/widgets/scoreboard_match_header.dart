import 'package:flutter/material.dart';
import 'package:volley_match/core/theme/app_colors.dart';

import '../viewmodels/scoreboard_viewmodel.dart';

class ScoreboardMatchHeader extends StatelessWidget {
  const ScoreboardMatchHeader({super.key, required this.viewModel});

  final ScoreboardViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final match = viewModel.match!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F101828),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          _HeaderPill(
            icon: Icons.schedule,
            label: viewModel.formattedElapsedTime,
            alignment: MainAxisAlignment.start,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  viewModel.isReadOnly ? 'Finalizada' : 'Partida',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${match.pointsPerSet} pontos',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.70),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          _HeaderPill(
            label: 'Set ${viewModel.currentSetNumber}/${match.bestOfSets}',
            alignment: MainAxisAlignment.end,
          ),
        ],
      ),
    );
  }
}

class _HeaderPill extends StatelessWidget {
  const _HeaderPill({required this.label, required this.alignment, this.icon});

  final String label;
  final MainAxisAlignment alignment;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 102,
      child: Row(
        mainAxisAlignment: alignment,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 15, color: Colors.white),
                  const SizedBox(width: 5),
                ],
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
