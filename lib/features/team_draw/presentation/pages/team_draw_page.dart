import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:volley_match/core/theme/app_colors.dart';

import '../../../../shared/widgets/feature_nav_bar.dart';
import '../../../players/presentation/widgets/players_position_filters.dart';
import '../viewmodels/team_draw_viewmodel.dart';
import '../widgets/selectable_player_card.dart';
import '../widgets/team_draw_states.dart';
import 'team_configuration_page.dart';

class TeamDrawPage extends StatefulWidget {
  const TeamDrawPage({super.key});

  @override
  State<TeamDrawPage> createState() => _TeamDrawPageState();
}

class _TeamDrawPageState extends State<TeamDrawPage> {
  late final TeamDrawViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = TeamDrawViewModel();
    viewModel.loadPlayers();
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  Future<void> _openTeamConfiguration() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TeamConfigurationPage(
          players: viewModel.selectedPlayers,
          playersPerTeamOptions: viewModel.playersPerTeamOptions,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FeatureNavBar(
      indiceAtual: 2,
      appBar: AppBar(title: const Text('Sorteio de times')),
      body: ChangeNotifierProvider<TeamDrawViewModel>.value(
        value: viewModel,
        child: Consumer<TeamDrawViewModel>(
          builder: (context, viewModel, _) {
            return Padding(
            padding: const EdgeInsets.fromLTRB(20, 2, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${viewModel.selectedPlayersCount} / ${viewModel.totalPlayersCount} selecionados',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: AppColors.textSubtle),
                ),
                if (!viewModel.isSelectionValid &&
                    viewModel.selectionValidationMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    viewModel.selectionValidationMessage!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.danger,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                TextField(
                  onChanged: viewModel.updateSearchQuery,
                  decoration: const InputDecoration(
                    hintText: 'Buscar jogador...',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 16),
                PlayersPositionFilters(
                  positions: viewModel.positions,
                  selectedPosition: viewModel.selectedPosition,
                  onSelected: viewModel.selectPosition,
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: viewModel.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : viewModel.errorMessage != null
                      ? TeamDrawErrorState(message: viewModel.errorMessage!)
                      : viewModel.players.isEmpty
                      ? const EmptyPlayersState()
                      : ListView.builder(
                          itemCount: viewModel.players.length,
                          itemBuilder: (context, index) {
                            final player = viewModel.players[index];

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: SelectablePlayerCard(
                                player: player,
                                isSelected: viewModel.isPlayerSelected(player.id),
                                onTap: () {
                                  viewModel.togglePlayerSelection(player.id);
                                },
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: viewModel.canDrawTeams
                        ? _openTeamConfiguration
                        : null,
                    icon: const Icon(Icons.arrow_forward_outlined),
                    label: const Text('Definir jogadores por time'),
                  ),
                ),
              ],
            ),
          );
          },
        ),
      ),
    );
  }
}
