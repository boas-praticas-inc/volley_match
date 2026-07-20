import 'package:flutter/material.dart';

class EditTeamNameDialog extends StatefulWidget {
  const EditTeamNameDialog({super.key, required this.initialName});

  final String initialName;

  @override
  State<EditTeamNameDialog> createState() => _EditTeamNameDialogState();
}

class _EditTeamNameDialogState extends State<EditTeamNameDialog> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar nome do time'),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(hintText: 'Nome do time'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(controller.text.trim());
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
