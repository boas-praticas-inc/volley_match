import 'package:flutter/material.dart';
import 'package:volley_match/core/theme/app_colors.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/feature_navBar.dart';
import '../../../scoreboard/presentation/pages/scoreboard_page.dart';
import '../../domain/entities/event_progress_entity.dart';
import '../viewmodels/event_viewmodel.dart';

class EventPage extends StatefulWidget {
  const EventPage({super.key, this.eventId});

  final int? eventId;

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  late final EventViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = EventViewModel();
    viewModel.loadEvent(eventId: widget.eventId);
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  void _openNewDraw() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.teamDraw);
  }

  Future<void> _openMatch(EventMatchProgressEntity match) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ScoreboardPage(matchId: match.id)),
    );
    await viewModel.loadEvent(eventId: widget.eventId);
  }

  Future<void> _editEventName(EventProgressEntity progress) async {
    final updatedName = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return _EditEventNameDialog(initialName: progress.name);
      },
    );

    if (updatedName == null || updatedName.trim().isEmpty) {
      return;
    }

    final saved = await viewModel.updateEventName(
      eventId: progress.eventId,
      name: updatedName,
    );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          saved
              ? 'Nome do evento atualizado.'
              : 'Nao foi possivel atualizar o nome do evento.',
        ),
      ),
    );
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

  Future<void> _confirmDeleteEvent(EventProgressEntity progress) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Excluir evento?'),
          content: Text(
            'O evento "${progress.name}" sera removido junto com seus times, partidas e sets.',
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
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    final deleted = await viewModel.deleteEvent(progress.eventId);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          deleted ? 'Evento excluido.' : 'Nao foi possivel excluir o evento.',
        ),
      ),
    );

    if (deleted) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(true);
      } else {
        Navigator.of(context).pushReplacementNamed(AppRoutes.events);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FeatureNavBar(
      indiceAtual: 2,
      appBar: AppBar(
        title: const Text('Evento'),
        actions: [
          IconButton(
            onPressed: () => viewModel.loadEvent(eventId: widget.eventId),
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
            onRefresh: () => viewModel.loadEvent(eventId: widget.eventId),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 2, 20, 20),
              children: [
                _EventSummary(
                  progress: progress,
                  isRenaming: viewModel.isRenaming,
                  isDeleting: viewModel.isDeleting,
                  onEditName: () => _editEventName(progress),
                  onDelete: () => _confirmDeleteEvent(progress),
                ),
                const SizedBox(height: 16),
                _CurrentMatchCard(match: progress.currentMatch),
                const SizedBox(height: 18),
                _SectionTitle(
                  title: 'Ranking dos times',
                  subtitle: '${progress.totalTeams} times',
                ),
                const SizedBox(height: 12),
                ..._rankedTeams(progress.teams).asMap().entries.map((entry) {
                  final position = entry.key + 1;
                  final team = entry.value;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _TeamRankingCard(team: team, position: position),
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
                      child: _MatchHistoryCard(
                        match: match,
                        onTap: () => _openMatch(match),
                      ),
                    );
                  }),
                if (progress.status == 'in_progress') ...[
                  const SizedBox(height: 8),
                  _FinishEventButton(
                    isLoading: viewModel.isFinishing,
                    onTap: viewModel.isFinishing
                        ? null
                        : () => _confirmFinishEvent(progress),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  List<EventTeamProgressEntity> _rankedTeams(
    List<EventTeamProgressEntity> teams,
  ) {
    final orderedTeams = [...teams];

    orderedTeams.sort((first, second) {
      final winsComparison = second.wins.compareTo(first.wins);

      if (winsComparison != 0) {
        return winsComparison;
      }

      final matchesComparison = first.matchesPlayed.compareTo(
        second.matchesPlayed,
      );

      if (matchesComparison != 0) {
        return matchesComparison;
      }

      return first.name.toLowerCase().compareTo(second.name.toLowerCase());
    });

    return orderedTeams;
  }
}

class _EditEventNameDialog extends StatefulWidget {
  const _EditEventNameDialog({required this.initialName});

  final String initialName;

  @override
  State<_EditEventNameDialog> createState() => _EditEventNameDialogState();
}

class _EditEventNameDialogState extends State<_EditEventNameDialog> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar nome do evento'),
      content: TextField(
        controller: controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(hintText: 'Nome do evento'),
        onSubmitted: (value) {
          Navigator.of(context).pop(value.trim());
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(controller.text.trim());
          },
          child: const Text('Salvar'),
        ),
      ],
    );
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
  const _EventSummary({
    required this.progress,
    required this.isRenaming,
    required this.isDeleting,
    required this.onEditName,
    required this.onDelete,
  });

  final EventProgressEntity progress;
  final bool isRenaming;
  final bool isDeleting;
  final VoidCallback onEditName;
  final VoidCallback onDelete;

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
          Row(
            children: [
              Expanded(
                child: Text(
                  progress.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _EventHeaderActionButton(
                icon: Icons.edit_outlined,
                isLoading: isRenaming,
                onTap: isRenaming || isDeleting ? null : onEditName,
              ),
              const SizedBox(width: 8),
              _EventHeaderActionButton(
                icon: Icons.delete_outline_rounded,
                isLoading: isDeleting,
                onTap: isRenaming || isDeleting ? null : onDelete,
              ),
            ],
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

class _EventHeaderActionButton extends StatelessWidget {
  const _EventHeaderActionButton({
    required this.icon,
    required this.isLoading,
    required this.onTap,
  });

  final IconData icon;
  final bool isLoading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Ink(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
          ),
          child: isLoading
              ? const Padding(
                  padding: EdgeInsets.all(11),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Icon(icon, color: Colors.white, size: 20),
        ),
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

class _TeamRankingCard extends StatelessWidget {
  const _TeamRankingCard({required this.team, required this.position});

  final EventTeamProgressEntity team;
  final int position;

  @override
  Widget build(BuildContext context) {
    final isLeader = position == 1;
    final rankColor = isLeader ? AppColors.success : AppColors.primary;
    final rankBackground = isLeader
        ? AppColors.successBackground
        : AppColors.primary.withValues(alpha: 0.10);

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
              color: rankBackground,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$position',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: rankColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
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
              color: rankBackground,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isLeader
                      ? Icons.emoji_events_outlined
                      : Icons.leaderboard_outlined,
                  color: rankColor,
                  size: 16,
                ),
                const SizedBox(width: 5),
                Text(
                  '${team.wins}V',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: rankColor,
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

class _MatchHistoryCard extends StatelessWidget {
  const _MatchHistoryCard({required this.match, required this.onTap});

  final EventMatchProgressEntity match;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isActive = match.status == 'in_progress';
    final statusColor = isActive ? AppColors.success : AppColors.textMuted;
    final statusBackground = isActive
        ? AppColors.successBackground
        : AppColors.surfaceMuted;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
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
                  const SizedBox(width: 8),
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.visibility_outlined,
                      color: AppColors.primary,
                      size: 16,
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
        ),
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
