import 'dart:async';

import 'package:endelea/core/utils/clock.dart';
import 'package:endelea/data/database.dart';
import 'package:endelea/data/repositories/body_repository.dart';
import 'package:endelea/data/repositories/exercise_repository.dart';
import 'package:endelea/data/repositories/session_repository.dart';
import 'package:endelea/domain/models/session_models.dart';
import 'package:endelea/domain/progress/stats.dart';
import 'package:endelea/domain/progress/volume.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// An exercise and how many sessions included it.
class ExerciseUsage extends Equatable {
  const ExerciseUsage(this.exercise, this.sessionCount);

  final Exercise exercise;
  final int sessionCount;

  @override
  List<Object?> get props => [exercise, sessionCount];
}

sealed class ProgressState extends Equatable {
  const ProgressState();

  @override
  List<Object?> get props => [];
}

final class ProgressLoading extends ProgressState {
  const ProgressLoading();
}

final class ProgressLoaded extends ProgressState {
  const ProgressLoaded({
    required this.period,
    required this.sessionCount,
    required this.volumeKg,
    required this.recordCount,
    required this.weeks,
    required this.topExercises,
    this.latestBody,
  });

  final ProgressPeriod period;
  final int sessionCount;
  final double volumeKg;
  final int recordCount;
  final List<WeekVolume> weeks;
  final List<ExerciseUsage> topExercises;
  final BodyMeasurement? latestBody;

  bool get isEmpty => sessionCount == 0;

  @override
  List<Object?> get props => [
    period,
    sessionCount,
    volumeKg,
    recordCount,
    weeks,
    topExercises,
    latestBody,
  ];
}

/// Progress over a period (PLAN.md §8.9).
class ProgressCubit extends Cubit<ProgressState> {
  ProgressCubit({
    required SessionRepository sessions,
    required this.exercises,
    required BodyRepository body,
    required this.clock,
  }) : super(const ProgressLoading()) {
    _setsSubscription = sessions.watchPerformedSets().listen((sets) async {
      _sets = sets;
      _exerciseList = await exercises.getAll();
      _emit();
    });
    _bodySubscription = body.watchAll().listen((measurements) {
      _latestBody = measurements.lastOrNull;
      _emit();
    });
  }

  final ExerciseRepository exercises;
  final Clock clock;
  late final StreamSubscription<List<PerformedSet>> _setsSubscription;
  late final StreamSubscription<List<BodyMeasurement>> _bodySubscription;

  List<PerformedSet>? _sets;
  List<Exercise> _exerciseList = const [];
  BodyMeasurement? _latestBody;
  ProgressPeriod _period = ProgressPeriod.weeks4;

  void setPeriod(ProgressPeriod period) {
    _period = period;
    _emit();
  }

  void _emit() {
    final all = _sets;
    if (all == null || isClosed) return;
    final now = clock.now();
    final start = _period.start(now);
    final sets = start == null
        ? all
        : all.where((s) => !s.sessionStartedAt.isBefore(start)).toList();
    final byId = {for (final e in _exerciseList) e.id: e};
    final records = recordHistory(
      all,
      trackingTypesOf(_exerciseList),
    ).where((e) => start == null || !e.date.isBefore(start)).length;
    final sessionsPerExercise = <String, Set<String>>{};
    for (final set in sets) {
      (sessionsPerExercise[set.exerciseId] ??= {}).add(set.sessionId);
    }
    emit(
      ProgressLoaded(
        period: _period,
        sessionCount: sets.map((s) => s.sessionId).toSet().length,
        volumeKg: totalVolume(sets),
        recordCount: records,
        weeks: weeklyVolume(sets, now, from: start),
        topExercises: [
          for (final id in topExercises(sets, limit: 8))
            if (byId[id] != null)
              ExerciseUsage(byId[id]!, sessionsPerExercise[id]!.length),
        ],
        latestBody: _latestBody,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _setsSubscription.cancel();
    await _bodySubscription.cancel();
    await super.close();
  }
}
