import '../../domain/entities/event_match_configuration_entity.dart';
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
}
