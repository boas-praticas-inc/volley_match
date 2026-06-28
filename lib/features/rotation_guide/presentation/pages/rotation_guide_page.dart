import 'package:flutter/material.dart';

import '../../../../shared/widgets/feature_placeholder_section.dart';
import '../viewmodels/rotation_guide_viewmodel.dart';

class RotationGuidePage extends StatelessWidget {
  const RotationGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = RotationGuideViewModel();

    return Scaffold(
      appBar: AppBar(title: const Text('Guia de rotacoes')),
      body: FeaturePlaceholderSection(
        title: 'Feature: Rotacoes',
        description: 'Estrutura pronta para os modulos visuais 6x0 e 5x1.',
        items: viewModel.responsibilities,
      ),
    );
  }
}
