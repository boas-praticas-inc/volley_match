import '../../domain/entities/player_entity.dart';

class PlayerModel extends PlayerEntity {
  const PlayerModel({
    required super.id,
    required super.name,
    required super.skillRating,
    required super.position,
    super.photoPath,
  });

  factory PlayerModel.fromMap(Map<String, Object?> map) {
    return PlayerModel(
      id: map['id'] as int,
      name: map['name'] as String,
      position: _canonicalPosition(map['position'] as String),
      skillRating: map['skill_rating'] as int,
      photoPath: map['photo_path'] as String?,
    );
  }

  factory PlayerModel.fromEntity(PlayerEntity entity) {
    return PlayerModel(
      id: entity.id,
      name: entity.name,
      skillRating: entity.skillRating,
      position: _canonicalPosition(entity.position),
      photoPath: entity.photoPath,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'position': position,
      'skill_rating': skillRating,
      'photo_path': photoPath,
    };
  }

  static String _canonicalPosition(String position) {
    final trimmedPosition = position.trim();
    final normalizedPosition = trimmedPosition.toLowerCase().replaceAll(
      'í',
      'i',
    );

    if (normalizedPosition == 'libero') {
      return 'Líbero';
    }

    return trimmedPosition;
  }
}
