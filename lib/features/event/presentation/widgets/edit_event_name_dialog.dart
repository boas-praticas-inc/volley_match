import 'package:flutter/material.dart';

class EditEventNameDialog extends StatefulWidget {
  const EditEventNameDialog({super.key, required this.initialName});

  final String initialName;

  @override
  State<EditEventNameDialog> createState() => _EditEventNameDialogState();
}

class _EditEventNameDialogState extends State<EditEventNameDialog> {
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
      title: const Text('Editar nome do evento'),
      content: TextField(
        controller: controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(hintText: 'Nome do evento'),
        onSubmitted: (value) {
          Navigator.of(context).pop(value.trim());
        },
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
