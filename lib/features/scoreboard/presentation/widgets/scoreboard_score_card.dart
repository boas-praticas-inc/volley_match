import 'package:flutter/material.dart';
import 'package:volley_match/core/theme/app_colors.dart';

import '../../domain/entities/scoreboard_match_entity.dart';
import '../viewmodels/scoreboard_viewmodel.dart';

class ScoreCard extends StatelessWidget {
  const ScoreCard({
    super.key,
    required this.viewModel,
    required this.onHomeTeamTap,
    required this.onAwayTeamTap,
  });

  final ScoreboardViewModel viewModel;
  final VoidCallback onHomeTeamTap;
  final VoidCallback onAwayTeamTap;

  @override
  Widget build(BuildContext context) {
    final match = viewModel.match!;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(26),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _TeamScoreColumn(
                      team: match.homeTeam,
                      score: viewModel.homeScore,
                      setsWon: viewModel.homeSetsWon,
                      accentColor: AppColors.primary,
                      onTeamTap: onHomeTeamTap,
                      onIncrement: viewModel.canEditScore
                          ? viewModel.incrementHomeScore
                          : null,
                      onDecrement: viewModel.canEditScore
                          ? viewModel.decrementHomeScore
                          : null,
                    ),
                  ),
                  Container(width: 1, color: AppColors.borderLight),
                  Expanded(
                    child: _TeamScoreColumn(
                      team: match.awayTeam,
                      score: viewModel.awayScore,
                      setsWon: viewModel.awaySetsWon,
                      accentColor: AppColors.danger,
                      onTeamTap: onAwayTeamTap,
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
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.035),
              borderRadius: BorderRadius.only(
                bottomLeft: const Radius.circular(26),
                bottomRight: const Radius.circular(26),
              ),
              border: const Border(
                top: BorderSide(color: AppColors.borderLight),
              ),
            ),
            child: _SetHistoryStrip(
              match: match,
              currentSetNumber: viewModel.currentSetNumber,
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamScoreColumn extends StatelessWidget {
  const _TeamScoreColumn({
    required this.team,
    required this.score,
    required this.setsWon,
    required this.accentColor,
    required this.onTeamTap,
    required this.onIncrement,
    required this.onDecrement,
  });

  final ScoreboardTeamEntity team;
  final int score;
  final int setsWon;
  final Color accentColor;
  final VoidCallback onTeamTap;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTeamTap,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$setsWon sets',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          team.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Icon(
                        Icons.groups_2_outlined,
                        color: accentColor,
                        size: 17,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$score',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            color: AppColors.textPrimary,
            fontSize: 76,
            fontWeight: FontWeight.w900,
            height: 0.98,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ScoreControlButton(
              icon: Icons.remove,
              backgroundColor: AppColors.surfaceMuted,
              foregroundColor: AppColors.textPrimary,
              onPressed: onDecrement,
            ),
            const SizedBox(width: 12),
            _ScoreControlButton(
              icon: Icons.add,
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
              onPressed: onIncrement,
            ),
          ],
        ),
      ],
    );
  }
}

class _ScoreControlButton extends StatelessWidget {
  const _ScoreControlButton({
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
  });

  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 54,
      height: 54,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          padding: EdgeInsets.zero,
          shape: const CircleBorder(),
        ),
        child: Icon(icon, size: 30),
      ),
    );
  }
}

class _SetHistoryStrip extends StatelessWidget {
  const _SetHistoryStrip({required this.match, required this.currentSetNumber});

  final ScoreboardMatchEntity match;
  final int currentSetNumber;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(match.bestOfSets, (index) {
        final setNumber = index + 1;
        final completedSet = _completedSetByNumber(setNumber);

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: setNumber == match.bestOfSets ? 0 : 8,
            ),
            child: _SetMarker(
              setNumber: setNumber,
              completedSet: completedSet,
              match: match,
              isCurrent:
                  match.status != 'finished' &&
                  completedSet == null &&
                  setNumber == currentSetNumber,
            ),
          ),
        );
      }),
    );
  }

  ScoreboardSetEntity? _completedSetByNumber(int setNumber) {
    for (final set in match.completedSets) {
      if (set.number == setNumber) {
        return set;
      }
    }

    return null;
  }
}

class _SetMarker extends StatelessWidget {
  const _SetMarker({
    required this.setNumber,
    required this.completedSet,
    required this.match,
    required this.isCurrent,
  });

  final int setNumber;
  final ScoreboardSetEntity? completedSet;
  final ScoreboardMatchEntity match;
  final bool isCurrent;

  bool get isCompleted => completedSet != null;

  Color get accentColor {
    final set = completedSet;

    if (set == null) {
      return isCurrent ? AppColors.secondary : AppColors.textSubtle;
    }

    return set.winnerTeamId == match.homeTeam.id
        ? AppColors.primary
        : AppColors.danger;
  }

  IconData get icon {
    if (isCompleted) {
      return Icons.emoji_events_outlined;
    }

    if (isCurrent) {
      return Icons.sports_score_outlined;
    }

    return Icons.radio_button_unchecked;
  }

  String get scoreLabel {
    final set = completedSet;

    if (set == null) {
      return isCurrent ? 'em jogo' : 'pendente';
    }

    return '${set.homeScore}-${set.awayScore}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 64),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: isCurrent
            ? accentColor.withValues(alpha: 0.14)
            : isCompleted
            ? Colors.white
            : Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withValues(alpha: isCurrent ? 0.50 : 0.20),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: accentColor, size: 16),
              const SizedBox(width: 4),
              Text(
                'Set $setNumber',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            scoreLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: accentColor,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
