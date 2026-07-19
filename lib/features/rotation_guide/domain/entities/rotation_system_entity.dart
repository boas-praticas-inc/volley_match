enum RotationSystem { sixZero }

extension RotationSystemX on RotationSystem {
  String get name {
    return switch (this) {
      RotationSystem.sixZero => '6x0',
    };
  }

  String get description {
    return switch (this) {
      RotationSystem.sixZero =>
        'Levantador fixo no centro da rede; os demais rodam.',
    };
  }
}

class RotationSystemEntity {
  const RotationSystemEntity({
    required this.system,
    required this.name,
    required this.description,
  });

  final RotationSystem system;
  final String name;
  final String description;
}
