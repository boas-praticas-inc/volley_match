import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:volley_match/core/theme/app_colors.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/feature_nav_bar.dart';
import '../../domain/entities/player_entity.dart';
import 'edit_player_page.dart';
import '../viewmodels/players_viewmodel.dart';
import '../widgets/player_list_item.dart';
import '../widgets/players_position_filters.dart';

class PlayersPage extends StatefulWidget {
  const PlayersPage({super.key});

  @override
  State<PlayersPage> createState() => _PlayersPageState();
}

class _PlayersPageState extends State<PlayersPage> {
  late final PlayersViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = PlayersViewModel();
    viewModel.loadPlayers();
  }

  Future<void> _openAddPlayerPage() async {
    final newPlayer = await Navigator.of(context).pushNamed(
      AppRoutes.addPlayer,
      arguments: viewModel.nextPlayerId,
    );

    if (newPlayer is PlayerEntity) {
      await viewModel.addPlayer(newPlayer);
    }
  }

  Future<void> _openEditPlayerPage(PlayerEntity player) async {
    final result = await Navigator.of(context).pushNamed(
      AppRoutes.editPlayer,
      arguments: player,
    );

    if (result is EditPlayerResult) {
      if (result.updatedPlayer != null) {
        await viewModel.updatePlayer(result.updatedPlayer!);
      }

      if (result.removedPlayerId != null) {
        await viewModel.removePlayer(result.removedPlayerId!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FeatureNavBar(
      indiceAtual: 1,
      appBar: AppBar(title: const Text('Jogadores')),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddPlayerPage,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: ChangeNotifierProvider<PlayersViewModel>.value(
        value: viewModel,
        child: Consumer<PlayersViewModel>(
          builder: (context, viewModel, _) {
            return Padding(
            padding: const EdgeInsets.fromLTRB(20, 2, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${viewModel.totalPlayersCount} cadastrados',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: AppColors.textSubtle),
                ),
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
                      ? _PlayersErrorState(message: viewModel.errorMessage!)
                      : viewModel.players.isEmpty
                      ? const _EmptyPlayersState()
                      : ListView.builder(
                          itemCount: viewModel.players.length,
                          itemBuilder: (context, index) {
                            final player = viewModel.players[index];

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: PlayerListItem(
                                player: player,
                                onTap: () => _openEditPlayerPage(player),
                              ),
                            );
                          },
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

class _PlayersErrorState extends StatelessWidget {
  const _PlayersErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Erro ao carregar jogadores',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _EmptyPlayersState extends StatelessWidget {
  const _EmptyPlayersState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nenhum jogador encontrado',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Tente ajustar a busca ou o filtro selecionado.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
