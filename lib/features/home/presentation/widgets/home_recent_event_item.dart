class HomeRecentEventItem {
  const HomeRecentEventItem({
    required this.id,
    required this.dateLabel,
    required this.eventLabel,
    required this.summaryLabel,
    required this.championLabel,
    required this.hasChampion,
  });

  final int id;
  final String dateLabel;
  final String eventLabel;
  final String summaryLabel;
  final String championLabel;
  final bool hasChampion;
}
