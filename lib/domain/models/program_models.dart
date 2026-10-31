import 'package:endelea/data/database.dart';
import 'package:equatable/equatable.dart';

/// A program with what the list screen needs.
class ProgramSummary extends Equatable {
  const ProgramSummary({
    required this.program,
    required this.dayCount,
    this.lastSessionAt,
  });

  final Program program;
  final int dayCount;
  final DateTime? lastSessionAt;

  @override
  List<Object?> get props => [program, dayCount, lastSessionAt];
}

/// A program day with the number of planned exercises.
class ProgramDaySummary extends Equatable {
  const ProgramDaySummary({required this.day, required this.exerciseCount});

  final ProgramDay day;
  final int exerciseCount;

  @override
  List<Object?> get props => [day, exerciseCount];
}

class ProgramDetails extends Equatable {
  const ProgramDetails({required this.program, required this.days});

  final Program program;
  final List<ProgramDaySummary> days;

  @override
  List<Object?> get props => [program, days];
}

/// A planned exercise joined with its catalog entry.
class PlannedExercise extends Equatable {
  const PlannedExercise({required this.plan, required this.exercise});

  final ProgramExercise plan;
  final Exercise exercise;

  @override
  List<Object?> get props => [plan, exercise];
}

class ProgramDayDetails extends Equatable {
  const ProgramDayDetails({
    required this.program,
    required this.day,
    required this.exercises,
  });

  final Program program;
  final ProgramDay day;
  final List<PlannedExercise> exercises;

  @override
  List<Object?> get props => [program, day, exercises];
}

/// Editable targets of a planned exercise.
class ExerciseTargets extends Equatable {
  const ExerciseTargets({
    required this.sets,
    required this.restSeconds,
    this.repsMin,
    this.repsMax,
    this.weightKg,
    this.durationSeconds,
    this.notes,
  });

  final int sets;
  final int? repsMin;
  final int? repsMax;
  final double? weightKg;
  final int? durationSeconds;
  final int restSeconds;
  final String? notes;

  @override
  List<Object?> get props => [
    sets,
    repsMin,
    repsMax,
    weightKg,
    durationSeconds,
    restSeconds,
    notes,
  ];
}
