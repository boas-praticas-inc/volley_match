import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../viewmodels/rotation_guide_viewmodel.dart';
import '../widgets/rotation_empty_state.dart';
import '../widgets/rotation_mode_content.dart';

class RotationGuidePage extends StatefulWidget {
  const RotationGuidePage({super.key, this.matchId});

  final int? matchId;

  @override
  State<RotationGuidePage> createState() => _RotationGuidePageState();
}

class _RotationGuidePageState extends State<RotationGuidePage> {
  static const _backgroundColor = Color(0xFF0E1A2D);

  late final RotationGuideViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = RotationGuideViewModel();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    viewModel.load(matchId: widget.matchId);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    viewModel.dispose();
    super.dispose();
  }

  void _close() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: ChangeNotifierProvider<RotationGuideViewModel>.value(
          value: viewModel,
          child: Consumer<RotationGuideViewModel>(
          builder: (context, viewModel, _) {
            if (viewModel.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            if (!viewModel.hasMatch) {
              return RotationEmptyState(
                message:
                    viewModel.errorMessage ??
                    'Nenhuma partida em andamento encontrada.',
                onClose: _close,
              );
            }

            final courtState = viewModel.courtState;

            if (courtState == null) {
              return RotationEmptyState(
                message:
                    viewModel.errorMessage ??
                    'Não foi possível montar a rotação.',
                onClose: _close,
              );
            }

            return RotationModeContent(
              state: courtState,
              viewModel: viewModel,
              onClose: _close,
            );
          },
          ),
        ),
      ),
    );
  }
}
