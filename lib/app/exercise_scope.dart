import 'package:flutter/widgets.dart';

import '../data/exercise_store.dart';

/// Exposes the [ExerciseStore] to the widget tree and rebuilds dependents
/// when exercises are added or removed.
class ExerciseScope extends InheritedNotifier<ExerciseStore> {
  const ExerciseScope({
    super.key,
    required ExerciseStore exercises,
    required super.child,
  }) : super(notifier: exercises);

  static ExerciseStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ExerciseScope>();
    assert(scope != null, 'No ExerciseScope found in context');
    return scope!.notifier!;
  }
}
