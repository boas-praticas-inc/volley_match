import 'package:flutter/material.dart';

import '../../core/router/app_routes.dart';

class FeatureNavBar extends StatelessWidget {
  const FeatureNavBar({
    super.key,
    required this.indiceAtual,
    required this.body,
    this.appBar,
    this.floatingActionButton,
  });

  final int indiceAtual;
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;

  void _onTap(BuildContext context, int indice) {
    if (indice == indiceAtual) {
      return;
    }

    final rota = switch (indice) {
      0 => AppRoutes.home,
      1 => AppRoutes.players,
      2 => AppRoutes.teamDraw,
      3 => AppRoutes.scoreboard,
      _ => AppRoutes.home,
    };

    Navigator.of(context).pushReplacementNamed(rota);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: NavigationBar(
        selectedIndex: indiceAtual,
        onDestinationSelected: (indice) => _onTap(context, indice),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_3_outlined),
            selectedIcon: Icon(Icons.groups_3),
            label: 'Jogadores',
          ),
          NavigationDestination(
            icon: Icon(Icons.casino_outlined),
            selectedIcon: Icon(Icons.casino),
            label: 'Sorteio',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events),
            label: 'Partida',
          ),
        ],
      ),
    );
  }
}
