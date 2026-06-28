import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/feature_card.dart';
import '../viewmodels/home_viewmodel.dart';
import '../widgets/home_header.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = HomeViewModel();

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.appName)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const HomeHeader(
            title: AppStrings.appName,
            subtitle: AppStrings.appTagline,
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Base inicial do projeto',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  ...viewModel.highlights.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text('- $item'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          FeatureCard(
            title: 'Jogadores',
            description: 'Cadastro da base de atletas.',
            icon: Icons.group_outlined,
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.players),
          ),
          FeatureCard(
            title: 'Sorteio de times',
            description: 'Balanceamento a partir das notas.',
            icon: Icons.shuffle_outlined,
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.teamDraw),
          ),
          FeatureCard(
            title: 'Placar',
            description: 'Pontos, sets e historico.',
            icon: Icons.scoreboard_outlined,
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.scoreboard),
          ),
          FeatureCard(
            title: 'Rotacoes',
            description: 'Guia visual para 6x0 e 5x1.',
            icon: Icons.sports_volleyball_outlined,
            onTap: () =>
                Navigator.of(context).pushNamed(AppRoutes.rotationGuide),
          ),
          FeatureCard(
            title: 'Eventos',
            description: 'Agrupamento das partidas do dia.',
            icon: Icons.event_outlined,
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.events),
          ),
          FeatureCard(
            title: 'Partidas',
            description: 'Historico de confrontos e resultados.',
            icon: Icons.emoji_events_outlined,
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.matches),
          ),
        ],
      ),
    );
  }
}
