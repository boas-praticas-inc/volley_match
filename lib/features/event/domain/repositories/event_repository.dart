import '../entities/event_match_configuration_entity.dart';

abstract class EventRepository {
  Future<int> startEventMatch(EventMatchConfigurationEntity configuration);
}
