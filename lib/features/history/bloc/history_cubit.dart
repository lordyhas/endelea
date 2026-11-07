import 'dart:async';

import 'package:endelea/data/repositories/exercise_repository.dart';
import 'package:endelea/data/repositories/session_repository.dart';
import 'package:endelea/domain/models/session_models.dart';
import 'package:endelea/domain/progress/stats.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HistoryItem extends Equatable {
  const HistoryItem({required this.details, required this.stats});

  final SessionDetails details;
  final SessionStats stats;

  @override
  List<Object?> get props => [details, stats];
}

sealed class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object?> get props => [];
}

final class HistoryLoading extends HistoryState {
  const HistoryLoading();
}

final class HistoryLoaded extends HistoryState {
  const HistoryLoaded(this.items);

  /// Most recent first.
  final List<HistoryItem> items;

  @override
  List<Object?> get props => [items];
}

/// Finished sessions with their duration, volume and records (PLAN.md §8.8).
class HistoryCubit extends Cubit<HistoryState> {
  HistoryCubit(this._sessions, this._exercises)
    : super(const HistoryLoading()) {
    _subscription = _sessions.watchHistory().asyncMap(_load).listen(emit);
  }

  final SessionRepository _sessions;
  final ExerciseRepository _exercises;
  late final StreamSubscription<HistoryLoaded> _subscription;

  Future<HistoryLoaded> _load(List<SessionDetails> history) async {
    final sets = await _sessions.getPerformedSets();
    final types = trackingTypesOf(await _exercises.getAll());
    final records = <String, int>{};
    for (final event in recordHistory(sets, types)) {
      records.update(event.set.sessionId, (n) => n + 1, ifAbsent: () => 1);
    }
    return HistoryLoaded([
      for (final details in history)
        HistoryItem(
          details: details,
          stats: sessionStats(
            details,
            recordCount: records[details.session.id] ?? 0,
          ),
        ),
    ]);
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    await super.close();
  }
}
