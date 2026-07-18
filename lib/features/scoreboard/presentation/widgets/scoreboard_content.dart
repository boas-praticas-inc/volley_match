import 'package:flutter/material.dart';
import 'package:volley_match/core/theme/app_colors.dart';

import '../../domain/entities/scoreboard_match_entity.dart';
import '../viewmodels/scoreboard_viewmodel.dart';

class PortraitScoreboard extends StatelessWidget {
  const PortraitScoreboard({
    super.key,
    required this.viewModel,
    required this.onNewDraw,
    required this.onRotationTap,
    required this.onExpandedTap,
  });

  final ScoreboardViewModel viewModel;
  final VoidCallback onNewDraw;
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

    final match = viewModel.match!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 2, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MatchHeader(viewModel: viewModel),
          const SizedBox(height: 18),
          Expanded(
            child: ListView(
              children: [
                _ScoreCard(viewModel: viewModel),
                const SizedBox(height: 16),
                _SetHistoryCard(
                  match: match,
                  currentSetNumber: viewModel.currentSetNumber,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _SecondaryScoreboardButton(
                        icon: Icons.rotate_right_outlined,
                        label: 'Ver rotacao',
                        onTap: onRotationTap,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SecondaryScoreboardButton(
                        icon: Icons.open_in_full_outlined,
                        label: 'Placar ampliado',
                        onTap: onExpandedTap,
                      ),
                    ),
                  ],
                ),
                if (viewModel.winnerName != null) ...[
                  const SizedBox(height: 16),
                  _WinnerCard(winnerName: viewModel.winnerName!),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: viewModel.canCloseSet
                  ? () => viewModel.closeCurrentSet()
                  : null,
              icon: const Icon(Icons.skip_next_outlined),
              label: const Text('Proximo set'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: viewModel.canFinishMatch
                  ? () => viewModel.finishMatch()
                  : null,
              child: const Text('Encerrar partida'),
            ),
          ),
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
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
            child: Row(
              children: [
                Expanded(
                  child: _TeamScoreColumn(
                    team: match.homeTeam,
                    score: viewModel.homeScore,
                    setsWon: viewModel.homeSetsWon,
                    accentColor: AppColors.primary,
                    onIncrement: viewModel.incrementHomeScore,
                    onDecrement: viewModel.decrementHomeScore,
                  ),
                ),
                Container(width: 1, height: 194, color: AppColors.borderLight),
                Expanded(
                  child: _TeamScoreColumn(
                    team: match.awayTeam,
                    score: viewModel.awayScore,
                    setsWon: viewModel.awaySetsWon,
                    accentColor: AppColors.danger,
                    onIncrement: viewModel.incrementAwayScore,
                    onDecrement: viewModel.decrementAwayScore,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(26),
                bottomRight: Radius.circular(26),
              ),
            ),
            child: Text(
              viewModel.canCloseSet
                  ? 'Set pode ser fechado'
                  : 'Feche o set quando alguem atingir ${match.pointsPerSet}+ pontos com 2 de vantagem',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: viewModel.canCloseSet
                    ? AppColors.success
                    : AppColors.textMuted,
                fontWeight: FontWeight.w700,
              ),
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
                  'Partida',
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
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

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
  final VoidCallback onPressed;

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

class _SetHistoryCard extends StatelessWidget {
  const _SetHistoryCard({required this.match, required this.currentSetNumber});

  final ScoreboardMatchEntity match;
  final int currentSetNumber;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sets da partida',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Row(
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
                        completedSet == null && setNumber == currentSetNumber,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
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
      constraints: const BoxConstraints(minHeight: 98),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: isCurrent ? 0.14 : 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: accentColor.withValues(alpha: isCurrent ? 0.50 : 0.18),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: isCompleted || isCurrent ? accentColor : Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isCompleted || isCurrent ? Colors.white : accentColor,
              size: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Set $setNumber',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            scoreLabel,
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
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: const BorderSide(color: AppColors.borderLight),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
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
  const LandscapeScoreboard({super.key, required this.viewModel});

  final ScoreboardViewModel viewModel;

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
                onIncrement: viewModel.incrementHomeScore,
                onDecrement: viewModel.decrementHomeScore,
              ),
            ),
            Expanded(
              child: _LandscapeTeamPanel(
                teamName: match.awayTeam.name,
                score: viewModel.awayScore,
                setsWon: viewModel.awaySetsWon,
                backgroundColor: const Color(0xFF7A0710),
                accentColor: const Color(0xFFFF1F2D),
                onIncrement: viewModel.incrementAwayScore,
                onDecrement: viewModel.decrementAwayScore,
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

class _LandscapePrimaryAction extends StatelessWidget {
  const _LandscapePrimaryAction({required this.viewModel});

  final ScoreboardViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final label = viewModel.canFinishMatch
        ? 'Encerrar partida'
        : viewModel.canCloseSet
        ? 'Proximo set'
        : 'Aguardando fechamento do set';

    final onPressed = viewModel.canFinishMatch
        ? viewModel.finishMatch
        : viewModel.canCloseSet
        ? viewModel.closeCurrentSet
        : null;

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
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

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
  final VoidCallback onPressed;

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
