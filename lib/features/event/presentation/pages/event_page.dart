import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:volley_match/core/theme/app_colors.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/feature_nav_bar.dart';
import '../../../../shared/widgets/team_players_sheet.dart';
import '../../../scoreboard/presentation/pages/scoreboard_page.dart';
import '../../domain/entities/event_progress_entity.dart';
import '../viewmodels/event_viewmodel.dart';
import '../widgets/current_match_card.dart';
import '../widgets/edit_event_name_dialog.dart';
import '../widgets/empty_event_state.dart';
import '../widgets/event_section_title.dart';
import '../widgets/event_summary.dart';
import '../widgets/finish_event_button.dart';
import '../widgets/match_history_card.dart';
import '../widgets/team_ranking_card.dart';

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

  void _showTeamPlayers(EventTeamProgressEntity team) {
    showTeamPlayersSheet(
      context: context,
      teamName: team.name,
      players: team.players.map(_playerViewDataFromEvent).toList(),
      accentColor: team.isPlaying ? AppColors.success : AppColors.primary,
    );
  }

  TeamPlayerViewData _playerViewDataFromEvent(EventTeamPlayerEntity player) {
    return TeamPlayerViewData(
      name: player.name,
      position: player.position,
      rotationOrder: player.rotationOrder,
      photoPath: player.photoPath,
    );
  }

  Future<void> _editEventName(EventProgressEntity progress) async {
    final updatedName = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return EditEventNameDialog(initialName: progress.name);
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
              : 'Não foi possível atualizar o nome do evento.',
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
              : 'Não foi possível finalizar o evento.',
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
            'O evento "${progress.name}" será removido junto com seus times, partidas e sets.',
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
          deleted ? 'Evento excluído.' : 'Não foi possível excluir o evento.',
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
      body: ChangeNotifierProvider<EventViewModel>.value(
        value: viewModel,
        child: Consumer<EventViewModel>(
          builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final progress = viewModel.eventProgress;

          if (progress == null) {
            return EmptyEventState(
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
                EventSummary(
                  progress: progress,
                  isRenaming: viewModel.isRenaming,
                  isDeleting: viewModel.isDeleting,
                  onEditName: () => _editEventName(progress),
                  onDelete: () => _confirmDeleteEvent(progress),
                ),
                const SizedBox(height: 16),
                CurrentMatchCard(
                  match: progress.currentMatch,
                  homeTeam: _teamById(
                    progress.teams,
                    progress.currentMatch?.homeTeamId,
                  ),
                  awayTeam: _teamById(
                    progress.teams,
                    progress.currentMatch?.awayTeamId,
                  ),
                  onTeamTap: _showTeamPlayers,
                ),
                const SizedBox(height: 18),
                EventSectionTitle(
                  title: 'Ranking dos times',
                  subtitle: '${progress.totalTeams} times',
                ),
                const SizedBox(height: 12),
                ..._rankedTeams(progress.teams).asMap().entries.map((entry) {
                  final position = entry.key + 1;
                  final team = entry.value;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TeamRankingCard(
                      team: team,
                      position: position,
                      onTap: () => _showTeamPlayers(team),
                    ),
                  );
                }),
                const SizedBox(height: 6),
                EventSectionTitle(
                  title: 'Histórico de partidas',
                  subtitle: '${progress.finishedMatches} finalizadas',
                ),
                const SizedBox(height: 12),
                if (progress.matches.isEmpty)
                  const EmptyHistoryCard()
                else
                  ...progress.matches.reversed.map((match) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: MatchHistoryCard(
                        match: match,
                        onTap: () => _openMatch(match),
                      ),
                    );
                  }),
                if (progress.status == 'in_progress') ...[
                  const SizedBox(height: 8),
                  FinishEventButton(
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

  EventTeamProgressEntity? _teamById(
    List<EventTeamProgressEntity> teams,
    int? teamId,
  ) {
    if (teamId == null) {
      return null;
    }

    for (final team in teams) {
      if (team.id == teamId) {
        return team;
      }
    }

    return null;
  }
}
