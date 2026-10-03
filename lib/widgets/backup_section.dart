import 'package:flutter/material.dart';

import '../app/backup_scope.dart';
import '../app/settings_scope.dart';
import '../data/export.dart';
import '../data/sync/backup_service.dart';
import '../utils/format.dart';
import 'confirm_dialog.dart';
import 'show_message.dart';

/// Settings tiles to back up the data to the cloud and restore it.
class BackupSection extends StatelessWidget {
  const BackupSection({super.key});

  /// Runs [action] and tells the user when it fails, for example without
  /// network or when the sign in is cancelled.
  static Future<bool> _attempt(
    BuildContext context,
    String failure,
    Future<void> Function() action,
  ) async {
    try {
      await action();
      return true;
    } on Object catch (error) {
      debugPrint('$failure: $error');
      if (context.mounted) showMessage(context, failure);
      return false;
    }
  }

  Future<void> _backUp(BuildContext context, BackupService backup) async {
    final done = await _attempt(context, 'Backup failed', backup.backUp);
    if (!done || !context.mounted) return;
    showMessage(context, 'Backed up to ${backup.provider.name}');
  }

  Future<void> _restore(BuildContext context, BackupService backup) async {
    ExportedData? downloaded;
    final done = await _attempt(
      context,
      'Could not read the backup',
      () async => downloaded = await backup.download(),
    );
    final data = downloaded;
    if (!done || !context.mounted) return;
    if (data == null) {
      showMessage(context, 'No backup found');
      return;
    }
    final confirmed = await confirm(
      context,
      title: 'Restore backup?',
      message:
          '${data.history.length} workouts and ${data.routines.length} '
          'routines will replace your current data.',
      action: 'Restore',
    );
    if (!confirmed || !context.mounted) return;
    backup.restore(data);
    showMessage(context, 'Backup restored');
  }

  @override
  Widget build(BuildContext context) {
    final backup = BackupScope.maybeOf(context);
    if (backup == null) return const SizedBox.shrink();
    final provider = backup.provider;
    final settings = SettingsScope.of(context).settings;
    final lastBackupAt = settings.lastBackupAt;
    final enabled = !backup.busy;
    return Column(
      children: [
        if (backup.busy)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: LinearProgressIndicator(),
          ),
        ListTile(
          leading: const Icon(Icons.account_circle_outlined),
          title: Text(provider.account ?? 'Not signed in'),
          subtitle: Text(provider.name),
          trailing: provider.isSignedIn
              ? TextButton(
                  onPressed: enabled
                      ? () =>
                            _attempt(context, 'Sign out failed', backup.signOut)
                      : null,
                  child: const Text('Sign out'),
                )
              : FilledButton.tonal(
                  onPressed: enabled
                      ? () => _attempt(context, 'Sign in failed', backup.signIn)
                      : null,
                  child: const Text('Sign in'),
                ),
        ),
        ListTile(
          leading: const Icon(Icons.cloud_upload_outlined),
          title: const Text('Back up now'),
          subtitle: Text(
            lastBackupAt == null
                ? 'Never backed up'
                : 'Last backup ${formatDay(lastBackupAt)} '
                      'at ${formatTime(lastBackupAt)}',
          ),
          enabled: enabled,
          onTap: () => _backUp(context, backup),
        ),
        ListTile(
          leading: const Icon(Icons.cloud_download_outlined),
          title: Text('Restore from ${provider.name}'),
          enabled: enabled,
          onTap: () => _restore(context, backup),
        ),
      ],
    );
  }
}
