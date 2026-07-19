import 'package:flutter/material.dart';
import 'package:volley_match/core/theme/app_colors.dart';

import '../../../scoreboard/presentation/pages/scoreboard_page.dart';
import '../../../team_draw/domain/entities/drawn_team_entity.dart';
import '../viewmodels/event_configuration_viewmodel.dart';
import '../widgets/event_config_choice_chip.dart';
import '../widgets/event_configuration_section.dart';
import '../widgets/event_summary_card.dart';
import '../widgets/starting_team_card.dart';

class EventConfigurationPage extends StatefulWidget {
  const EventConfigurationPage({
    super.key,
    required this.eventId,
    required this.teams,
  });

  final int eventId;
  final List<DrawnTeamEntity> teams;

  @override
  State<EventConfigurationPage> createState() => _EventConfigurationPageState();
}

class _EventConfigurationPageState extends State<EventConfigurationPage> {
  late final EventConfigurationViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = EventConfigurationViewModel(
      eventId: widget.eventId,
      teams: widget.teams,
    );
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  Future<void> _startEvent() async {
    final matchId = await viewModel.startEvent();

    if (!mounted) {
      return;
    }

    if (matchId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            viewModel.errorMessage ?? 'Não foi possível iniciar o evento.',
          ),
        ),
      );
      viewModel.clearErrorMessage();
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Primeira partida criada.')));

    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => ScoreboardPage(matchId: matchId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Configurar evento')),
          body: Padding(
            padding: const EdgeInsets.fromLTRB(20, 2, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${viewModel.teams.length} times sorteados',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  viewModel.eventRuleMessage,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '${viewModel.selectedTeamsCount} / 2 times para comecar',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView(
                    children: [
                      ...viewModel.teams.map((team) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: StartingTeamCard(
                            team: team,
                            isSelected: viewModel.isTeamSelected(team),
                            selectedOrder: viewModel.selectedOrderForTeam(team),
                            onTap: () => viewModel.toggleStartingTeam(team),
                          ),
                        );
                      }),
                      const SizedBox(height: 8),
                      EventConfigurationSection(
                        title: 'Sets por partida',
                        children: EventConfigurationViewModel.bestOfSetsOptions
                            .map((sets) {
                              return EventConfigChoiceChip(
                                label: 'Melhor de $sets',
                                isSelected:
                                    viewModel.selectedBestOfSets == sets,
                                onSelected: () {
                                  viewModel.selectBestOfSets(sets);
                                },
                              );
                            })
                            .toList(),
                      ),
                      const SizedBox(height: 18),
                      EventConfigurationSection(
                        title: 'Pontos por set',
                        children: EventConfigurationViewModel
                            .pointsPerSetOptions
                            .map((points) {
                              return EventConfigChoiceChip(
                                label: '$points pontos',
                                isSelected:
                                    viewModel.selectedPointsPerSet == points,
                                onSelected: () {
                                  viewModel.selectPointsPerSet(points);
                                },
                              );
                            })
                            .toList(),
                      ),
                      const SizedBox(height: 18),
                      EventSummaryCard(
                        selectedBestOfSets: viewModel.selectedBestOfSets,
                        setsToWin: viewModel.setsToWin,
                        pointsPerSet: viewModel.selectedPointsPerSet,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: viewModel.canStartEvent ? _startEvent : null,
                    icon: viewModel.isStarting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.sports_volleyball_outlined),
                    label: const Text('Iniciar primeira partida'),
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
