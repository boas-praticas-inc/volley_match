import 'package:flutter/material.dart';
import 'package:volley_match/core/theme/app_colors.dart';

import '../viewmodels/scoreboard_viewmodel.dart';

class LandscapeScoreboard extends StatelessWidget {
  const LandscapeScoreboard({
    super.key,
    required this.viewModel,
    required this.onExitExpanded,
  });

  final ScoreboardViewModel viewModel;
  final VoidCallback onExitExpanded;

  @override
  Widget build(BuildContext context) {
    final match = viewModel.match!;

    return Stack(
      children: [
        Row(
          children: [
            Expanded(
              child: _LandscapeTeamPanel(
                teamName: match.homeTeam.name,
                score: viewModel.homeScore,
                setsWon: viewModel.homeSetsWon,
                backgroundColor: const Color(0xFF17275D),
                accentColor: AppColors.primary,
                onIncrement: viewModel.canEditScore
                    ? viewModel.incrementHomeScore
                    : null,
                onDecrement: viewModel.canEditScore
                    ? viewModel.decrementHomeScore
                    : null,
              ),
            ),
            Expanded(
              child: _LandscapeTeamPanel(
                teamName: match.awayTeam.name,
                score: viewModel.awayScore,
                setsWon: viewModel.awaySetsWon,
                backgroundColor: const Color(0xFF7A0710),
                accentColor: const Color(0xFFFF1F2D),
                onIncrement: viewModel.canEditScore
                    ? viewModel.incrementAwayScore
                    : null,
                onDecrement: viewModel.canEditScore
                    ? viewModel.decrementAwayScore
                    : null,
              ),
            ),
          ],
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.textPrimary.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.schedule, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        viewModel.formattedElapsedTime,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Set ${viewModel.currentSetNumber} / ${match.bestOfSets}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 14, top: 12),
              child: _LandscapeModeButton(onTap: onExitExpanded),
            ),
          ),
        ),
        if (!viewModel.isMatchReadyToFinish)
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 14, top: 12),
                child: _LandscapePauseButton(viewModel: viewModel),
              ),
            ),
          ),
        SafeArea(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: _LandscapePrimaryAction(viewModel: viewModel),
            ),
          ),
        ),
      ],
    );
  }
}

class _LandscapeModeButton extends StatelessWidget {
  const _LandscapeModeButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.stay_current_portrait_outlined,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                'Vertical',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LandscapePauseButton extends StatelessWidget {
  const _LandscapePauseButton({required this.viewModel});

  final ScoreboardViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final isPaused = viewModel.isPaused;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: viewModel.canTogglePause ? viewModel.togglePause : null,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                isPaused ? 'Continuar' : 'Pausar',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LandscapePrimaryAction extends StatelessWidget {
  const _LandscapePrimaryAction({required this.viewModel});

  final ScoreboardViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    if (!viewModel.canFinishMatch && !viewModel.canCloseSet) {
      return const SizedBox.shrink();
    }

    final label = viewModel.canFinishMatch ? 'Fim' : 'Próximo set';

    final onPressed = viewModel.canFinishMatch
        ? viewModel.finishMatch
        : viewModel.closeCurrentSet;

    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        disabledBackgroundColor: Colors.white.withValues(alpha: 0.20),
        disabledForegroundColor: Colors.white.withValues(alpha: 0.76),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      child: Text(label),
    );
  }
}

class _LandscapeTeamPanel extends StatelessWidget {
  const _LandscapeTeamPanel({
    required this.teamName,
    required this.score,
    required this.setsWon,
    required this.backgroundColor,
    required this.accentColor,
    required this.onIncrement,
    required this.onDecrement,
  });

  final String teamName;
  final int score;
  final int setsWon;
  final Color backgroundColor;
  final Color accentColor;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(34, 26, 34, 26),
          child: Column(
            children: [
              Text(
                teamName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$setsWon sets',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.76),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '$score',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: Colors.white,
                  fontSize: 116,
                  fontWeight: FontWeight.w900,
                  height: 0.9,
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _LandscapeScoreButton(
                    icon: Icons.remove,
                    backgroundColor: Colors.white.withValues(alpha: 0.14),
                    onPressed: onDecrement,
                  ),
                  const SizedBox(width: 18),
                  _LandscapeScoreButton(
                    icon: Icons.add,
                    backgroundColor: accentColor,
                    onPressed: onIncrement,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LandscapeScoreButton extends StatelessWidget {
  const _LandscapeScoreButton({
    required this.icon,
    required this.backgroundColor,
    required this.onPressed,
  });

  final IconData icon;
  final Color backgroundColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 64,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: Colors.white,
          padding: EdgeInsets.zero,
          shape: const CircleBorder(),
        ),
        child: Icon(icon, size: 36),
      ),
    );
  }
}
