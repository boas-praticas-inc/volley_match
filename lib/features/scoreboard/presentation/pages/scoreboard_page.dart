import 'package:flutter/material.dart';
import 'package:volley_match/core/router/app_routes.dart';
import 'package:volley_match/shared/widgets/feature_navBar.dart';

import '../viewmodels/scoreboard_viewmodel.dart';
import '../widgets/scoreboard_content.dart';

class ScoreboardPage extends StatefulWidget {
  const ScoreboardPage({super.key, this.matchId});

  final int? matchId;

  @override
  State<ScoreboardPage> createState() => _ScoreboardPageState();
}

class _ScoreboardPageState extends State<ScoreboardPage> {
  late final ScoreboardViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = ScoreboardViewModel(matchId: widget.matchId);
    viewModel.loadMatch();
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  void _openNewDraw() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.teamDraw);
  }

  void _showRotationMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Guia de rotacao ainda nao integrado.')),
    );
  }

  void _showExpandedScoreboardMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Vire o celular para usar o placar ampliado.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) {
        return OrientationBuilder(
          builder: (context, orientation) {
            if (orientation == Orientation.landscape && viewModel.hasMatch) {
              return Scaffold(body: LandscapeScoreboard(viewModel: viewModel));
            }

            return FeatureNavBar(
              indiceAtual: 3,
              appBar: AppBar(title: const Text('Placar')),
              body: PortraitScoreboard(
                viewModel: viewModel,
                onNewDraw: _openNewDraw,
                onRotationTap: _showRotationMessage,
                onExpandedTap: _showExpandedScoreboardMessage,
              ),
            );
          },
        );
      },
    );
  }
}
