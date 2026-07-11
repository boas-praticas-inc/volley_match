import 'package:flutter/foundation.dart';

import '../../domain/entities/player_entity.dart';

class PlayersViewModel extends ChangeNotifier {
  final List<PlayerEntity> players = const [
    PlayerEntity(
      id: 1,
      name: 'Matheus',
      skillRating: 8,
      position: 'Levantador',
    ),
    PlayerEntity(
      id: 2,
      name: 'Bruno',
      skillRating: 7,
      position: 'Ponteiro',
    ),
    PlayerEntity(
      id: 3,
      name: 'Caio',
      skillRating: 9,
      position: 'Central',
    ),
    PlayerEntity(
      id: 4,
      name: 'Rafael',
      skillRating: 6,
      position: 'Libero',
    ),
  ];
}
