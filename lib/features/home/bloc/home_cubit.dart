import 'dart:async';

import 'package:endelea/core/utils/clock.dart';
import 'package:endelea/core/utils/date_utils.dart';
import 'package:endelea/data/database.dart';
import 'package:endelea/data/repositories/exercise_repository.dart';
import 'package:endelea/data/repositories/program_repository.dart';
import 'package:endelea/data/repositories/session_repository.dart';
import 'package:endelea/domain/models/session_models.dart';
import 'package:endelea/domain/progress/stats.dart';
import 'package:endelea/domain/progress/volume.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A recent record with its exercise.
class HomeRecord extends Equatable {
  const HomeRecord(this.exercise, this.event);

  final Exercise exercise;
  final RecordEvent event;

  @override
  List<Object?> get props => [exercise, event];
}

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

final class HomeLoading extends HomeState {
  const HomeLoading();
}

final class HomeLoaded extends HomeState {
  const HomeLoaded({
    required this.hasPrograms,
    required this.sessionsThisWeek,
    required this.volumeThisWeekKg,
    required this.weekStreak,
    required this.lastRecords,
    this.next,
  });

  final bool hasPrograms;

  /// Next day of the active program.
  final NextProgramDay? next;
  final int sessionsThisWeek;
  final double volumeThisWeekKg;
  final int weekStreak;

  /// Three most recent, newest first.
  final List<HomeRecord> lastRecords;

  @override
  List<Object?> get props => [
    hasPrograms,
    next?.program,
    next?.day,
    sessionsThisWeek,
    volumeThisWeekKg,
    weekStreak,
    lastRecords,
  ];
}

/// Home screen figures (PLAN.md §8.1).
class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required ProgramRepository programs,
    required SessionRepository sessions,
    required this.exercises,
    required this.clock,
  }) : super(const HomeLoading()) {
    _subscriptions = [
      programs.watchSummaries().listen((programs) {
        _hasPrograms = programs.isNotEmpty;
        _emit();
      }),
      programs.watchNextDay().listen((next) {
        _next = next;
        _nextLoaded = true;
        _emit();
      }),
      sessions.watchPerformedSets().listen((sets) async {
        _sets = sets;
        _exerciseList = await exercises.getAll();
        _emit();
      }),
    ];
  }

  final ExerciseRepository exercises;
  final Clock clock;
  late final List<StreamSubscription<Object?>> _subscriptions;

  bool? _hasPrograms;
  NextProgramDay? _next;
  bool _nextLoaded = false;
  List<PerformedSet>? _sets;
  List<Exercise> _exerciseList = const [];

  void _emit() {
    final hasPrograms = _hasPrograms;
    final sets = _sets;
    if (hasPrograms == null || sets == null || !_nextLoaded || isClosed) {
      return;
    }
    final now = clock.now();
    final week = startOfWeek(now);
    final thisWeek = sets
        .where((s) => !s.sessionStartedAt.isBefore(week))
        .toList();
    final byId = {for (final e in _exerciseList) e.id: e};
    final records = recordHistory(sets, trackingTypesOf(_exerciseList));
    emit(
      HomeLoaded(
        hasPrograms: hasPrograms,
        next: _next,
        sessionsThisWeek: thisWeek.map((s) => s.sessionId).toSet().length,
        volumeThisWeekKg: totalVolume(thisWeek),
        weekStreak: activeWeekStreak(sets.map((s) => s.sessionStartedAt), now),
        lastRecords: [
          for (final event in records.reversed.take(3))
            if (byId[event.exerciseId] != null)
              HomeRecord(byId[event.exerciseId]!, event),
        ],
      ),
    );
  }

  @override
  Future<void> close() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    await super.close();
  }
}
