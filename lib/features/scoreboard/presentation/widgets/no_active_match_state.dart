import 'package:flutter/material.dart';
import 'package:volley_match/core/theme/app_colors.dart';

class NoActiveMatchState extends StatelessWidget {
  const NoActiveMatchState({
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
            'Nenhuma partida ativa',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.sports_volleyball_outlined,
                  color: AppColors.primary,
                  size: 36,
                ),
                const SizedBox(height: 14),
                Text(
                  'Para iniciar uma partida, faça um novo sorteio e configure o evento.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
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
