import 'package:flutter/widgets.dart';

import '../data/template_store.dart';

/// Exposes the [TemplateStore] to the widget tree and rebuilds dependents
/// when templates change.
class TemplateScope extends InheritedNotifier<TemplateStore> {
  const TemplateScope({
    super.key,
    required TemplateStore templates,
    required super.child,
  }) : super(notifier: templates);

  static TemplateStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<TemplateScope>();
    assert(scope != null, 'No TemplateScope found in context');
    return scope!.notifier!;
  }
}
