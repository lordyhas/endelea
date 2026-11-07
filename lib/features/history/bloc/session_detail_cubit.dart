import 'dart:async';

import 'package:endelea/data/repositories/session_repository.dart';
import 'package:endelea/domain/models/session_models.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class SessionDetailState extends Equatable {
  const SessionDetailState();

  @override
  List<Object?> get props => [];
}

final class SessionDetailLoading extends SessionDetailState {
  const SessionDetailLoading();
}

final class SessionDetailLoaded extends SessionDetailState {
  const SessionDetailLoaded(this.details);

  final SessionDetails details;

  @override
  List<Object?> get props => [details];
}

final class SessionDetailNotFound extends SessionDetailState {
  const SessionDetailNotFound();
}

/// A past session: its sets, corrected after the fact, or deleted.
class SessionDetailCubit extends Cubit<SessionDetailState> {
  SessionDetailCubit(this._sessions, this.sessionId)
    : super(const SessionDetailLoading()) {
    _subscription = _sessions
        .watchDetails(sessionId)
        .listen(
          (details) => emit(
            details == null
                ? const SessionDetailNotFound()
                : SessionDetailLoaded(details),
          ),
        );
  }

  final SessionRepository _sessions;
  final String sessionId;
  late final StreamSubscription<SessionDetails?> _subscription;

  Future<void> updateSet(String setId, SetValues values) =>
      _sessions.updateSet(setId, values);

  Future<void> updateNotes(String notes) =>
      _sessions.updateSessionNotes(sessionId, notes);

  Future<void> delete() => _sessions.delete(sessionId);

  @override
  Future<void> close() async {
    await _subscription.cancel();
    await super.close();
  }
}
