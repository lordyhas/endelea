import 'dart:async';

import 'package:endelea/data/repositories/program_repository.dart';
import 'package:endelea/domain/models/exercise_enums.dart';
import 'package:endelea/domain/models/program_models.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class DayEditorState extends Equatable {
  const DayEditorState();

  @override
  List<Object?> get props => [];
}

final class DayEditorLoading extends DayEditorState {
  const DayEditorLoading();
}

final class DayEditorLoaded extends DayEditorState {
  const DayEditorLoaded(this.day);

  final ProgramDayDetails day;

  @override
  List<Object?> get props => [day];
}

final class DayEditorNotFound extends DayEditorState {
  const DayEditorNotFound();
}

/// Day editor: planned exercises and their targets (PLAN.md §8.4).
class DayEditorCubit extends Cubit<DayEditorState> {
  DayEditorCubit(
    this._repository,
    this.dayId, {
    required this.defaultRestSeconds,
  }) : super(const DayEditorLoading()) {
    _subscription = _repository
        .watchDay(dayId)
        .listen(
          (day) => emit(
            day == null ? const DayEditorNotFound() : DayEditorLoaded(day),
          ),
        );
  }

  final ProgramRepository _repository;
  final String dayId;
  final int defaultRestSeconds;
  late final StreamSubscription<ProgramDayDetails?> _subscription;

  /// Default targets of a newly added exercise.
  ExerciseTargets defaultTargets(TrackingType type) => ExerciseTargets(
    sets: 3,
    repsMin: type.usesReps ? 8 : null,
    repsMax: type.usesReps ? 12 : null,
    durationSeconds: type == TrackingType.duration ? 60 : null,
    restSeconds: defaultRestSeconds,
  );

  /// Adds exercises in the given order, each with the defaults of its
  /// tracking type.
  Future<void> addExercises(Map<String, TrackingType> exercises) async {
    for (final MapEntry(key: id, value: type) in exercises.entries) {
      await _repository.addExercises(dayId, [
        id,
      ], defaults: defaultTargets(type));
    }
  }

  Future<void> updateTargets(String plannedId, ExerciseTargets targets) =>
      _repository.updateTargets(plannedId, targets);

  Future<void> remove(String plannedId) =>
      _repository.removePlannedExercise(plannedId);

  Future<void> rename(String name) => _repository.renameDay(dayId, name);

  /// [newIndex] is the final position of the exercise.
  Future<void> move(int oldIndex, int newIndex) async {
    final current = state;
    if (current is DayEditorLoaded && oldIndex != newIndex) {
      final exercises = [...current.day.exercises];
      exercises.insert(newIndex, exercises.removeAt(oldIndex));
      emit(
        DayEditorLoaded(
          ProgramDayDetails(
            program: current.day.program,
            day: current.day.day,
            exercises: exercises,
          ),
        ),
      );
    }
    await _repository.movePlannedExercise(dayId, oldIndex, newIndex);
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    await super.close();
  }
}
