import 'package:flutter/material.dart';
import 'package:volley_match/core/theme/app_colors.dart';

class WinnerCard extends StatelessWidget {
  const WinnerCard({super.key, required this.winnerName});

  final String winnerName;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.successBackground,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.35)),
      ),
      child: Text(
        '$winnerName venceu a partida.',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppColors.success,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
