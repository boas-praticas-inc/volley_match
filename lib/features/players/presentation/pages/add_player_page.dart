import 'package:flutter/material.dart';

import '../../domain/entities/player_entity.dart';
import '../widgets/player_form.dart';

class AddPlayerPage extends StatelessWidget {
  const AddPlayerPage({super.key, required this.nextPlayerId});

  final int nextPlayerId;

  void _submitForm(BuildContext context, PlayerFormData formData) {
    final player = PlayerEntity(
      id: nextPlayerId,
      name: formData.name,
      skillRating: formData.skillRating,
      position: formData.position,
    );

    Navigator.of(context).pop(player);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar Jogador')),
      body: PlayerForm(
        submitLabel: 'Adicionar Jogador',
        onSubmit: (formData) => _submitForm(context, formData),
      ),
    );
  }
}
