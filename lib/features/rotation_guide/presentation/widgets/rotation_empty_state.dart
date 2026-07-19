import 'package:flutter/material.dart';

import 'rotation_header.dart';

class RotationEmptyState extends StatelessWidget {
  const RotationEmptyState({
    super.key,
    required this.message,
    required this.onClose,
  });

  final String message;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RotationHeader(
            title: 'Modo Rotação',
            subtitle: 'Partida não encontrada',
            trailing: HeaderIconButton(icon: Icons.close, onTap: onClose),
          ),
          Expanded(
            child: Center(
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
