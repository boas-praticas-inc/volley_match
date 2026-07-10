class HomeRecentMatchItem {
  const HomeRecentMatchItem({
    required this.dateLabel,
    required this.matchLabel,
    required this.scoreLabel,
    required this.resultLabel,
    required this.isVictory,
  });

  final String dateLabel;
  final String matchLabel;
  final String scoreLabel;
  final String resultLabel;
  final bool isVictory;
}