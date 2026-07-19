import '../entities/event_match_configuration_entity.dart';
import '../entities/event_progress_entity.dart';
import '../entities/recent_event_entity.dart';

abstract class EventRepository {
  Future<int> startEventMatch(EventMatchConfigurationEntity configuration);

  Future<EventProgressEntity?> getActiveEventProgress();

  Future<EventProgressEntity?> getEventProgress(int eventId);

  Future<List<RecentEventEntity>> getRecentEvents({int limit = 5});

  Future<void> updateEventName({required int eventId, required String name});

  Future<void> finishEvent(int eventId);
}
