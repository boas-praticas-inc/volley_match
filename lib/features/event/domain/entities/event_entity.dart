class EventEntity {
  const EventEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.date,
  });

  final int id;
  final String name;
  final String description;
  final DateTime date;
}
