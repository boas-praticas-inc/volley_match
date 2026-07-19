import 'package:flutter/foundation.dart';

import '../../data/repositories/event_repository_impl.dart';
import '../../domain/entities/event_progress_entity.dart';
import '../../domain/repositories/event_repository.dart';

class EventViewModel extends ChangeNotifier {
  EventViewModel({EventRepository? repository})
    : _repository = repository ?? EventRepositoryImpl();

  final EventRepository _repository;

  EventProgressEntity? _eventProgress;
  bool _isLoading = false;
  bool _isFinishing = false;
  String? _errorMessage;

  EventProgressEntity? get eventProgress => _eventProgress;
  bool get isLoading => _isLoading;
  bool get isFinishing => _isFinishing;
  String? get errorMessage => _errorMessage;
  bool get hasEvent => _eventProgress != null;

  Future<void> loadActiveEvent() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _eventProgress = await _repository.getActiveEventProgress();

      if (_eventProgress == null) {
        _errorMessage = 'Nenhum evento em andamento encontrado.';
      }
    } catch (_) {
      _errorMessage = 'Nao foi possivel carregar o andamento do evento.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> finishEvent(int eventId) async {
    if (_isFinishing) {
      return false;
    }

    _isFinishing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.finishEvent(eventId);
      _eventProgress = null;
      _errorMessage = 'Nenhum evento em andamento encontrado.';
      return true;
    } catch (_) {
      _errorMessage = 'Nao foi possivel finalizar o evento.';
      return false;
    } finally {
      _isFinishing = false;
      notifyListeners();
    }
  }
}
