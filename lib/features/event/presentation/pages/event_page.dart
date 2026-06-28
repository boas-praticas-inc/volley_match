import 'package:flutter/material.dart';

import '../../../../shared/widgets/feature_placeholder_section.dart';
import '../viewmodels/event_viewmodel.dart';

class EventPage extends StatelessWidget {
  const EventPage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = EventViewModel();

    return Scaffold(
      appBar: AppBar(title: const Text('Eventos')),
      body: FeaturePlaceholderSection(
        title: 'Feature: Eventos',
        description:
            'Base pronta para agrupar times e partidas em cada encontro.',
        items: viewModel.responsibilities,
      ),
    );
  }
}
