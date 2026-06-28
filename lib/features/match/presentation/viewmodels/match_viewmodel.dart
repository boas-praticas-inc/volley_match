import 'package:flutter/foundation.dart';

class MatchViewModel extends ChangeNotifier {
  final List<String> responsibilities = const [
    'Resultado final da partida.',
    'Quantidade de sets para vencer.',
    'Vinculo com evento e time vencedor.',
  ];
}
