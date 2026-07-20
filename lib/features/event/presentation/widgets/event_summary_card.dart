import 'package:flutter/material.dart';
import 'package:volley_match/core/theme/app_colors.dart';

class EventSummaryCard extends StatelessWidget {
  const EventSummaryCard({
    super.key,
    required this.selectedBestOfSets,
    required this.setsToWin,
    required this.pointsPerSet,
  });

  final int selectedBestOfSets;
  final int setsToWin;
  final int pointsPerSet;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: AppColors.surfaceMuted,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.rule_outlined, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Partida em melhor de $selectedBestOfSets sets, vence quem fizer $setsToWin set(s). Cada set vai ate $pointsPerSet pontos.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
