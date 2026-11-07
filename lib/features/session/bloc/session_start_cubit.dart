import 'dart:async';

import 'package:endelea/data/repositories/program_repository.dart';
import 'package:endelea/domain/models/program_models.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class SessionStartState extends Equatable {
  const SessionStartState();

  @override
  List<Object?> get props => [];
}

final class SessionStartLoading extends SessionStartState {
  const SessionStartLoading();
}

final class SessionStartLoaded extends SessionStartState {
  const SessionStartLoaded({this.next, this.days = const []});

  /// Next day of the active program, null without one.
  final NextProgramDay? next;

  /// Every day of the active program.
  final List<ProgramDaySummary> days;

  @override
  List<Object?> get props => [next?.program, next?.day, days];
}

/// What can be started from the workout tab.
class SessionStartCubit extends Cubit<SessionStartState> {
  SessionStartCubit(this._programs) : super(const SessionStartLoading()) {
    _subscription = _programs
        .watchNextDay()
        .asyncMap((next) async {
          if (next == null) return const SessionStartLoaded();
          final details = await _programs.getDetails(next.program.id);
          return SessionStartLoaded(
            next: next,
            days: details?.days ?? const [],
          );
        })
        .listen(emit);
  }

  final ProgramRepository _programs;
  late final StreamSubscription<SessionStartLoaded> _subscription;

  @override
  Future<void> close() async {
    await _subscription.cancel();
    await super.close();
  }
}
