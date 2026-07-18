import 'dart:math';

import 'package:flutter/material.dart';
import 'package:volley_match/core/theme/app_colors.dart';

import '../../../event/presentation/pages/event_configuration_page.dart';
import '../../../players/domain/entities/player_entity.dart';
import '../../data/repositories/team_draw_repository_impl.dart';
import '../../domain/entities/drawn_team_entity.dart';
import '../../domain/repositories/team_draw_repository.dart';
import '../../domain/usecases/generate_balanced_teams_usecase.dart';
import '../../domain/usecases/save_draw_teams_usecase.dart';
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
  final Random _random = Random();
  final GenerateBalancedTeamsUseCase _generateBalancedTeamsUseCase =
      GenerateBalancedTeamsUseCase();
  final TeamDrawRepository _teamDrawRepository = TeamDrawRepositoryImpl();
  late final SaveDrawTeamsUseCase _saveDrawTeamsUseCase;
  late List<DrawnTeamEntity> drawnTeams;
  int? eventId;
  bool isPersisting = false;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _saveDrawTeamsUseCase = SaveDrawTeamsUseCase(_teamDrawRepository);
    drawnTeams = _buildDrawnTeams();
    Future.microtask(_persistCurrentDraw);
  }

  List<List<PlayerEntity>> _generateBalancedTeams() {
    return _generateBalancedTeamsUseCase(
      players: widget.players,
      teamsCount: widget.teamsCount,
      playersPerTeam: widget.playersPerTeam,
      random: _random,
    );
  }

  List<DrawnTeamEntity> _buildDrawnTeams({List<String>? preservedNames}) {
    final generatedTeams = _generateBalancedTeams();

    return List.generate(generatedTeams.length, (index) {
      final name = preservedNames != null && index < preservedNames.length
          ? preservedNames[index]
          : 'Time ${String.fromCharCode(65 + index)}';

      return DrawnTeamEntity(name: name, players: generatedTeams[index]);
    });
  }

  bool get canStartMatch {
    return !isPersisting &&
        eventId != null &&
        drawnTeams.every((team) => team.id != null);
  }

  void _regenerateDraw() {
    final preservedNames = drawnTeams.map((team) => team.name).toList();

    setState(() {
      drawnTeams = _buildDrawnTeams(preservedNames: preservedNames);
    });

    _persistCurrentDraw();
  }

  Future<void> _editTeamName(int teamIndex) async {
    final team = drawnTeams[teamIndex];

    final updatedName = await showDialog<String>(
      context: context,
      builder: (dialogContext) => _EditTeamNameDialog(initialName: team.name),
    );

    if (updatedName == null || updatedName.isEmpty) {
      return;
    }

    setState(() {
      drawnTeams[teamIndex] = team.copyWith(name: updatedName);
    });

    if (team.id == null) {
      await _persistCurrentDraw();
      return;
    }

    try {
      await _teamDrawRepository.updateTeamName(
        teamId: team.id!,
        name: updatedName,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nao foi possivel salvar o nome do time.'),
        ),
      );
    }
  }

  Future<void> _persistCurrentDraw() async {
    if (mounted) {
      setState(() {
        isPersisting = true;
      });
    }

    try {
      final result = await _saveDrawTeamsUseCase(
        teams: drawnTeams,
        eventId: eventId,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        eventId = result.eventId;
        drawnTeams = result.teams;
        isPersisting = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        isPersisting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nao foi possivel salvar o sorteio.')),
      );
    }
  }

  Future<void> _openEventConfiguration() async {
    if (!canStartMatch) {
      await _persistCurrentDraw();
    }

    if (!mounted || eventId == null) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            EventConfigurationPage(eventId: eventId!, teams: drawnTeams),
      ),
    );
  }

  List<_TeamResultItem> get filteredTeams {
    final allTeams = List.generate(
      drawnTeams.length,
      (index) => _TeamResultItem(
        index: index,
        title: drawnTeams[index].name,
        players: drawnTeams[index].players,
      ),
    );

    if (searchQuery.trim().isEmpty) {
      return allTeams;
    }

    final normalizedQuery = searchQuery.trim().toLowerCase();

    return allTeams
        .where((team) => team.title.toLowerCase().contains(normalizedQuery))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Times')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 2, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.players.length} jogadores selecionados',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
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
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
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
                onPressed: isPersisting ? null : _openEventConfiguration,
                child: const Text('Iniciar partida'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: isPersisting ? null : _regenerateDraw,
                child: const Text('Refazer sorteio'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamResultItem {
  const _TeamResultItem({
    required this.index,
    required this.title,
    required this.players,
  });

  final int index;
  final String title;
  final List<PlayerEntity> players;
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
