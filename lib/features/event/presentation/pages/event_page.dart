import 'package:flutter/material.dart';
import 'package:volley_match/core/theme/app_colors.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/feature_navBar.dart';
import '../../domain/entities/event_progress_entity.dart';
import '../viewmodels/event_viewmodel.dart';

class EventPage extends StatefulWidget {
  const EventPage({super.key});

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  late final EventViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = EventViewModel();
    viewModel.loadActiveEvent();
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  void _openNewDraw() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.teamDraw);
  }

  Future<void> _confirmFinishEvent(EventProgressEntity progress) async {
    final shouldFinish = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Finalizar evento?'),
          content: const Text(
            'Isso encerra o evento atual e remove a partida em andamento da tela de placar.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
              ),
              child: const Text('Finalizar'),
            ),
          ],
        );
      },
    );

    if (shouldFinish != true) {
      return;
    }

    final finished = await viewModel.finishEvent(progress.eventId);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          finished
              ? 'Evento finalizado.'
              : 'Nao foi possivel finalizar o evento.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FeatureNavBar(
      indiceAtual: 3,
      appBar: AppBar(
        title: const Text('Evento'),
        actions: [
          IconButton(
            onPressed: viewModel.loadActiveEvent,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: viewModel,
        builder: (context, _) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final progress = viewModel.eventProgress;

          if (progress == null) {
            return _EmptyEventState(
              message:
                  viewModel.errorMessage ??
                  'Nenhum evento em andamento encontrado.',
              onNewDraw: _openNewDraw,
            );
          }

          return RefreshIndicator(
            onRefresh: viewModel.loadActiveEvent,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 2, 20, 20),
              children: [
                _EventSummary(progress: progress),
                const SizedBox(height: 16),
                _CurrentMatchCard(match: progress.currentMatch),
                const SizedBox(height: 18),
                _SectionTitle(
                  title: 'Times no evento',
                  subtitle: _queueSubtitle(progress),
                ),
                const SizedBox(height: 12),
                ..._orderedTeams(progress.teams).map((team) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _TeamProgressCard(team: team),
                  );
                }),
                const SizedBox(height: 6),
                _SectionTitle(
                  title: 'Historico de partidas',
                  subtitle: '${progress.finishedMatches} finalizadas',
                ),
                const SizedBox(height: 12),
                if (progress.matches.isEmpty)
                  const _EmptyHistoryCard()
                else
                  ...progress.matches.reversed.map((match) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _MatchHistoryCard(match: match),
                    );
                  }),
                const SizedBox(height: 8),
                _FinishEventButton(
                  isLoading: viewModel.isFinishing,
                  onTap: viewModel.isFinishing
                      ? null
                      : () => _confirmFinishEvent(progress),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _queueSubtitle(EventProgressEntity progress) {
    final waitingTeams = progress.teams.where((team) => !team.isPlaying).length;

    if (progress.currentMatch == null) {
      return '$waitingTeams times aguardando';
    }

    return 'Vencedor fica, proximo da fila entra';
  }

  List<EventTeamProgressEntity> _orderedTeams(
    List<EventTeamProgressEntity> teams,
  ) {
    final orderedTeams = [...teams];

    orderedTeams.sort((first, second) {
      if (first.isPlaying && !second.isPlaying) {
        return -1;
      }

      if (!first.isPlaying && second.isPlaying) {
        return 1;
      }

      final firstOrder = first.waitingOrder ?? 9999;
      final secondOrder = second.waitingOrder ?? 9999;
      final orderComparison = firstOrder.compareTo(secondOrder);

      if (orderComparison != 0) {
        return orderComparison;
      }

      return first.id.compareTo(second.id);
    });

    return orderedTeams;
  }
}

class _FinishEventButton extends StatelessWidget {
  const _FinishEventButton({required this.isLoading, required this.onTap});

  final bool isLoading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.danger,
          side: BorderSide(color: AppColors.danger.withValues(alpha: 0.42)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        icon: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.stop_circle_outlined),
        label: const Text('Finalizar evento'),
      ),
    );
  }
}

class _EventSummary extends StatelessWidget {
  const _EventSummary({required this.progress});

  final EventProgressEntity progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            progress.name,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SummaryMetric(
                  value: '${progress.totalTeams}',
                  label: 'times',
                ),
              ),
              Expanded(
                child: _SummaryMetric(
                  value: '${progress.totalPlayers}',
                  label: 'jogadores',
                ),
              ),
              Expanded(
                child: _SummaryMetric(
                  value: '${progress.finishedMatches}/${progress.totalMatches}',
                  label: 'partidas',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.72),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentMatchCard extends StatelessWidget {
  const _CurrentMatchCard({required this.match});

  final EventMatchProgressEntity? match;

  @override
  Widget build(BuildContext context) {
    final currentMatch = match;

    if (currentMatch == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Text(
          'Nenhuma partida ativa neste evento.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.successBackground,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Em quadra',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'Melhor de ${currentMatch.bestOfSets}',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _CurrentTeamName(
                  name: currentMatch.homeTeamName,
                  color: AppColors.primary,
                  alignment: TextAlign.left,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.textPrimary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  currentMatch.scoreLabel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Expanded(
                child: _CurrentTeamName(
                  name: currentMatch.awayTeamName,
                  color: AppColors.danger,
                  alignment: TextAlign.right,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${currentMatch.pointsPerSet} pontos por set',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentTeamName extends StatelessWidget {
  const _CurrentTeamName({
    required this.name,
    required this.color,
    required this.alignment,
  });

  final String name;
  final Color color;
  final TextAlign alignment;

  @override
  Widget build(BuildContext context) {
    return Text(
      name,
      textAlign: alignment,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: color,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
        ),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _TeamProgressCard extends StatelessWidget {
  const _TeamProgressCard({required this.team});

  final EventTeamProgressEntity team;

  @override
  Widget build(BuildContext context) {
    final statusColor = team.isPlaying ? AppColors.success : AppColors.primary;
    final statusBackground = team.isPlaying
        ? AppColors.successBackground
        : AppColors.primary.withValues(alpha: 0.10);
    final statusLabel = team.isPlaying
        ? 'Jogando'
        : 'Fila ${team.waitingOrder ?? '-'}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: statusBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(
              team.isPlaying
                  ? Icons.sports_volleyball_outlined
                  : Icons.queue_play_next_outlined,
              color: statusColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  team.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${team.playersCount} jogadores | ${team.matchesPlayed} jogos | ${team.wins} vitorias',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: statusBackground,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              statusLabel,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchHistoryCard extends StatelessWidget {
  const _MatchHistoryCard({required this.match});

  final EventMatchProgressEntity match;

  @override
  Widget build(BuildContext context) {
    final isActive = match.status == 'in_progress';
    final statusColor = isActive ? AppColors.success : AppColors.textMuted;
    final statusBackground = isActive
        ? AppColors.successBackground
        : AppColors.surfaceMuted;

    return Container(
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

class _EmptyHistoryCard extends StatelessWidget {
  const _EmptyHistoryCard();

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
        'As partidas do evento vao aparecer aqui.',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: AppColors.textMuted,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyEventState extends StatelessWidget {
  const _EmptyEventState({required this.message, required this.onNewDraw});

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
            'Nenhum evento ativo',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
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
            child: const Icon(
              Icons.timeline_outlined,
              color: AppColors.primary,
              size: 42,
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
