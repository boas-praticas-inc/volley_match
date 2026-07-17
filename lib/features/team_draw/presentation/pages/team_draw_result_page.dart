import 'dart:math';

import 'package:flutter/material.dart';
import 'package:volley_match/core/theme/app_colors.dart';

import '../../../players/domain/entities/player_entity.dart';
import '../../domain/usecases/generate_balanced_teams_usecase.dart';
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
  late List<List<PlayerEntity>> teams;
  late List<String> teamNames;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    teams = _generateBalancedTeams();
    teamNames = List.generate(
      widget.teamsCount,
      (index) => 'Time ${String.fromCharCode(65 + index)}',
    );
  }

  List<List<PlayerEntity>> _generateBalancedTeams() {
    return _generateBalancedTeamsUseCase(
      players: widget.players,
      teamsCount: widget.teamsCount,
      playersPerTeam: widget.playersPerTeam,
      random: _random,
    );
  }

  void _regenerateDraw() {
    setState(() {
      teams = _generateBalancedTeams();
    });
  }

  Future<void> _editTeamName(int teamIndex) async {
    final controller = TextEditingController(text: teamNames[teamIndex]);

    final updatedName = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Editar nome do time'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Nome do time'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(controller.text.trim());
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (updatedName == null || updatedName.isEmpty) {
      return;
    }

    setState(() {
      teamNames[teamIndex] = updatedName;
    });
  }

  List<_TeamResultItem> get filteredTeams {
    final allTeams = List.generate(
      teams.length,
      (index) => _TeamResultItem(
        index: index,
        title: teamNames[index],
        players: teams[index],
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
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fluxo de partida ainda nao implementado.'),
                    ),
                  );
                },
                child: const Text('Iniciar partida'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _regenerateDraw,
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
