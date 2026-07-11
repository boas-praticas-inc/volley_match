import 'package:flutter/material.dart';
import 'package:volley_match/core/theme/app_colors.dart';

import '../../../../shared/widgets/feature_navBar.dart';
import '../viewmodels/players_viewmodel.dart';
import '../widgets/player_list_item.dart';
import '../widgets/players_position_filters.dart';

class PlayersPage extends StatelessWidget {
  const PlayersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = PlayersViewModel();

    return FeatureNavBar(
      indiceAtual: 1,
      appBar: AppBar(title: const Text('Jogadores')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 2, 20, 20),
        children: [
          Text(
            '${viewModel.players.length} cadastrados',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.textSubtle),
          ),
          const SizedBox(height: 20),
          const TextField(
            decoration: InputDecoration(
              hintText: 'Buscar jogador...',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 16),
          const PlayersPositionFilters(),
          const SizedBox(height: 20),
          ...viewModel.players.map(
            (player) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: PlayerListItem(player: player),
            ),
          ),
        ],
      ),
    );
  }
}
