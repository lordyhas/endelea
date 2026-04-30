import 'package:flutter/widgets.dart';

import '../data/workout_store.dart';

/// Exposes the [WorkoutStore] to the widget tree and rebuilds dependents
/// when it changes.
class StoreScope extends InheritedNotifier<WorkoutStore> {
  const StoreScope({
    super.key,
    required WorkoutStore store,
    required super.child,
  }) : super(notifier: store);

  static WorkoutStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<StoreScope>();
    assert(scope != null, 'No StoreScope found in context');
    return scope!.notifier!;
  }
}
