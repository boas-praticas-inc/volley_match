import 'package:flutter/material.dart';
import 'package:volley_match/core/theme/app_colors.dart';

class EmptyEventState extends StatelessWidget {
  const EmptyEventState({
    super.key,
    required this.message,
    required this.onNewDraw,
  });

  final String message;
  final VoidCallback onNewDraw;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 2, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nenhum evento ativo',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: const Icon(
              Icons.timeline_outlined,
              color: AppColors.primary,
              size: 42,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onNewDraw,
              icon: const Icon(Icons.casino_outlined),
              label: const Text('Fazer novo sorteio'),
            ),
          ),
        ],
      ),
    );
  }
}
