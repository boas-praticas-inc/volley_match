import '../entities/event_match_configuration_entity.dart';
import '../repositories/event_repository.dart';

class StartEventMatchUseCase {
  const StartEventMatchUseCase(this._repository);

  final EventRepository _repository;

  Future<int> call(EventMatchConfigurationEntity configuration) {
    return _repository.startEventMatch(configuration);
  }
}
