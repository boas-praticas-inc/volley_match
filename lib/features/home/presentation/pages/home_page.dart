import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/feature_nav_bar.dart';
import '../viewmodels/home_viewmodel.dart';
import '../widgets/home_quick_actions.dart';
import '../models/home_recent_event_item.dart';
import '../widgets/home_recent_events_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = HomeViewModel();
    viewModel.loadRecentEvents();
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  Future<void> _openTeamDraw() async {
    await Navigator.of(context).pushNamed(AppRoutes.teamDraw);
    await viewModel.loadRecentEvents();
  }

  Future<void> _openEvent(HomeRecentEventItem event) async {
    await Navigator.of(
      context,
    ).pushNamed(AppRoutes.eventDetails, arguments: event.id);
    await viewModel.loadRecentEvents();
  }

  Future<void> _openEvents() async {
    await Navigator.of(context).pushNamed(AppRoutes.events);
    await viewModel.loadRecentEvents();
  }

  @override
  Widget build(BuildContext context) {
    return FeatureNavBar(
      indiceAtual: 0,
      appBar: AppBar(title: Text(AppStrings.appName)),
      body: AnimatedBuilder(
        animation: viewModel,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              HomeQuickActions(onStartMatchTap: _openTeamDraw),
              const SizedBox(height: 20),
              HomeRecentEventsSection(
                events: viewModel.recentEvents,
                isLoading: viewModel.isLoadingRecentEvents,
                errorMessage: viewModel.recentEventsErrorMessage,
                onSeeAllTap: _openEvents,
                onEventTap: _openEvent,
              ),
            ],
          );
        },
      ),
    );
  }
}
