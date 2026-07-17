import 'dart:math';

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

  Future<void> _openTeamConfiguration() async {
    final selectedPlayers = viewModel.selectedPlayers;
    final playersPerTeamOptions = viewModel.playersPerTeamOptions;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TeamConfigurationPage(
          players: selectedPlayers,
          playersPerTeamOptions: playersPerTeamOptions,
        ),
      ),
    );
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
    );
  }
}

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
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
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
                    '${widget.players.length} jogadores validos para o sorteio',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Escolha quantos jogadores cada time tera. A quantidade de times sera calculada automaticamente.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Opcoes permitidas: de 2 a 6 jogadores por time.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Jogadores por time',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: widget.playersPerTeamOptions.map((teamSize) {
                final isSelected = teamSize == selectedPlayersPerTeam;

                return ChoiceChip(
                  label: Text('$teamSize por time'),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      selectedPlayersPerTeam = teamSize;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Text(
                '${widget.players.length} jogadores selecionados -> $teamsCount times de $selectedPlayersPerTeam jogadores',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
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
                    child: _SelectedPlayerPreviewCard(player: player),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
  late List<List<PlayerEntity>> teams;

  @override
  void initState() {
    super.initState();
    teams = _generateBalancedTeams();
  }

  List<List<PlayerEntity>> _generateBalancedTeams() {
    final shuffledPlayers = [...widget.players]..shuffle(_random);
    shuffledPlayers.sort(
      (left, right) => right.skillRating.compareTo(left.skillRating),
    );

    final generatedTeams = List.generate(
      widget.teamsCount,
      (_) => <PlayerEntity>[],
    );

    var playerIndex = 0;
    final startsForward = _random.nextBool();

    for (var round = 0; round < widget.playersPerTeam; round++) {
      final movesForward = round.isEven ? startsForward : !startsForward;
      final teamIndexes = movesForward
          ? List.generate(widget.teamsCount, (index) => index)
          : List.generate(
              widget.teamsCount,
              (index) => widget.teamsCount - 1 - index,
            );

      for (final teamIndex in teamIndexes) {
        generatedTeams[teamIndex].add(shuffledPlayers[playerIndex]);
        playerIndex += 1;
      }
    }

    return generatedTeams;
  }

  void _regenerateDraw() {
    setState(() {
      teams = _generateBalancedTeams();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resultado do sorteio')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Times',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.players.length} jogadores selecionados',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.textSubtle),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: teams.length,
                itemBuilder: (context, index) {
                  final team = teams[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _GeneratedTeamCard(
                      title: 'Time ${String.fromCharCode(65 + index)}',
                      players: team,
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

class _GeneratedTeamCard extends StatelessWidget {
  const _GeneratedTeamCard({
    required this.title,
    required this.players,
  });

  final String title;
  final List<PlayerEntity> players;

  double get averageSkillRating {
    if (players.isEmpty) {
      return 0;
    }

    final totalSkillRating = players.fold(
      0,
      (total, player) => total + player.skillRating,
    );

    return totalSkillRating / players.length;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Media ${averageSkillRating.toStringAsFixed(1)}',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 2),
            child: Column(
              children: players
                  .map(
                    (player) => Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: _GeneratedTeamPlayerRow(player: player),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _GeneratedTeamPlayerRow extends StatelessWidget {
  const _GeneratedTeamPlayerRow({required this.player});

  final PlayerEntity player;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _avatarColorForPlayer(player.id),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            _initialsFromName(player.name),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                player.name,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                player.position,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Row(
          children: List.generate(
            10,
            (index) => Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Container(
                width: 8,
                height: 8,
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
    );
  }

  String _initialsFromName(String name) {
    final parts = name
        .trim()
        .split(' ')
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return '?';
    }

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  Color _avatarColorForPlayer(int playerId) {
    const colors = [
      Color(0xFF2563EB),
      Color(0xFF10B981),
      Color(0xFFF97316),
      Color(0xFF8B5CF6),
      Color(0xFFEF4444),
      Color(0xFF06B6D4),
    ];

    return colors[playerId % colors.length];
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
            'Jogadores presentes',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            '${viewModel.selectedPlayersCount} / ${viewModel.totalPlayersCount} jogador(es) selecionado(s)',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 8),
          Text(
            viewModel.selectionValidationMessage ??
                'Selecao valida para definir jogadores por time.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: viewModel.isSelectionValid
                  ? AppColors.success
                  : AppColors.danger,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Regras: minimo de 4 jogadores selecionados e times com 2 a 6 jogadores.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSubtle),
          ),
        ],
      ),
    );
  }
}

class _SelectedPlayerPreviewCard extends StatelessWidget {
  const _SelectedPlayerPreviewCard({required this.player});

  final PlayerEntity player;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'Nota ${player.skillRating}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
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
