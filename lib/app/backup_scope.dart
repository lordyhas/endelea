import 'package:flutter/widgets.dart';

import '../data/sync/backup_service.dart';

/// Exposes the [BackupService], when there is one, and rebuilds dependents
/// while a backup runs.
class BackupScope extends InheritedNotifier<BackupService> {
  const BackupScope({
    super.key,
    required BackupService? backup,
    required super.child,
  }) : super(notifier: backup);

  /// Returns null when the app was started without cloud backup.
  static BackupService? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<BackupScope>()?.notifier;
}
