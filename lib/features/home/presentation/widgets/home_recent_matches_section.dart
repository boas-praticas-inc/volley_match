import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'home_recent_match_item.dart';

class HomeRecentMatchesSection extends StatelessWidget {
  const HomeRecentMatchesSection({
    super.key,
    required this.matches,
    required this.onSeeAllTap,
  });

  final List<HomeRecentMatchItem> matches;
  final VoidCallback onSeeAllTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Partidas Recentes',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            TextButton(onPressed: onSeeAllTap, child: const Text('Ver todas')),
          ],
        ),
        const SizedBox(height: 12),
        if (matches.isEmpty)
          const _EmptyRecentMatchesCard()
        else
          ...matches.map(
            (match) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _RecentMatchCard(match: match),
            ),
          ),
      ],
    );
  }
}

class _RecentMatchCard extends StatelessWidget {
  const _RecentMatchCard({required this.match});

  final HomeRecentMatchItem match;

  @override
  Widget build(BuildContext context) {
    final badgeBackground = match.isVictory
        ? AppColors.successBackground
        : AppColors.dangerBackground;
    final badgeTextColor = match.isVictory
        ? AppColors.success
        : AppColors.danger;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  match.dateLabel,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.textSubtle),
                ),
                const SizedBox(height: 8),
                Text(
                  match.matchLabel,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  match.scoreLabel,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: badgeBackground,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              match.resultLabel,
              style: TextStyle(
                color: badgeTextColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyRecentMatchesCard extends StatelessWidget {
  const _EmptyRecentMatchesCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nenhuma partida recente',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'As partidas finalizadas vão aparecer aqui.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSubtle),
          ),
        ],
      ),
    );
  }
}
