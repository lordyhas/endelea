import 'dart:async';

import 'package:endelea/data/repositories/program_repository.dart';
import 'package:endelea/domain/models/program_models.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class ProgramEditorState extends Equatable {
  const ProgramEditorState();

  @override
  List<Object?> get props => [];
}

final class ProgramEditorLoading extends ProgramEditorState {
  const ProgramEditorLoading();
}

final class ProgramEditorLoaded extends ProgramEditorState {
  const ProgramEditorLoaded(this.details);

  final ProgramDetails details;

  @override
  List<Object?> get props => [details];
}

/// The program was deleted (here or from another device).
final class ProgramEditorNotFound extends ProgramEditorState {
  const ProgramEditorNotFound();
}

/// Program editor: name, description, days (PLAN.md §8.3).
class ProgramEditorCubit extends Cubit<ProgramEditorState> {
  ProgramEditorCubit(this._repository, this.programId)
    : super(const ProgramEditorLoading()) {
    _subscription = _repository
        .watchDetails(programId)
        .listen(
          (details) => emit(
            details == null
                ? const ProgramEditorNotFound()
                : ProgramEditorLoaded(details),
          ),
        );
  }

  final ProgramRepository _repository;
  final String programId;
  late final StreamSubscription<ProgramDetails?> _subscription;

  Future<void> update({required String name, String? description}) =>
      _repository.updateProgram(
        programId,
        name: name,
        description: description,
      );

  Future<String> addDay(String name) => _repository.addDay(programId, name);

  Future<void> renameDay(String dayId, String name) =>
      _repository.renameDay(dayId, name);

  Future<void> deleteDay(String dayId) => _repository.deleteDay(dayId);

  /// [newIndex] is the final position of the day.
  Future<void> moveDay(int oldIndex, int newIndex) async {
    final current = state;
    if (current is ProgramEditorLoaded && oldIndex != newIndex) {
      // Show the new order right away; the database stream confirms it.
      final days = [...current.details.days];
      days.insert(newIndex, days.removeAt(oldIndex));
      emit(
        ProgramEditorLoaded(
          ProgramDetails(program: current.details.program, days: days),
        ),
      );
    }
    await _repository.moveDay(programId, oldIndex, newIndex);
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    await super.close();
  }
}
