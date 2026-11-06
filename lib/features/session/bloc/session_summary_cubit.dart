import 'package:endelea/data/repositories/session_repository.dart';
import 'package:endelea/domain/progress/session_summary.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class SessionSummaryState extends Equatable {
  const SessionSummaryState();

  @override
  List<Object?> get props => [];
}

final class SessionSummaryLoading extends SessionSummaryState {
  const SessionSummaryLoading();
}

final class SessionSummaryLoaded extends SessionSummaryState {
  const SessionSummaryLoaded(this.summary);

  final SessionSummary summary;

  @override
  List<Object?> get props => [summary];
}

final class SessionSummaryNotFound extends SessionSummaryState {
  const SessionSummaryNotFound();
}

/// Summary of a finished session (PLAN.md §8.7).
class SessionSummaryCubit extends Cubit<SessionSummaryState> {
  SessionSummaryCubit(this._sessions, this.sessionId)
    : super(const SessionSummaryLoading());

  final SessionRepository _sessions;
  final String sessionId;

  Future<void> load() async {
    final details = await _sessions.getDetails(sessionId);
    if (details == null) {
      emit(const SessionSummaryNotFound());
      return;
    }
    final history = await _sessions.getPerformedSets();
    final dayId = details.session.programDayId;
    final previous = dayId == null
        ? null
        : (await _sessions.getHistory())
              .where(
                (s) =>
                    s.session.programDayId == dayId &&
                    s.session.startedAt.isBefore(details.session.startedAt),
              )
              .firstOrNull;
    emit(
      SessionSummaryLoaded(
        summarizeSession(details, history, previousSameDay: previous),
      ),
    );
  }

  Future<void> saveNotes(String notes) =>
      _sessions.updateSessionNotes(sessionId, notes);
}
