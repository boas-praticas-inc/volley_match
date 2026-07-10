import 'package:flutter/material.dart';

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
    final badgeBackground =
    match.isVictory ? const Color(0xFFDDF7E7) : const Color(0xFFFFE1E1);
    final badgeTextColor =
    match.isVictory ? const Color(0xFF1AA251) : const Color(0xFFFF4D4F);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE6E8EE)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  match.dateLabel,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF98A2B3),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  match.matchLabel,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  match.scoreLabel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF667085),
                  ),
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
