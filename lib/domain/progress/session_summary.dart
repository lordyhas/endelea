import 'package:endelea/data/database.dart';
import 'package:endelea/domain/models/exercise_enums.dart';
import 'package:endelea/domain/models/session_models.dart';
import 'package:endelea/domain/progress/one_rep_max.dart';
import 'package:endelea/domain/progress/personal_records.dart';
import 'package:endelea/domain/progress/volume.dart';
import 'package:endelea/domain/session/session_rules.dart';
import 'package:equatable/equatable.dart';

/// A record beaten by one set of a session.
class RecordHit extends Equatable {
  const RecordHit({
    required this.exercise,
    required this.type,
    required this.set,
  });

  final Exercise exercise;
  final RecordType type;
  final PerformedSet set;

  @override
  List<Object?> get props => [exercise, type, set];
}

/// Figures of a finished session (PLAN.md §8.7).
class SessionSummary extends Equatable {
  const SessionSummary({
    required this.details,
    required this.duration,
    required this.volumeKg,
    required this.setCount,
    required this.records,
    this.previous,
  });

  final SessionDetails details;
  final Duration duration;
  final double volumeKg;

  /// Completed sets, warm-ups included.
  final int setCount;

  /// Best record of each kind per exercise.
  final List<RecordHit> records;

  /// Last session of the same program day, for comparison.
  final SessionSummary? previous;

  @override
  List<Object?> get props => [
    details,
    duration,
    volumeKg,
    setCount,
    records,
    previous,
  ];
}

/// Summarizes [details] against [history], every finished set of every
/// session (oldest first). Only sessions started before this one count for
/// records and comparison.
SessionSummary summarizeSession(
  SessionDetails details,
  List<PerformedSet> history, {
  SessionDetails? previousSameDay,
}) {
  final session = details.session;
  final before = history
      .where((s) => s.sessionStartedAt.isBefore(session.startedAt))
      .toList();

  final records = <RecordHit>[];
  var volume = 0.0;
  var count = 0;
  for (final exercise in details.exercises) {
    final done = performedSetsOf(session, exercise);
    count += done.length;
    volume += totalVolume(done);
    records.addAll(_recordsOf(exercise, done, before));
  }

  final previous = previousSameDay;
  return SessionSummary(
    details: details,
    duration: sessionElapsed(session, session.endedAt ?? session.startedAt),
    volumeKg: volume,
    setCount: count,
    records: records,
    previous: previous == null ? null : summarizeSession(previous, const []),
  );
}

List<RecordHit> _recordsOf(
  SessionExerciseDetails exercise,
  List<PerformedSet> done,
  List<PerformedSet> before,
) {
  final past = PersonalRecords.fromSets(
    before.where((s) => s.exerciseId == exercise.exercise.id),
  );
  final type = TrackingType.fromKey(exercise.exercise.trackingType);
  final best = <RecordType, RecordHit>{};
  final soFar = <PerformedSet>[];
  for (final set in done) {
    soFar.add(set);
    final hits = past.beatenBy(
      set: SetValues(
        reps: set.reps,
        weightKg: set.weightKg,
        isWarmup: set.isWarmup,
      ),
      trackingType: type,
      sessionVolumeKg: totalVolume(soFar),
    );
    for (final record in hits) {
      final current = best[record];
      // Keep the best set for each kind of record.
      if (current == null ||
          _score(record, set) >= _score(record, current.set)) {
        best[record] = RecordHit(
          exercise: exercise.exercise,
          type: record,
          set: set,
        );
      }
    }
  }
  return best.values.toList();
}

double _score(RecordType type, PerformedSet set) => switch (type) {
  RecordType.maxWeight => set.weightKg ?? 0,
  RecordType.estimatedOneRepMax =>
    estimatedOneRepMax(set.weightKg, set.reps) ?? 0,
  RecordType.repsAtWeight => (set.reps ?? 0).toDouble(),
  // Volume grows with every set: the last one carries the total.
  RecordType.sessionVolume => set.setIndex.toDouble(),
};
