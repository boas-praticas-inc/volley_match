import 'package:flutter/material.dart';
import 'package:volley_match/core/theme/app_colors.dart';

import '../../../scoreboard/presentation/pages/scoreboard_page.dart';
import '../../../team_draw/domain/entities/drawn_team_entity.dart';
import '../../data/repositories/event_repository_impl.dart';
import '../../domain/entities/event_match_configuration_entity.dart';
import '../../domain/repositories/event_repository.dart';
import '../../domain/usecases/start_event_match_usecase.dart';

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
  final EventRepository _eventRepository = EventRepositoryImpl();
  late final StartEventMatchUseCase _startEventMatchUseCase;
  late final List<int> selectedTeamIds;
  int selectedBestOfSets = 3;
  int selectedPointsPerSet = 25;
  bool isStarting = false;

  static const bestOfSetsOptions = [1, 3, 5];
  static const pointsPerSetOptions = [15, 21, 25];

  @override
  void initState() {
    super.initState();
    _startEventMatchUseCase = StartEventMatchUseCase(_eventRepository);
    selectedTeamIds = widget.teams
        .where((team) => team.id != null)
        .take(2)
        .map((team) => team.id!)
        .toList();
  }

  int get setsToWin => (selectedBestOfSets ~/ 2) + 1;

  bool get canStartEvent {
    return selectedTeamIds.length == 2 && !isStarting;
  }

  String get eventRuleMessage {
    if (widget.teams.length == 2) {
      return 'Com 2 times, eles permanecem jogando durante o evento.';
    }

    return 'Vencedor permanece em quadra, perdedor sai e o próximo time entra.';
  }

  void _toggleStartingTeam(DrawnTeamEntity team) {
    final teamId = team.id;

    if (teamId == null) {
      return;
    }

    setState(() {
      if (selectedTeamIds.contains(teamId)) {
        selectedTeamIds.remove(teamId);
        return;
      }

      if (selectedTeamIds.length == 2) {
        selectedTeamIds.removeAt(0);
      }

      selectedTeamIds.add(teamId);
    });
  }

  Future<void> _startEvent() async {
    if (!canStartEvent) {
      return;
    }

    setState(() {
      isStarting = true;
    });

    try {
      final matchId = await _startEventMatchUseCase(
        EventMatchConfigurationEntity(
          eventId: widget.eventId,
          homeTeamId: selectedTeamIds[0],
          awayTeamId: selectedTeamIds[1],
          bestOfSets: selectedBestOfSets,
          setsToWin: setsToWin,
          pointsPerSet: selectedPointsPerSet,
        ),
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Primeira partida criada.')));

      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => ScoreboardPage(matchId: matchId)),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        isStarting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível iniciar o evento.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurar evento')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 2, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.teams.length} times sorteados',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              eventRuleMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '${selectedTeamIds.length} / 2 times para comecar',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  ...widget.teams.map((team) {
                    final teamId = team.id;
                    final isSelected =
                        teamId != null && selectedTeamIds.contains(teamId);
                    final selectedOrder = isSelected
                        ? selectedTeamIds.indexOf(teamId) + 1
                        : null;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _StartingTeamCard(
                        team: team,
                        isSelected: isSelected,
                        selectedOrder: selectedOrder,
                        onTap: () => _toggleStartingTeam(team),
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  _ConfigurationSection(
                    title: 'Sets por partida',
                    children: bestOfSetsOptions.map((sets) {
                      return _ConfigChoiceChip(
                        label: 'Melhor de $sets',
                        isSelected: selectedBestOfSets == sets,
                        onSelected: () {
                          setState(() {
                            selectedBestOfSets = sets;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),
                  _ConfigurationSection(
                    title: 'Pontos por set',
                    children: pointsPerSetOptions.map((points) {
                      return _ConfigChoiceChip(
                        label: '$points pontos',
                        isSelected: selectedPointsPerSet == points,
                        onSelected: () {
                          setState(() {
                            selectedPointsPerSet = points;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),
                  _EventSummaryCard(
                    selectedBestOfSets: selectedBestOfSets,
                    setsToWin: setsToWin,
                    pointsPerSet: selectedPointsPerSet,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: canStartEvent ? _startEvent : null,
                icon: isStarting
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
