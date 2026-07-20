import 'package:flutter/material.dart';
import 'package:volley_match/core/theme/app_colors.dart';

import '../../domain/services/rotation_calculator.dart';
import '../viewmodels/rotation_guide_viewmodel.dart';

class RotationFooter extends StatelessWidget {
  const RotationFooter({
    super.key,
    required this.state,
    required this.viewModel,
  });

  final RotationCourtStateEntity state;
  final RotationGuideViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ServeStatusPill(
            color: AppColors.primary,
            teamName: state.homeTeam.name,
            isServing: state.homeTeam.isServing,
          ),
        ),
        const Spacer(),
        _ScoreAdjustButton(
          icon: Icons.remove,
          color: AppColors.primary,
          onTap: viewModel.canEditScore ? viewModel.decrementHomeScore : null,
        ),
        const SizedBox(width: 8),
        _ScoreAdjustButton(
          icon: Icons.add,
          color: AppColors.primary,
          onTap: viewModel.canEditScore ? viewModel.incrementHomeScore : null,
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '${state.homeScore} x ${state.awayScore}',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 10),
        _ScoreAdjustButton(
          icon: Icons.remove,
          color: AppColors.danger,
          onTap: viewModel.canEditScore ? viewModel.decrementAwayScore : null,
        ),
        const SizedBox(width: 8),
        _ScoreAdjustButton(
          icon: Icons.add,
          color: AppColors.danger,
          onTap: viewModel.canEditScore ? viewModel.incrementAwayScore : null,
        ),
        const Spacer(),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: _ServeStatusPill(
              color: AppColors.danger,
              teamName: state.awayTeam.name,
              isServing: state.awayTeam.isServing,
            ),
          ),
        ),
      ],
    );
  }
}

class _ScoreAdjustButton extends StatelessWidget {
  const _ScoreAdjustButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Ink(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: isEnabled
                ? color.withValues(alpha: 0.88)
                : Colors.white.withValues(alpha: 0.10),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          ),
          child: Icon(
            icon,
            color: isEnabled
                ? Colors.white
                : Colors.white.withValues(alpha: 0.42),
            size: 21,
          ),
        ),
      ),
    );
  }
}

class _ServeStatusPill extends StatelessWidget {
  const _ServeStatusPill({
    required this.color,
    required this.teamName,
    required this.isServing,
  });

  final Color color;
  final String teamName;
  final bool isServing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          '$teamName | ${isServing ? 'Saque' : 'Side-Out'}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
