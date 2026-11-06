import 'dart:async';

import 'package:endelea/data/database.dart';
import 'package:endelea/data/repositories/exercise_repository.dart';
import 'package:endelea/domain/models/exercise_enums.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class ExercisesState extends Equatable {
  const ExercisesState();

  @override
  List<Object?> get props => [];
}

final class ExercisesLoading extends ExercisesState {
  const ExercisesLoading();
}

final class ExercisesLoaded extends ExercisesState {
  const ExercisesLoaded({
    required this.all,
    required this.visible,
    this.query = '',
    this.muscleGroups = const {},
    this.equipment = const {},
  });

  final List<Exercise> all;

  /// [all] filtered by [query], [muscleGroups] and [equipment], sorted by
  /// displayed name.
  final List<Exercise> visible;
  final String query;
  final Set<MuscleGroup> muscleGroups;
  final Set<Equipment> equipment;

  bool get hasFilters =>
      query.isNotEmpty || muscleGroups.isNotEmpty || equipment.isNotEmpty;

  @override
  List<Object?> get props => [all, visible, query, muscleGroups, equipment];
}

/// Exercise library: search and filters (PLAN.md §8.5).
class ExercisesCubit extends Cubit<ExercisesState> {
  ExercisesCubit(this._repository, {required this.nameOf})
    : super(const ExercisesLoading()) {
    _subscription = _repository.watchAll().listen(_onExercises);
  }

  final ExerciseRepository _repository;

  /// Displayed (localized) name, used to search and sort.
  final String Function(Exercise) nameOf;
  late final StreamSubscription<List<Exercise>> _subscription;

  String _query = '';
  Set<MuscleGroup> _muscles = const {};
  Set<Equipment> _equipment = const {};
  List<Exercise> _all = const [];

  void _onExercises(List<Exercise> exercises) {
    _all = exercises;
    _emit();
  }

  void _emit() {
    final query = _normalize(_query);
    final visible =
        _all.where((e) {
          if (_muscles.isNotEmpty &&
              !_muscles.contains(MuscleGroup.fromKey(e.muscleGroup))) {
            return false;
          }
          if (_equipment.isNotEmpty &&
              !_equipment.contains(Equipment.fromKey(e.equipment))) {
            return false;
          }
          return query.isEmpty || _normalize(nameOf(e)).contains(query);
        }).toList()..sort(
          (a, b) => _normalize(nameOf(a)).compareTo(_normalize(nameOf(b))),
        );
    emit(
      ExercisesLoaded(
        all: _all,
        visible: visible,
        query: _query,
        muscleGroups: _muscles,
        equipment: _equipment,
      ),
    );
  }

  void search(String query) {
    _query = query;
    _emit();
  }

  void toggleMuscleGroup(MuscleGroup group) {
    _muscles = _toggle(_muscles, group);
    _emit();
  }

  void toggleEquipment(Equipment equipment) {
    _equipment = _toggle(_equipment, equipment);
    _emit();
  }

  void clearFilters() {
    _query = '';
    _muscles = const {};
    _equipment = const {};
    _emit();
  }

  /// Creates a custom exercise and returns it.
  Future<Exercise?> create({
    required String name,
    required MuscleGroup muscleGroup,
    required Equipment equipment,
    required TrackingType trackingType,
  }) async {
    final id = await _repository.createCustom(
      name: name,
      muscleGroup: muscleGroup,
      equipment: equipment,
      trackingType: trackingType,
    );
    return await _repository.getById(id);
  }

  static Set<T> _toggle<T>(Set<T> set, T value) =>
      set.contains(value) ? ({...set}..remove(value)) : {...set, value};

  /// Lower case without accents, so "developpe" finds "Développé".
  static String _normalize(String value) {
    const from = 'àâäáãåçéèêëíìîïñóòôöõúùûüýÿœæ';
    const to = 'aaaaaaceeeeiiiinooooouuuuyyoa';
    final lower = value.toLowerCase().trim();
    final buffer = StringBuffer();
    for (final char in lower.split('')) {
      final index = from.indexOf(char);
      buffer.write(index < 0 ? char : to[index]);
    }
    return buffer.toString();
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    await super.close();
  }
}
