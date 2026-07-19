import 'package:flutter/foundation.dart';

import '../../../event/data/repositories/event_repository_impl.dart';
import '../../../event/domain/repositories/event_repository.dart';
import '../widgets/home_recent_event_item.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({EventRepository? eventRepository})
    : _eventRepository = eventRepository ?? EventRepositoryImpl();

  final EventRepository _eventRepository;

  final List<HomeRecentEventItem> _recentEvents = [];
  bool _isLoadingRecentEvents = false;
  String? _recentEventsErrorMessage;

  List<HomeRecentEventItem> get recentEvents =>
      List.unmodifiable(_recentEvents);
  bool get isLoadingRecentEvents => _isLoadingRecentEvents;
  String? get recentEventsErrorMessage => _recentEventsErrorMessage;

  Future<void> loadRecentEvents() async {
    _isLoadingRecentEvents = true;
    _recentEventsErrorMessage = null;
    notifyListeners();

    try {
      final events = await _eventRepository.getRecentEvents(limit: 5);

      _recentEvents
        ..clear()
        ..addAll(
          events.map((event) {
            return HomeRecentEventItem(
              id: event.id,
              dateLabel: _formatDateLabel(event.date),
              eventLabel: event.name,
            );
          }),
        );
    } catch (_) {
      _recentEventsErrorMessage = 'Nao foi possivel carregar eventos recentes.';
    } finally {
      _isLoadingRecentEvents = false;
      notifyListeners();
    }
  }

  String _formatDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(date.year, date.month, date.day);
    final differenceInDays = today.difference(eventDay).inDays;

    if (differenceInDays == 0) {
      return 'Hoje';
    }

    if (differenceInDays == 1) {
      return 'Ontem';
    }

    return '${date.day.toString().padLeft(2, '0')} ${_monthLabel(date.month)}';
  }

  String _monthLabel(int month) {
    const months = [
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez',
    ];

    if (month < 1 || month > months.length) {
      return '';
    }

    return months[month - 1];
  }
}
