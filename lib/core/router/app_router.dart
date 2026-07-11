import 'package:flutter/material.dart';

import '../../features/event/presentation/pages/event_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/match/presentation/pages/match_page.dart';
import '../../features/players/presentation/pages/add_player_page.dart';
import '../../features/players/presentation/pages/players_page.dart';
import '../../features/rotation_guide/presentation/pages/rotation_guide_page.dart';
import '../../features/scoreboard/presentation/pages/scoreboard_page.dart';
import '../../features/team_draw/presentation/pages/team_draw_page.dart';
import 'app_routes.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case AppRoutes.players:
        return MaterialPageRoute(builder: (_) => const PlayersPage());
      case AppRoutes.addPlayer:
        final nextPlayerId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => AddPlayerPage(nextPlayerId: nextPlayerId),
        );
      case AppRoutes.teamDraw:
        return MaterialPageRoute(builder: (_) => const TeamDrawPage());
      case AppRoutes.scoreboard:
        return MaterialPageRoute(builder: (_) => const ScoreboardPage());
      case AppRoutes.rotationGuide:
        return MaterialPageRoute(builder: (_) => const RotationGuidePage());
      case AppRoutes.events:
        return MaterialPageRoute(builder: (_) => const EventPage());
      case AppRoutes.matches:
        return MaterialPageRoute(builder: (_) => const MatchPage());
      default:
        return MaterialPageRoute(builder: (_) => const HomePage());
    }
  }
}
