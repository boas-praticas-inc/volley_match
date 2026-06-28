class PlayerEntity {
  const PlayerEntity({
    required this.id,
    required this.name,
    required this.skillRating,
    required this.position,
    this.photoPath,
  });

  final int id;
  final String name;
  final int skillRating;
  final String position;
  final String? photoPath;
}
