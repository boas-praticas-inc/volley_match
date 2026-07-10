import 'package:flutter/foundation.dart';

import '../widgets/home_recent_match_item.dart';

class HomeViewModel extends ChangeNotifier {
  final List<HomeRecentMatchItem> recentMatches = const [
    HomeRecentMatchItem(
      dateLabel: 'Hoje',
      matchLabel: 'Time A x Time B',
      scoreLabel: '25 x 21',
      resultLabel: 'Vitoria',
      isVictory: true,
    ),
    HomeRecentMatchItem(
      dateLabel: 'Ontem',
      matchLabel: 'Time C x Time A',
      scoreLabel: '18 x 25',
      resultLabel: 'Derrota',
      isVictory: false,
    ),
    HomeRecentMatchItem(
      dateLabel: '19 Mai',
      matchLabel: 'Time B x Time C',
      scoreLabel: '25 x 23',
      resultLabel: 'Vitoria',
      isVictory: true,
    ),
  ];
}
