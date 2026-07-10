import 'package:flutter/material.dart';

import '../../../../shared/widgets/feature_navBar.dart';
import '../../../../shared/widgets/feature_placeholder_section.dart';
import '../viewmodels/players_viewmodel.dart';

class PlayersPage extends StatelessWidget {
  const PlayersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = PlayersViewModel();

    return FeatureNavBar(
      indiceAtual: 1,
      appBar: AppBar(title: const Text('Jogadores')),
      body: FeaturePlaceholderSection(
        title: 'Feature: Jogadores',
        description:
            'Base inicial pronta para o cadastro e manutenção da base de jogadores.',
        items: viewModel.responsibilities,
      ),
    );
  }
}
