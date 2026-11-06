import 'dart:async';

import 'package:endelea/data/database.dart';
import 'package:endelea/data/repositories/exercise_repository.dart';
import 'package:endelea/domain/models/exercise_enums.dart';
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
  const ExerciseDetailLoaded(this.exercise);

  final Exercise exercise;

  @override
  List<Object?> get props => [exercise];
}

final class ExerciseDetailNotFound extends ExerciseDetailState {
  const ExerciseDetailNotFound();
}

/// Exercise detail (PLAN.md §8.5).
class ExerciseDetailCubit extends Cubit<ExerciseDetailState> {
  ExerciseDetailCubit(this._exercises, this.exerciseId)
    : super(const ExerciseDetailLoading()) {
    _subscription = _exercises
        .watchById(exerciseId)
        .listen(
          (exercise) => emit(
            exercise == null
                ? const ExerciseDetailNotFound()
                : ExerciseDetailLoaded(exercise),
          ),
        );
  }

  final ExerciseRepository _exercises;
  final String exerciseId;
  late final StreamSubscription<Exercise?> _subscription;

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
    await super.close();
  }
}
