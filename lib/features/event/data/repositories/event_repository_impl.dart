import '../../domain/entities/event_match_configuration_entity.dart';
import '../../domain/entities/event_progress_entity.dart';
import '../../domain/entities/recent_event_entity.dart';
import '../../domain/repositories/event_repository.dart';
import '../datasources/event_local_data_source.dart';

class EventRepositoryImpl implements EventRepository {
  EventRepositoryImpl({EventLocalDataSource? localDataSource})
    : _localDataSource = localDataSource ?? EventLocalDataSource();

  final EventLocalDataSource _localDataSource;

  @override
  Future<int> startEventMatch(EventMatchConfigurationEntity configuration) {
    return _localDataSource.startEventMatch(configuration);
  }

  @override
  Future<EventProgressEntity?> getActiveEventProgress() {
    return _localDataSource.getActiveEventProgress();
  }

  @override
  Future<EventProgressEntity?> getEventProgress(int eventId) {
    return _localDataSource.getEventProgress(eventId);
  }

  @override
  Future<List<RecentEventEntity>> getRecentEvents({int limit = 5}) {
    return _localDataSource.getRecentEvents(limit: limit);
  }

  @override
  Future<void> updateEventName({required int eventId, required String name}) {
    return _localDataSource.updateEventName(eventId: eventId, name: name);
  }

  @override
  Future<void> finishEvent(int eventId) {
    return _localDataSource.finishEvent(eventId);
  }
}
