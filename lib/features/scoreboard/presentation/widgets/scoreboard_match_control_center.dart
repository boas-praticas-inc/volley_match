import 'package:flutter/material.dart';
import 'package:volley_match/core/theme/app_colors.dart';

import '../viewmodels/scoreboard_viewmodel.dart';

class MatchControlCenter extends StatelessWidget {
  const MatchControlCenter({super.key, required this.viewModel});

  final ScoreboardViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: viewModel.isMatchReadyToFinish
          ? Center(
              child: _ControlActionButton(
                icon: Icons.flag_rounded,
                label: 'Fim',
                color: AppColors.danger,
                onTap: viewModel.canFinishMatch ? viewModel.finishMatch : null,
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _ControlActionButton(
                  icon: Icons.flag_rounded,
                  label: 'Fim',
                  color: AppColors.danger,
                  onTap: viewModel.canFinishMatch
                      ? viewModel.finishMatch
                      : null,
                ),
                _MainControlButton(
                  isPaused: viewModel.isPaused,
                  onTap: viewModel.canTogglePause
                      ? viewModel.togglePause
                      : null,
                ),
                _ControlActionButton(
                  icon: Icons.skip_next_rounded,
                  label: 'Set',
                  color: AppColors.primary,
                  onTap: viewModel.canCloseSet
                      ? viewModel.closeCurrentSet
                      : null,
                ),
              ],
            ),
    );
  }
}

class _MainControlButton extends StatelessWidget {
  const _MainControlButton({required this.isPaused, required this.onTap});

  final bool isPaused;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;
    final backgroundColor = !isEnabled
        ? AppColors.surfaceMuted
        : isPaused
        ? AppColors.success
        : AppColors.textPrimary;
    final foregroundColor = isEnabled ? Colors.white : AppColors.textSubtle;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Ink(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: isEnabled ? backgroundColor : AppColors.borderDisabled,
            ),
          ),
          child: Icon(
            isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
            color: foregroundColor,
            size: 34,
          ),
        ),
      ),
    );
  }
}

class _ControlActionButton extends StatelessWidget {
  const _ControlActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;
    final effectiveColor = isEnabled ? color : AppColors.textSubtle;
    final backgroundColor = isEnabled
        ? color.withValues(alpha: 0.10)
        : AppColors.surfaceMuted;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          width: 72,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: effectiveColor.withValues(alpha: isEnabled ? 0.22 : 0.16),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: effectiveColor, size: 24),
              const SizedBox(height: 3),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: effectiveColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
