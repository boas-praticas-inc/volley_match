import 'package:flutter/material.dart';
import 'package:volley_match/shared/widgets/feature_navBar.dart';

import '../../../../shared/widgets/feature_navBar.dart';
import '../../../../shared/widgets/feature_placeholder_section.dart';
import '../viewmodels/scoreboard_viewmodel.dart';

class ScoreboardPage extends StatelessWidget {
  const ScoreboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = ScoreboardViewModel();

    return FeatureNavBar(
      indiceAtual: 3,
      appBar: AppBar(title: const Text('Placar')),
      body: FeaturePlaceholderSection(
        title: 'Feature: Placar',
        description: 'Base pronta para pontos, sets e historico de jogo.',
        items: viewModel.responsibilities,
      ),
    );
  }
}
