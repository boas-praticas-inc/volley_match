import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../models/home_recent_event_item.dart';

class HomeRecentEventsSection extends StatelessWidget {
  const HomeRecentEventsSection({
    super.key,
    required this.events,
    required this.isLoading,
    required this.errorMessage,
    required this.onSeeAllTap,
    required this.onEventTap,
  });

  final List<HomeRecentEventItem> events;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onSeeAllTap;
  final ValueChanged<HomeRecentEventItem> onEventTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Eventos Recentes',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            TextButton(onPressed: onSeeAllTap, child: const Text('Ver todos')),
          ],
        ),
        const SizedBox(height: 12),
        if (isLoading)
          const _RecentEventsLoadingCard()
        else if (errorMessage != null)
          _RecentEventsFeedbackCard(
            title: 'Erro ao carregar eventos',
            message: errorMessage!,
            icon: Icons.error_outline,
          )
        else if (events.isEmpty)
          const _RecentEventsFeedbackCard(
            title: 'Nenhum evento recente',
            message: 'Eventos finalizados vão aparecer aqui.',
            icon: Icons.timeline_outlined,
          )
        else
          ...events.map(
            (event) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _RecentEventCard(
                event: event,
                onTap: () => onEventTap(event),
              ),
            ),
          ),
      ],
    );
  }
}

class _RecentEventCard extends StatelessWidget {
  const _RecentEventCard({required this.event, required this.onTap});

  final HomeRecentEventItem event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.event_available_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.eventLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          event.dateLabel,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppColors.textSubtle,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right, color: AppColors.textSubtle),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentEventsLoadingCard extends StatelessWidget {
  const _RecentEventsLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _RecentEventsFeedbackCard extends StatelessWidget {
  const _RecentEventsFeedbackCard({
    required this.title,
    required this.message,
    required this.icon,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 32),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSubtle,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
