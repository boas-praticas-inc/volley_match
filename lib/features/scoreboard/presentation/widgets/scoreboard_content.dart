import 'package:flutter/material.dart';
import 'package:volley_match/core/theme/app_colors.dart';

import '../../domain/entities/scoreboard_match_entity.dart';
import '../viewmodels/scoreboard_viewmodel.dart';

class PortraitScoreboard extends StatelessWidget {
  const PortraitScoreboard({
    super.key,
    required this.viewModel,
    required this.onNewDraw,
    required this.onEventTap,
    required this.onRotationTap,
    required this.onExpandedTap,
  });

  final ScoreboardViewModel viewModel;
  final VoidCallback onNewDraw;
  final VoidCallback onEventTap;
  final VoidCallback onRotationTap;
  final VoidCallback onExpandedTap;

  @override
  Widget build(BuildContext context) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!viewModel.hasMatch) {
      return NoActiveMatchState(
        message:
            viewModel.errorMessage ??
            'Nenhuma partida em andamento encontrada.',
        onNewDraw: onNewDraw,
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 2, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MatchHeader(viewModel: viewModel),
          const SizedBox(height: 12),
          _ScoreCard(viewModel: viewModel),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SecondaryScoreboardButton(
                  icon: Icons.timeline_outlined,
                  label: 'Evento',
                  onTap: onEventTap,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SecondaryScoreboardButton(
                  icon: Icons.rotate_right_outlined,
                  label: 'Rotacao',
                  onTap: onRotationTap,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SecondaryScoreboardButton(
                  icon: Icons.open_in_full_outlined,
                  label: 'Ampliado',
                  onTap: onExpandedTap,
                ),
              ),
            ],
          ),
          if (viewModel.winnerName != null) ...[
            const SizedBox(height: 12),
            _WinnerCard(winnerName: viewModel.winnerName!),
          ],
          const Spacer(),
          if (!viewModel.isReadOnly) ...[
            const SizedBox(height: 12),
            _MatchControlCenter(viewModel: viewModel),
          ],
        ],
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.viewModel});

  final ScoreboardViewModel viewModel;

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

class _MatchHeader extends StatelessWidget {
  const _MatchHeader({required this.viewModel});

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

class _TeamScoreColumn extends StatelessWidget {
  const _TeamScoreColumn({
    required this.team,
    required this.score,
    required this.setsWon,
    required this.accentColor,
    required this.onIncrement,
    required this.onDecrement,
  });

  final ScoreboardTeamEntity team;
  final int score;
  final int setsWon;
  final Color accentColor;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
        Text(
          team.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
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

class _MatchControlCenter extends StatelessWidget {
  const _MatchControlCenter({required this.viewModel});

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

class _SecondaryScoreboardButton extends StatelessWidget {
  const _SecondaryScoreboardButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 17, color: AppColors.primary),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WinnerCard extends StatelessWidget {
  const _WinnerCard({required this.winnerName});

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

class NoActiveMatchState extends StatelessWidget {
  const NoActiveMatchState({
    super.key,
    required this.message,
    required this.onNewDraw,
  });

  final String message;
  final VoidCallback onNewDraw;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 2, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nenhuma partida ativa',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.sports_volleyball_outlined,
                  color: AppColors.primary,
                  size: 36,
                ),
                const SizedBox(height: 14),
                Text(
                  'Para iniciar uma partida, faca um novo sorteio e configure o evento.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onNewDraw,
              icon: const Icon(Icons.casino_outlined),
              label: const Text('Fazer novo sorteio'),
            ),
          ),
        ],
      ),
    );
  }
}

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

    final label = viewModel.canFinishMatch ? 'Fim' : 'Proximo set';

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
