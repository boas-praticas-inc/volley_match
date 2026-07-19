import '../entities/event_match_configuration_entity.dart';
import '../entities/event_progress_entity.dart';

abstract class EventRepository {
  Future<int> startEventMatch(EventMatchConfigurationEntity configuration);

  Future<EventProgressEntity?> getActiveEventProgress();

  Future<void> finishEvent(int eventId);
}
