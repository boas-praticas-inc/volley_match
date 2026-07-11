import 'package:flutter/material.dart';
import 'package:volley_match/core/theme/app_colors.dart';

import '../../domain/entities/player_entity.dart';
import '../widgets/player_form.dart';

class EditPlayerResult {
  const EditPlayerResult._({
    this.updatedPlayer,
    this.removedPlayerId,
  });

  const EditPlayerResult.updated(PlayerEntity player)
      : this._(updatedPlayer: player);

  const EditPlayerResult.removed(int playerId)
      : this._(removedPlayerId: playerId);

  final PlayerEntity? updatedPlayer;
  final int? removedPlayerId;
}

class EditPlayerPage extends StatefulWidget {
  const EditPlayerPage({super.key, required this.player});

  final PlayerEntity player;

  @override
  State<EditPlayerPage> createState() => _EditPlayerPageState();
}

class _EditPlayerPageState extends State<EditPlayerPage> {
  void _saveChanges(PlayerFormData formData) {
    final updatedPlayer = PlayerEntity(
      id: widget.player.id,
      name: formData.name,
      skillRating: formData.skillRating,
      position: formData.position,
      photoPath: widget.player.photoPath,
    );

    Navigator.of(context).pop(EditPlayerResult.updated(updatedPlayer));
  }

  Future<void> _confirmRemovePlayer() async {
    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Remover jogador'),
          content: Text(
            'Deseja remover ${widget.player.name} da base de jogadores?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.danger,
              ),
              child: const Text('Remover'),
            ),
          ],
        );
      },
    );

    if (!mounted) {
      return;
    }

    if (shouldRemove == true) {
      Navigator.of(context).pop(EditPlayerResult.removed(widget.player.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Jogador')),
      body: PlayerForm(
        initialName: widget.player.name,
        initialPosition: widget.player.position,
        initialSkillRating: widget.player.skillRating,
        submitLabel: 'Salvar Alteracoes',
        onSubmit: _saveChanges,
        secondaryAction: Align(
          alignment: Alignment.center,
          child: FractionallySizedBox(
            widthFactor: 0.66,
            child: OutlinedButton(
              onPressed: _confirmRemovePlayer,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                side: const BorderSide(color: AppColors.danger, width: 2),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text('Remover Jogador'),
            ),
          ),
        ),
      ),
    );
  }
}
