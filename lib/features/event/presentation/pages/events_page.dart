import 'package:flutter/material.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/feature_nav_bar.dart';
import '../../domain/entities/recent_event_entity.dart';
import '../viewmodels/events_viewmodel.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  late final EventsViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = EventsViewModel();
    viewModel.loadEvents();
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  Future<void> _openEvent(RecentEventEntity event) async {
    await Navigator.of(
      context,
    ).pushNamed(AppRoutes.eventDetails, arguments: event.id);
    await viewModel.loadEvents();
  }

  Future<void> _openNewDraw() async {
    await Navigator.of(context).pushNamed(AppRoutes.teamDraw);
    await viewModel.loadEvents();
  }

  @override
  Widget build(BuildContext context) {
    return FeatureNavBar(
      indiceAtual: 2,
      appBar: AppBar(title: const Text('Eventos')),
      floatingActionButton: FloatingActionButton(
        onPressed: _openNewDraw,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: AnimatedBuilder(
        animation: viewModel,
        builder: (context, _) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 2, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${viewModel.totalEventsCount} eventos',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: AppColors.textSubtle),
                ),
                const SizedBox(height: 20),
                TextField(
                  onChanged: viewModel.updateSearchQuery,
                  decoration: const InputDecoration(
                    hintText: 'Buscar evento...',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 16),
                _EventStatusFilters(
                  filters: viewModel.statusFilters,
                  selectedFilter: viewModel.selectedStatus,
                  onSelected: viewModel.selectStatus,
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: viewModel.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : viewModel.errorMessage != null
                      ? _EventsFeedbackState(
                          title: 'Erro ao carregar eventos',
                          message: viewModel.errorMessage!,
                        )
                      : viewModel.events.isEmpty
                      ? const _EventsFeedbackState(
                          title: 'Nenhum evento encontrado',
                          message:
                              'Eventos criados a partir de sorteios vão aparecer aqui.',
                        )
                      : RefreshIndicator(
                          onRefresh: viewModel.loadEvents,
                          child: ListView.builder(
                            itemCount: viewModel.events.length,
                            itemBuilder: (context, index) {
                              final event = viewModel.events[index];

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _EventListCard(
                                  event: event,
                                  onTap: () => _openEvent(event),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _EventStatusFilters extends StatelessWidget {
  const _EventStatusFilters({
    required this.filters,
    required this.selectedFilter,
    required this.onSelected,
  });

  final List<String> filters;
  final String selectedFilter;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (_) => onSelected(filter),
              showCheckmark: false,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textMuted,
                fontWeight: FontWeight.w800,
              ),
              backgroundColor: AppColors.surfaceMuted,
              selectedColor: AppColors.primary,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _EventListCard extends StatelessWidget {
  const _EventListCard({required this.event, required this.onTap});

  final RecentEventEntity event;
  final VoidCallback onTap;

  bool get isInProgress => event.status == 'in_progress';

  @override
  Widget build(BuildContext context) {
    final statusColor = isInProgress ? AppColors.success : AppColors.textMuted;
    final statusBackground = isInProgress
        ? AppColors.successBackground
        : AppColors.surfaceMuted;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.event_available_outlined,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _formatDate(event.date),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: statusBackground,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          isInProgress ? 'Ativo' : 'Finalizado',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textSubtle,
                    size: 22,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class _EventsFeedbackState extends StatelessWidget {
  const _EventsFeedbackState({required this.title, required this.message});

  final String title;
  final String message;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
