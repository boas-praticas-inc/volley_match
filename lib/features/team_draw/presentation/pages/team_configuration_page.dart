import 'package:flutter/material.dart';
import 'package:volley_match/core/theme/app_colors.dart';

import '../../../players/domain/entities/player_entity.dart';
import '../widgets/selected_player_preview_card.dart';
import 'team_draw_result_page.dart';

class TeamConfigurationPage extends StatefulWidget {
  const TeamConfigurationPage({
    super.key,
    required this.players,
    required this.playersPerTeamOptions,
  });

  final List<PlayerEntity> players;
  final List<int> playersPerTeamOptions;

  @override
  State<TeamConfigurationPage> createState() => _TeamConfigurationPageState();
}

class _TeamConfigurationPageState extends State<TeamConfigurationPage> {
  late int selectedPlayersPerTeam;

  @override
  void initState() {
    super.initState();
    selectedPlayersPerTeam = widget.playersPerTeamOptions.first;
  }

  int get teamsCount => widget.players.length ~/ selectedPlayersPerTeam;

  Future<void> _openDrawResult() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TeamDrawResultPage(
          players: widget.players,
          teamsCount: teamsCount,
          playersPerTeam: selectedPlayersPerTeam,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuracao dos times')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 2, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.players.length} jogadores escolhidos',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$teamsCount times de $selectedPlayersPerTeam jogadores',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: widget.playersPerTeamOptions.map((teamSize) {
                  final isSelected = teamSize == selectedPlayersPerTeam;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text('$teamSize por time'),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() {
                          selectedPlayersPerTeam = teamSize;
                        });
                      },
                      showCheckmark: false,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                      backgroundColor: AppColors.surfaceMuted,
                      selectedColor: AppColors.primary,
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Jogadores selecionados',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: widget.players.length,
                itemBuilder: (context, index) {
                  final player = widget.players[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SelectedPlayerPreviewCard(player: player),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _openDrawResult,
                icon: const Icon(Icons.casino_outlined),
                label: const Text('Gerar sorteio'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
