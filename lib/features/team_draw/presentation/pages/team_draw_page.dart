import 'package:flutter/material.dart';

import '../../../../shared/widgets/feature_placeholder_section.dart';
import '../viewmodels/team_draw_viewmodel.dart';

class TeamDrawPage extends StatelessWidget {
  const TeamDrawPage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = TeamDrawViewModel();

    return Scaffold(
      appBar: AppBar(title: const Text('Sorteio de times')),
      body: FeaturePlaceholderSection(
        title: 'Feature: Sorteio de times',
        description:
            'Estrutura pronta para implementar o algoritmo de balanceamento por notas.',
        items: viewModel.responsibilities,
      ),
    );
  }
}
