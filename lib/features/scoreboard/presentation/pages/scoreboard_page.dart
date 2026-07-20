import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:volley_match/core/router/app_routes.dart';
import 'package:volley_match/core/theme/app_colors.dart';
import 'package:volley_match/features/rotation_guide/presentation/pages/rotation_guide_page.dart';
import 'package:volley_match/shared/widgets/feature_nav_bar.dart';
import 'package:volley_match/shared/widgets/team_players_sheet.dart';

import '../../domain/entities/scoreboard_match_entity.dart';
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
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    viewModel.dispose();
    super.dispose();
  }

  void _openNewDraw() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.teamDraw);
  }

  void _openEventProgress() {
    Navigator.of(
      context,
    ).pushNamed(AppRoutes.eventDetails, arguments: viewModel.match?.eventId);
  }

  void _showTeamPlayers(ScoreboardTeamEntity team, Color accentColor) {
    showTeamPlayersSheet(
      context: context,
      teamName: team.name,
      players: team.players.map(_playerViewDataFromScoreboard).toList(),
      accentColor: accentColor,
    );
  }

  TeamPlayerViewData _playerViewDataFromScoreboard(
    ScoreboardPlayerEntity player,
  ) {
    return TeamPlayerViewData(
      name: player.name,
      position: player.position,
      rotationOrder: player.rotationOrder,
      photoPath: player.photoPath,
    );
  }

  Future<void> _openRotationGuide() async {
    if (!viewModel.hasMatch) {
      return;
    }

    await viewModel.flushPendingSaves();

    if (!mounted) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RotationGuidePage(matchId: viewModel.match!.matchId),
      ),
    );

    if (!mounted) {
      return;
    }

    await viewModel.loadMatch();
  }

  Future<void> _openExpandedScoreboard() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  Future<void> _exitExpandedScoreboard() async {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ScoreboardViewModel>.value(
      value: viewModel,
      child: Consumer<ScoreboardViewModel>(
      builder: (context, viewModel, _) {
        return OrientationBuilder(
          builder: (context, orientation) {
            if (orientation == Orientation.landscape && viewModel.hasMatch) {
              return Scaffold(
                body: LandscapeScoreboard(
                  viewModel: viewModel,
                  onExitExpanded: _exitExpandedScoreboard,
                ),
              );
            }

            return FeatureNavBar(
              indiceAtual: 3,
              appBar: AppBar(title: const Text('Placar')),
              body: PortraitScoreboard(
                viewModel: viewModel,
                onNewDraw: _openNewDraw,
                onEventTap: _openEventProgress,
                onRotationTap: _openRotationGuide,
                onHomeTeamTap: () {
                  final match = viewModel.match;

                  if (match != null) {
                    _showTeamPlayers(match.homeTeam, AppColors.primary);
                  }
                },
                onAwayTeamTap: () {
                  final match = viewModel.match;

                  if (match != null) {
                    _showTeamPlayers(match.awayTeam, AppColors.danger);
                  }
                },
                onExpandedTap: () {
                  _openExpandedScoreboard();
                },
              ),
            );
          },
        );
      },
      ),
    );
  }
}
