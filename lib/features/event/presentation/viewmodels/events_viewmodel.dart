import 'package:flutter/foundation.dart';

import '../../data/repositories/event_repository_impl.dart';
import '../../domain/entities/recent_event_entity.dart';
import '../../domain/repositories/event_repository.dart';

class EventsViewModel extends ChangeNotifier {
  EventsViewModel({EventRepository? repository})
    : _repository = repository ?? EventRepositoryImpl();

  final EventRepository _repository;

  final List<RecentEventEntity> _events = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String _selectedStatus = allStatusFilter;

  static const allStatusFilter = 'Todos';
  static const inProgressStatusFilter = 'Em andamento';
  static const finishedStatusFilter = 'Finalizados';

  List<String> get statusFilters => const [
    allStatusFilter,
    inProgressStatusFilter,
    finishedStatusFilter,
  ];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedStatus => _selectedStatus;

  int get totalEventsCount => _events.length;

  List<RecentEventEntity> get events {
    final normalizedQuery = _searchQuery.trim().toLowerCase();

    return _events.where((event) {
      final matchesSearch =
          normalizedQuery.isEmpty ||
          event.name.toLowerCase().contains(normalizedQuery) ||
          (event.championTeamName?.toLowerCase().contains(normalizedQuery) ??
              false);
      final matchesStatus =
          _selectedStatus == allStatusFilter ||
          (_selectedStatus == inProgressStatusFilter &&
              event.status == 'in_progress') ||
          (_selectedStatus == finishedStatusFilter &&
              event.status == 'finished');

      return matchesSearch && matchesStatus;
    }).toList();
  }

  Future<void> loadEvents() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final events = await _repository.getEvents();

      _events
        ..clear()
        ..addAll(events);
    } catch (_) {
      _errorMessage = 'Nao foi possivel carregar os eventos.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void selectStatus(String status) {
    _selectedStatus = status;
    notifyListeners();
  }
}
