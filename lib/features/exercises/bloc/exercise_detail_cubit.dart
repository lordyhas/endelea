import 'dart:async';

import 'package:endelea/data/database.dart';
import 'package:endelea/data/repositories/exercise_repository.dart';
import 'package:endelea/data/repositories/session_repository.dart';
import 'package:endelea/domain/models/exercise_enums.dart';
import 'package:endelea/domain/models/session_models.dart';
import 'package:endelea/domain/progress/personal_records.dart';
import 'package:endelea/domain/progress/stats.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class ExerciseDetailState extends Equatable {
  const ExerciseDetailState();

  @override
  List<Object?> get props => [];
}

final class ExerciseDetailLoading extends ExerciseDetailState {
  const ExerciseDetailLoading();
}

final class ExerciseDetailLoaded extends ExerciseDetailState {
  const ExerciseDetailLoaded({
    required this.exercise,
    this.records = PersonalRecords.empty,
    this.series = const [],
    this.sessions = const [],
  });

  final Exercise exercise;
  final PersonalRecords records;

  /// One point per session, oldest first.
  final List<ExercisePoint> series;

  /// Sets of each session that included the exercise, most recent first.
  final List<List<PerformedSet>> sessions;

  @override
  List<Object?> get props => [exercise, records, series, sessions];
}

final class ExerciseDetailNotFound extends ExerciseDetailState {
  const ExerciseDetailNotFound();
}

/// Exercise detail (PLAN.md §8.5).
class ExerciseDetailCubit extends Cubit<ExerciseDetailState> {
  ExerciseDetailCubit(this._exercises, this._sessions, this.exerciseId)
    : super(const ExerciseDetailLoading()) {
    _subscription = _exercises.watchById(exerciseId).listen((exercise) {
      _exercise = exercise;
      _exerciseLoaded = true;
      _emit();
    });
    _setsSubscription = _sessions.watchPerformedSets().listen((sets) {
      _sets = sets.where((s) => s.exerciseId == exerciseId).toList();
      _emit();
    });
  }

  final ExerciseRepository _exercises;
  final SessionRepository _sessions;
  final String exerciseId;
  late final StreamSubscription<Exercise?> _subscription;
  late final StreamSubscription<List<PerformedSet>> _setsSubscription;

  Exercise? _exercise;
  bool _exerciseLoaded = false;
  List<PerformedSet> _sets = const [];

  void _emit() {
    if (!_exerciseLoaded || isClosed) return;
    final exercise = _exercise;
    if (exercise == null) {
      emit(const ExerciseDetailNotFound());
      return;
    }
    final bySession = setsBySession(_sets, exerciseId);
    emit(
      ExerciseDetailLoaded(
        exercise: exercise,
        records: PersonalRecords.fromSets(_sets),
        series: exerciseSeries(_sets, exerciseId),
        sessions: bySession.values.toList().reversed.toList(),
      ),
    );
  }

  Future<void> update({
    required String name,
    required MuscleGroup muscleGroup,
    required Equipment equipment,
    required TrackingType trackingType,
  }) {
    return _exercises.updateCustom(
      exerciseId,
      name: name,
      muscleGroup: muscleGroup,
      equipment: equipment,
      trackingType: trackingType,
    );
  }

  Future<void> delete() => _exercises.delete(exerciseId);

  @override
  Future<void> close() async {
    await _subscription.cancel();
    await _setsSubscription.cancel();
    await super.close();
  }
}
