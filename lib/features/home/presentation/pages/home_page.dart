import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/feature_navBar.dart';
import '../viewmodels/home_viewmodel.dart';
import '../widgets/home_quick_actions.dart';
import '../widgets/home_recent_event_item.dart';
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
    ).pushNamed(AppRoutes.events, arguments: event.id);
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
              HomeQuickActions(
                onNewDrawTap: _openTeamDraw,
                onStartMatchTap: _openTeamDraw,
              ),
              const SizedBox(height: 20),
              HomeRecentEventsSection(
                events: viewModel.recentEvents,
                isLoading: viewModel.isLoadingRecentEvents,
                errorMessage: viewModel.recentEventsErrorMessage,
                onRetry: viewModel.loadRecentEvents,
                onEventTap: _openEvent,
              ),
            ],
          );
        },
      ),
    );
  }
}
