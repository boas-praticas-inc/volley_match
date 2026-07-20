class RecentEventEntity {
  const RecentEventEntity({
    required this.id,
    required this.name,
    required this.date,
    required this.status,
    required this.totalTeams,
    required this.totalMatches,
    required this.championTeamName,
  });

  final int id;
  final String name;
  final DateTime date;
  final String status;
  final int totalTeams;
  final int totalMatches;
  final String? championTeamName;
}
