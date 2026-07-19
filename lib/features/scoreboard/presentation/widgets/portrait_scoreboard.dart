import 'package:flutter/material.dart';

import '../viewmodels/scoreboard_viewmodel.dart';
import 'no_active_match_state.dart';
import 'scoreboard_match_control_center.dart';
import 'scoreboard_match_header.dart';
import 'scoreboard_score_card.dart';
import 'secondary_scoreboard_button.dart';
import 'winner_card.dart';

class PortraitScoreboard extends StatelessWidget {
  const PortraitScoreboard({
    super.key,
    required this.viewModel,
    required this.onNewDraw,
    required this.onEventTap,
    required this.onRotationTap,
    required this.onHomeTeamTap,
    required this.onAwayTeamTap,
    required this.onExpandedTap,
  });

  final ScoreboardViewModel viewModel;
  final VoidCallback onNewDraw;
  final VoidCallback onEventTap;
  final VoidCallback onRotationTap;
  final VoidCallback onHomeTeamTap;
  final VoidCallback onAwayTeamTap;
  final VoidCallback onExpandedTap;

  @override
  Widget build(BuildContext context) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!viewModel.hasMatch) {
      return NoActiveMatchState(
        message:
            viewModel.errorMessage ??
            'Nenhuma partida em andamento encontrada.',
        onNewDraw: onNewDraw,
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 2, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScoreboardMatchHeader(viewModel: viewModel),
          const SizedBox(height: 12),
          ScoreCard(
            viewModel: viewModel,
            onHomeTeamTap: onHomeTeamTap,
            onAwayTeamTap: onAwayTeamTap,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SecondaryScoreboardButton(
                  icon: Icons.timeline_outlined,
                  label: 'Evento',
                  onTap: onEventTap,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SecondaryScoreboardButton(
                  icon: Icons.rotate_right_outlined,
                  label: 'Rotação',
                  onTap: onRotationTap,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SecondaryScoreboardButton(
                  icon: Icons.open_in_full_outlined,
                  label: 'Ampliado',
                  onTap: onExpandedTap,
                ),
              ),
            ],
          ),
          if (viewModel.winnerName != null) ...[
            const SizedBox(height: 12),
            WinnerCard(winnerName: viewModel.winnerName!),
          ],
          const Spacer(),
          if (!viewModel.isReadOnly) ...[
            const SizedBox(height: 12),
            MatchControlCenter(viewModel: viewModel),
          ],
        ],
      ),
    );
  }
}
