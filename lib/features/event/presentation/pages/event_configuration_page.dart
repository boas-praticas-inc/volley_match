import 'package:flutter/material.dart';
import 'package:volley_match/core/theme/app_colors.dart';

import '../../../scoreboard/presentation/pages/scoreboard_page.dart';
import '../../../team_draw/domain/entities/drawn_team_entity.dart';
import '../viewmodels/event_configuration_viewmodel.dart';

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
                          child: _StartingTeamCard(
                            team: team,
                            isSelected: viewModel.isTeamSelected(team),
                            selectedOrder: viewModel.selectedOrderForTeam(team),
                            onTap: () => viewModel.toggleStartingTeam(team),
                          ),
                        );
                      }),
                      const SizedBox(height: 8),
                      _ConfigurationSection(
                        title: 'Sets por partida',
                        children: EventConfigurationViewModel.bestOfSetsOptions
                            .map((sets) {
                              return _ConfigChoiceChip(
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
                      _ConfigurationSection(
                        title: 'Pontos por set',
                        children: EventConfigurationViewModel
                            .pointsPerSetOptions
                            .map((points) {
                              return _ConfigChoiceChip(
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
                      _EventSummaryCard(
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

class _StartingTeamCard extends StatelessWidget {
  const _StartingTeamCard({
    required this.team,
    required this.isSelected,
    required this.selectedOrder,
    required this.onTap,
  });

  final DrawnTeamEntity team;
  final bool isSelected;
  final int? selectedOrder;
  final VoidCallback onTap;

  double get averageSkillRating {
    if (team.players.isEmpty) {
      return 0;
    }

    final totalSkillRating = team.players.fold(
      0,
      (total, player) => total + player.skillRating,
    );

    return totalSkillRating / team.players.length;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.successBackground : AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? AppColors.success : AppColors.borderLight,
            width: isSelected ? 1.6 : 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F101828),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.success : AppColors.surfaceMuted,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isSelected
                    ? Text(
                        '$selectedOrder',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                      )
                    : const Icon(
                        Icons.sports_volleyball_outlined,
                        color: AppColors.textMuted,
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${team.players.length} jogadores | média ${averageSkillRating.toStringAsFixed(1)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.success : AppColors.textSubtle,
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfigurationSection extends StatelessWidget {
  const _ConfigurationSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: children
                .map(
                  (child) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: child,
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _ConfigChoiceChip extends StatelessWidget {
  const _ConfigChoiceChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      showCheckmark: false,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textMuted,
        fontWeight: FontWeight.w700,
      ),
      backgroundColor: AppColors.surfaceMuted,
      selectedColor: AppColors.primary,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    );
  }
}

class _EventSummaryCard extends StatelessWidget {
  const _EventSummaryCard({
    required this.selectedBestOfSets,
    required this.setsToWin,
    required this.pointsPerSet,
  });

  final int selectedBestOfSets;
  final int setsToWin;
  final int pointsPerSet;

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
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: AppColors.surfaceMuted,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.rule_outlined, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Partida em melhor de $selectedBestOfSets sets, vence quem fizer $setsToWin set(s). Cada set vai ate $pointsPerSet pontos.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
