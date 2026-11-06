import 'dart:async';

import 'package:endelea/data/repositories/program_repository.dart';
import 'package:endelea/domain/models/program_models.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class ProgramsState extends Equatable {
  const ProgramsState();

  @override
  List<Object?> get props => [];
}

final class ProgramsLoading extends ProgramsState {
  const ProgramsLoading();
}

final class ProgramsLoaded extends ProgramsState {
  const ProgramsLoaded(this.programs);

  final List<ProgramSummary> programs;

  @override
  List<Object?> get props => [programs];
}

final class ProgramsError extends ProgramsState {
  const ProgramsError();
}

/// Program list (PLAN.md §8.2).
class ProgramsCubit extends Cubit<ProgramsState> {
  ProgramsCubit(this._repository) : super(const ProgramsLoading()) {
    _subscription = _repository.watchSummaries().listen(
      (programs) => emit(ProgramsLoaded(programs)),
      onError: (Object _) => emit(const ProgramsError()),
    );
  }

  final ProgramRepository _repository;
  late final StreamSubscription<List<ProgramSummary>> _subscription;

  Future<String> create(String name) => _repository.createProgram(name);

  Future<void> rename(String id, String name, {String? description}) =>
      _repository.updateProgram(id, name: name, description: description);

  Future<String> duplicate(String id, {required String name}) =>
      _repository.duplicate(id, name: name);

  Future<void> activate(String id) => _repository.activate(id);

  Future<void> delete(String id) => _repository.deleteProgram(id);

  @override
  Future<void> close() async {
    await _subscription.cancel();
    await super.close();
  }
}
