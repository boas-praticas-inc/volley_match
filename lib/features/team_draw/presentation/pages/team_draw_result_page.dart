import 'package:flutter/material.dart';
import 'package:volley_match/core/theme/app_colors.dart';

import '../../../event/presentation/pages/event_configuration_page.dart';
import '../../../players/domain/entities/player_entity.dart';
import '../viewmodels/team_draw_result_viewmodel.dart';
import '../widgets/generated_team_card.dart';
import '../widgets/team_draw_states.dart';

class TeamDrawResultPage extends StatefulWidget {
  const TeamDrawResultPage({
    super.key,
    required this.players,
    required this.teamsCount,
    required this.playersPerTeam,
  });

  final List<PlayerEntity> players;
  final int teamsCount;
  final int playersPerTeam;

  @override
  State<TeamDrawResultPage> createState() => _TeamDrawResultPageState();
}

class _TeamDrawResultPageState extends State<TeamDrawResultPage> {
  late final TeamDrawResultViewModel viewModel;
  String? _lastDisplayedErrorMessage;

  @override
  void initState() {
    super.initState();
    viewModel = TeamDrawResultViewModel(
      players: widget.players,
      teamsCount: widget.teamsCount,
      playersPerTeam: widget.playersPerTeam,
    );
    viewModel.addListener(_showErrorMessage);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      viewModel.initialize();
    });
  }

  @override
  void dispose() {
    viewModel.removeListener(_showErrorMessage);
    viewModel.dispose();
    super.dispose();
  }

  Future<void> _editTeamName(int teamIndex) async {
    final team = viewModel.drawnTeams[teamIndex];

    final updatedName = await showDialog<String>(
      context: context,
      builder: (dialogContext) => _EditTeamNameDialog(initialName: team.name),
    );

    if (updatedName == null || updatedName.trim().isEmpty) {
      return;
    }

    await viewModel.updateTeamName(teamIndex: teamIndex, name: updatedName);
  }

  void _showErrorMessage() {
    final message = viewModel.errorMessage;

    if (message == null || message == _lastDisplayedErrorMessage) {
      return;
    }

    _lastDisplayedErrorMessage = message;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || viewModel.errorMessage != message) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      _lastDisplayedErrorMessage = null;
      viewModel.clearErrorMessage();
    });
  }

  Future<void> _openEventConfiguration() async {
    await viewModel.ensureCurrentDrawPersisted();

    if (!mounted || viewModel.eventId == null) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EventConfigurationPage(
          eventId: viewModel.eventId!,
          teams: viewModel.drawnTeams,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) {
        final filteredTeams = viewModel.filteredTeams;

        return Scaffold(
          appBar: AppBar(title: const Text('Times')),
          body: Padding(
            padding: const EdgeInsets.fromLTRB(20, 2, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.players.length} jogadores selecionados',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${widget.teamsCount} times de ${widget.playersPerTeam} jogadores',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  onChanged: viewModel.updateSearchQuery,
                  decoration: const InputDecoration(
                    hintText: 'Buscar time...',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: filteredTeams.isEmpty
                      ? const EmptyTeamsSearchState()
                      : ListView.builder(
                          itemCount: filteredTeams.length,
                          itemBuilder: (context, index) {
                            final team = filteredTeams[index];

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: GeneratedTeamCard(
                                onEditName: () => _editTeamName(team.index),
                                title: team.title,
                                players: team.players,
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: viewModel.isPersisting
                        ? null
                        : _openEventConfiguration,
                    child: const Text('Iniciar partida'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: viewModel.isPersisting
                        ? null
                        : viewModel.regenerateDraw,
                    child: const Text('Refazer sorteio'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EditTeamNameDialog extends StatefulWidget {
  const _EditTeamNameDialog({required this.initialName});

  final String initialName;

  @override
  State<_EditTeamNameDialog> createState() => _EditTeamNameDialogState();
}

class _EditTeamNameDialogState extends State<_EditTeamNameDialog> {
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
      title: const Text('Editar nome do time'),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(hintText: 'Nome do time'),
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
