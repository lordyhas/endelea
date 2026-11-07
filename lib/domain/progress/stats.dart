import 'dart:math' as math;

import 'package:endelea/core/utils/date_utils.dart';
import 'package:endelea/data/database.dart';
import 'package:endelea/domain/models/exercise_enums.dart';
import 'package:endelea/domain/models/session_models.dart';
import 'package:endelea/domain/progress/one_rep_max.dart';
import 'package:endelea/domain/progress/personal_records.dart';
import 'package:endelea/domain/progress/volume.dart';
import 'package:equatable/equatable.dart';

/// Period of the progress screen (PLAN.md §8.9).
enum ProgressPeriod {
  weeks4,
  months3,
  year,
  all;

  /// First day included at [now], null for everything.
  DateTime? start(DateTime now) {
    final today = startOfDay(now);
    return switch (this) {
      ProgressPeriod.weeks4 => startOfWeek(
        today.subtract(const Duration(days: 7 * 3)),
      ),
      ProgressPeriod.months3 => DateTime(
        today.year,
        today.month - 3,
        today.day,
      ),
      ProgressPeriod.year => DateTime(today.year - 1, today.month, today.day),
      ProgressPeriod.all => null,
    };
  }
}

/// Volume of one week (Monday, local time).
class WeekVolume extends Equatable {
  const WeekVolume(this.weekStart, this.volumeKg);

  final DateTime weekStart;
  final double volumeKg;

  @override
  List<Object?> get props => [weekStart, volumeKg];
}

/// Weekly volume from [from] (or the first set) to [now], empty weeks
/// included.
List<WeekVolume> weeklyVolume(
  Iterable<PerformedSet> sets,
  DateTime now, {
  DateTime? from,
}) {
  final byWeek = <DateTime, double>{};
  DateTime? first;
  for (final set in sets) {
    final week = startOfWeek(set.sessionStartedAt);
    if (from != null && week.isBefore(startOfWeek(from))) continue;
    byWeek[week] = (byWeek[week] ?? 0) + performedVolume(set);
    if (first == null || week.isBefore(first)) first = week;
  }
  final start = from == null ? first : startOfWeek(from);
  if (start == null) return const [];
  final result = <WeekVolume>[];
  final last = startOfWeek(now);
  for (var week = start; !week.isAfter(last); week = _nextWeek(week)) {
    result.add(WeekVolume(week, byWeek[week] ?? 0));
  }
  return result;
}

/// Monday of the following week. Calendar arithmetic, safe across DST.
DateTime _nextWeek(DateTime week) =>
    DateTime(week.year, week.month, week.day + 7);

/// Number of consecutive weeks with at least one session, counting back
/// from this week (or last week, if nothing was done yet this week).
int activeWeekStreak(Iterable<DateTime> sessionDates, DateTime now) {
  final weeks = sessionDates.map(startOfWeek).toSet();
  var week = startOfWeek(now);
  if (!weeks.contains(week)) {
    week = DateTime(week.year, week.month, week.day - 7);
  }
  var streak = 0;
  while (weeks.contains(week)) {
    streak++;
    week = DateTime(week.year, week.month, week.day - 7);
  }
  return streak;
}

/// One point per session of an exercise.
class ExercisePoint extends Equatable {
  const ExercisePoint({
    required this.date,
    required this.sessionId,
    required this.volumeKg,
    this.maxWeightKg,
    this.bestOneRepMaxKg,
    this.maxReps,
  });

  final DateTime date;
  final String sessionId;
  final double? maxWeightKg;
  final double? bestOneRepMaxKg;
  final double volumeKg;
  final int? maxReps;

  @override
  List<Object?> get props => [
    date,
    sessionId,
    maxWeightKg,
    bestOneRepMaxKg,
    volumeKg,
    maxReps,
  ];
}

/// Curve of an exercise: max weight, best estimated 1RM and volume per
/// session, oldest first. Warm-ups excluded.
List<ExercisePoint> exerciseSeries(
  Iterable<PerformedSet> sets,
  String exerciseId,
) {
  final points = <ExercisePoint>[];
  for (final MapEntry(key: sessionId, value: session) in setsBySession(
    sets,
    exerciseId,
  ).entries) {
    final working = session.where((s) => !s.isWarmup).toList();
    if (working.isEmpty) continue;
    final weights = working.map((s) => s.weightKg).whereType<double>();
    final oneRms = working
        .map((s) => estimatedOneRepMax(s.weightKg, s.reps))
        .whereType<double>();
    final reps = working.map((s) => s.reps).whereType<int>();
    points.add(
      ExercisePoint(
        date: session.first.sessionStartedAt,
        sessionId: sessionId,
        maxWeightKg: weights.isEmpty ? null : weights.reduce(math.max),
        bestOneRepMaxKg: oneRms.isEmpty ? null : oneRms.reduce(math.max),
        volumeKg: totalVolume(working),
        maxReps: reps.isEmpty ? null : reps.reduce(math.max),
      ),
    );
  }
  points.sort((a, b) => a.date.compareTo(b.date));
  return points;
}

/// Exercise ids ordered by number of sessions (most done first).
List<String> topExercises(Iterable<PerformedSet> sets, {int? limit}) {
  final sessions = <String, Set<String>>{};
  for (final set in sets) {
    (sessions[set.exerciseId] ??= {}).add(set.sessionId);
  }
  final ids = sessions.keys.toList()
    ..sort((a, b) => sessions[b]!.length.compareTo(sessions[a]!.length));
  return limit == null ? ids : ids.take(limit).toList();
}

/// A record beaten in a past session.
class RecordEvent extends Equatable {
  const RecordEvent({
    required this.exerciseId,
    required this.type,
    required this.set,
  });

  final String exerciseId;
  final RecordType type;
  final PerformedSet set;

  DateTime get date => set.sessionStartedAt;

  @override
  List<Object?> get props => [exerciseId, type, set];
}

/// Every record beaten, session by session, oldest first: each session is
/// compared with the sessions before it. One event per exercise, kind and
/// session (the best set).
List<RecordEvent> recordHistory(
  List<PerformedSet> sets,
  Map<String, TrackingType> trackingTypes,
) {
  final events = <RecordEvent>[];
  final bySession = <String, List<PerformedSet>>{};
  final order = <String>[];
  for (final set in sets) {
    final list = bySession[set.sessionId];
    if (list == null) {
      order.add(set.sessionId);
      bySession[set.sessionId] = [set];
    } else {
      list.add(set);
    }
  }
  final past = <String, List<PerformedSet>>{};
  for (final sessionId in order) {
    final session = bySession[sessionId]!;
    final byExercise = <String, List<PerformedSet>>{};
    for (final set in session) {
      (byExercise[set.exerciseId] ??= []).add(set);
    }
    for (final MapEntry(key: exerciseId, value: done) in byExercise.entries) {
      final records = PersonalRecords.fromSets(past[exerciseId] ?? const []);
      final type = trackingTypes[exerciseId] ?? TrackingType.weightReps;
      final best = <RecordType, PerformedSet>{};
      final soFar = <PerformedSet>[];
      for (final set in done) {
        soFar.add(set);
        final hits = records.beatenBy(
          set: SetValues(
            reps: set.reps,
            weightKg: set.weightKg,
            isWarmup: set.isWarmup,
          ),
          trackingType: type,
          sessionVolumeKg: totalVolume(soFar),
        );
        for (final hit in hits) {
          best[hit] = set;
        }
      }
      for (final MapEntry(key: hit, value: set) in best.entries) {
        events.add(RecordEvent(exerciseId: exerciseId, type: hit, set: set));
      }
      (past[exerciseId] ??= []).addAll(done);
    }
  }
  return events;
}

/// Duration, volume and record count of a finished session.
class SessionStats extends Equatable {
  const SessionStats({
    required this.duration,
    required this.volumeKg,
    required this.setCount,
    required this.recordCount,
  });

  final Duration duration;
  final double volumeKg;
  final int setCount;
  final int recordCount;

  @override
  List<Object?> get props => [duration, volumeKg, setCount, recordCount];
}

SessionStats sessionStats(SessionDetails details, {required int recordCount}) {
  final session = details.session;
  final end = session.endedAt ?? session.startedAt;
  final seconds =
      end.difference(session.startedAt).inSeconds - session.pausedSeconds;
  var volume = 0.0;
  var count = 0;
  for (final exercise in details.exercises) {
    for (final set in exercise.sets) {
      if (set.completedAt == null) continue;
      count++;
      volume += setVolume(
        weightKg: set.weightKg,
        reps: set.reps,
        isWarmup: set.isWarmup,
      );
    }
  }
  return SessionStats(
    duration: Duration(seconds: math.max(0, seconds)),
    volumeKg: volume,
    setCount: count,
    recordCount: recordCount,
  );
}

/// Tracking type of each exercise, for [recordHistory].
Map<String, TrackingType> trackingTypesOf(Iterable<Exercise> exercises) => {
  for (final exercise in exercises)
    exercise.id: TrackingType.fromKey(exercise.trackingType),
};
