import 'dart:async';

import 'package:endelea/data/database.dart';
import 'package:endelea/data/repositories/body_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class BodyState extends Equatable {
  const BodyState();

  @override
  List<Object?> get props => [];
}

final class BodyLoading extends BodyState {
  const BodyLoading();
}

final class BodyLoaded extends BodyState {
  const BodyLoaded(this.measurements);

  /// Oldest first.
  final List<BodyMeasurement> measurements;

  @override
  List<Object?> get props => [measurements];
}

/// Body weight and body fat (PLAN.md §8.9).
class BodyCubit extends Cubit<BodyState> {
  BodyCubit(this._body) : super(const BodyLoading()) {
    _subscription = _body.watchAll().listen(
      (measurements) => emit(BodyLoaded(measurements)),
    );
  }

  final BodyRepository _body;
  late final StreamSubscription<List<BodyMeasurement>> _subscription;

  Future<void> add({
    required DateTime measuredAt,
    double? bodyWeightKg,
    double? bodyFatPercent,
  }) {
    return _body.add(
      measuredAt: measuredAt,
      bodyWeightKg: bodyWeightKg,
      bodyFatPercent: bodyFatPercent,
    );
  }

  Future<void> delete(String id) => _body.delete(id);

  @override
  Future<void> close() async {
    await _subscription.cancel();
    await super.close();
  }
}
