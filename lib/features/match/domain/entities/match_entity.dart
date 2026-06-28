class MatchEntity {
  const MatchEntity({
    required this.id,
    required this.eventId,
    required this.date,
    required this.result,
    required this.setsToWin,
  });

  final int id;
  final int eventId;
  final DateTime date;
  final String result;
  final int setsToWin;
}
