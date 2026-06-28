import 'package:flutter/material.dart';

import '../../../../shared/widgets/feature_placeholder_section.dart';
import '../viewmodels/match_viewmodel.dart';

class MatchPage extends StatelessWidget {
  const MatchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = MatchViewModel();

    return Scaffold(
      appBar: AppBar(title: const Text('Partidas')),
      body: FeaturePlaceholderSection(
        title: 'Feature: Partidas',
        description:
            'Estrutura pronta para historico e detalhamento das partidas.',
        items: viewModel.responsibilities,
      ),
    );
  }
}
