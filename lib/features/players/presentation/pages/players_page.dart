import 'package:flutter/material.dart';

import '../../../../shared/widgets/feature_placeholder_section.dart';
import '../viewmodels/players_viewmodel.dart';

class PlayersPage extends StatelessWidget {
  const PlayersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = PlayersViewModel();

    return Scaffold(
      appBar: AppBar(title: const Text('Jogadores')),
      body: FeaturePlaceholderSection(
        title: 'Feature: Jogadores',
        description:
            'Base inicial pronta para o cadastro e manutencao da base de atletas.',
        items: viewModel.responsibilities,
      ),
    );
  }
}
