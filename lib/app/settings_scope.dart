import 'package:flutter/widgets.dart';

import '../data/settings_store.dart';

/// Exposes the [SettingsStore] to the widget tree and rebuilds dependents
/// when a preference changes.
class SettingsScope extends InheritedNotifier<SettingsStore> {
  const SettingsScope({
    super.key,
    required SettingsStore settings,
    required super.child,
  }) : super(notifier: settings);

  static SettingsStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<SettingsScope>();
    assert(scope != null, 'No SettingsScope found in context');
    return scope!.notifier!;
  }
}
