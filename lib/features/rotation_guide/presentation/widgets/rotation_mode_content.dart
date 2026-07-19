import 'package:flutter/material.dart';

import '../../domain/services/rotation_calculator.dart';
import '../viewmodels/rotation_guide_viewmodel.dart';
import 'rotation_court_board.dart';
import 'rotation_footer.dart';
import 'rotation_header.dart';

class RotationModeContent extends StatelessWidget {
  const RotationModeContent({
    super.key,
    required this.state,
    required this.viewModel,
    required this.onClose,
  });

  final RotationCourtStateEntity state;
  final RotationGuideViewModel viewModel;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RotationHeader(
            title: 'Modo Rotação',
            subtitle:
                '${state.matchTitle} | Set ${state.currentSetNumber} | ${state.system.name}',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                HeaderIconButton(icon: Icons.refresh, onTap: viewModel.refresh),
                const SizedBox(width: 8),
                HeaderIconButton(icon: Icons.close, onTap: onClose),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(child: RotationCourtBoard(state: state)),
          const SizedBox(height: 8),
          RotationFooter(state: state, viewModel: viewModel),
        ],
      ),
    );
  }
}
