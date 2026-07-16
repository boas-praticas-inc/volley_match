import 'package:flutter/material.dart';
import 'package:volley_match/core/theme/app_colors.dart';

import '../../../../shared/widgets/feature_navBar.dart';
import '../../../players/domain/entities/player_entity.dart';
import '../viewmodels/team_draw_viewmodel.dart';

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

  @override
  Widget build(BuildContext context) {
    return FeatureNavBar(
      indiceAtual: 2,
      appBar: AppBar(title: const Text('Sorteio de times')),
      body: AnimatedBuilder(
        animation: viewModel,
        builder: (context, _) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 2, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SelectionSummary(viewModel: viewModel),
                const SizedBox(height: 20),
                Expanded(
                  child: viewModel.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : viewModel.errorMessage != null
                      ? _TeamDrawErrorState(message: viewModel.errorMessage!)
                      : viewModel.players.isEmpty
                      ? const _EmptyPlayersState()
                      : ListView.builder(
                          itemCount: viewModel.players.length,
                          itemBuilder: (context, index) {
                            final player = viewModel.players[index];

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _SelectablePlayerCard(
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
                    onPressed: viewModel.canDrawTeams ? () {} : null,
                    icon: const Icon(Icons.casino_outlined),
                    label: const Text('Sortear times'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SelectionSummary extends StatelessWidget {
  const _SelectionSummary({required this.viewModel});

  final TeamDrawViewModel viewModel;

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
            '${viewModel.selectedPlayersCount} / ${viewModel.totalPlayersCount} jogadore(s) selecionado(s)',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _SelectablePlayerCard extends StatelessWidget {
  const _SelectablePlayerCard({
    required this.player,
    required this.isSelected,
    required this.onTap,
  });

  final PlayerEntity player;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.borderLight,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Checkbox(
                value: isSelected,
                onChanged: (_) => onTap(),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      player.position,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: List.generate(
                        10,
                        (index) => Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: index < player.skillRating
                                  ? AppColors.primary
                                  : AppColors.borderDisabled,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TeamDrawErrorState extends StatelessWidget {
  const _TeamDrawErrorState({required this.message});

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
            'Nenhum jogador cadastrado',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Cadastre jogadores na base antes de montar a lista de presentes.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
