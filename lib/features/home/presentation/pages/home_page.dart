import 'package:flutter/material.dart';
import 'package:volley_match/features/home/presentation/widgets/home_recent_matches_section.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/feature_card.dart';
import '../../../../shared/widgets/feature_navBar.dart';
import '../viewmodels/home_viewmodel.dart';
import '../widgets/home_quick_actions.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = HomeViewModel();

    return FeatureNavBar(
      indiceAtual: 0,
      appBar: AppBar(title: Text(AppStrings.appName)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          HomeQuickActions(
            onNewDrawTap: () {
              Navigator.of(context).pushNamed(AppRoutes.teamDraw);
            },
            onStartMatchTap: () {
              Navigator.of(context).pushNamed(AppRoutes.scoreboard);
            },
          ),
          const SizedBox(height: 20),
          HomeRecentMatchesSection(
            matches: viewModel.recentMatches,
            onSeeAllTap: () {
              Navigator.of(context).pushNamed(AppRoutes.matches);
            },
          ),
        ],
      ),
    );
  }
}
