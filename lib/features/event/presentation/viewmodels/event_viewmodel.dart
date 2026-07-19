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
  bool _isRenaming = false;
  bool _isDeleting = false;
  String? _errorMessage;

  EventProgressEntity? get eventProgress => _eventProgress;
  bool get isLoading => _isLoading;
  bool get isFinishing => _isFinishing;
  bool get isRenaming => _isRenaming;
  bool get isDeleting => _isDeleting;
  String? get errorMessage => _errorMessage;
  bool get hasEvent => _eventProgress != null;

  Future<void> loadEvent({int? eventId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _eventProgress = eventId == null
          ? await _repository.getActiveEventProgress()
          : await _repository.getEventProgress(eventId);

      if (_eventProgress == null) {
        _errorMessage = eventId == null
            ? 'Nenhum evento em andamento encontrado.'
            : 'Evento nao encontrado.';
      }
    } catch (_) {
      _errorMessage = 'Nao foi possivel carregar o evento.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadActiveEvent() {
    return loadEvent();
  }

  Future<bool> updateEventName({
    required int eventId,
    required String name,
  }) async {
    final normalizedName = name.trim();

    if (_isRenaming || normalizedName.isEmpty) {
      return false;
    }

    _isRenaming = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.updateEventName(eventId: eventId, name: normalizedName);
      _eventProgress = _eventProgress?.copyWith(name: normalizedName);
      return true;
    } catch (_) {
      _errorMessage = 'Nao foi possivel atualizar o nome do evento.';
      return false;
    } finally {
      _isRenaming = false;
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

  Future<bool> deleteEvent(int eventId) async {
    if (_isDeleting) {
      return false;
    }

    _isDeleting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteEvent(eventId);
      _eventProgress = null;
      return true;
    } catch (_) {
      _errorMessage = 'Nao foi possivel excluir o evento.';
      return false;
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
  }
}
