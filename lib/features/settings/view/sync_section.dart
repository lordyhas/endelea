import 'package:endelea/core/l10n/formatters.dart';
import 'package:endelea/core/l10n/l10n.dart';
import 'package:endelea/core/theme/app_spacing.dart';
import 'package:endelea/core/widgets/buttons.dart';
import 'package:endelea/core/widgets/feedback.dart';
import 'package:endelea/features/settings/bloc/sync_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// The sync state shown by a [SyncStatusChip].
SyncStatus syncStatusOf(SyncState state) => switch (state) {
  SyncDisabled() => SyncStatus.disabled,
  SyncInProgress() => SyncStatus.syncing,
  SyncUpToDate() => SyncStatus.upToDate,
  SyncFailed() => SyncStatus.error,
};

/// Settings › Sync: connect Google Drive, state, sync now, sign out.
class SyncSection extends StatelessWidget {
  const SyncSection({super.key});

  Future<void> _signOut(BuildContext context) async {
    final l10n = context.l10n;
    final bloc = context.read<SyncBloc>();
    final confirmed = await ConfirmSheet.show(
      context,
      title: l10n.syncDisconnect,
      message: l10n.syncDisconnectMessage,
      confirmLabel: l10n.syncDisconnect,
    );
    if (confirmed) bloc.add(const SyncSignOutRequested());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bloc = context.read<SyncBloc>();
    return BlocConsumer<SyncBloc, SyncState>(
      listenWhen: (a, b) => b is SyncDisabled && b.signInFailed,
      listener: (context, state) =>
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(l10n.syncSignInFailed))),
      builder: (context, state) {
        switch (state) {
          case SyncDisabled():
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ListTile(
                  leading: const Icon(PhosphorIconsRegular.cloudSlash),
                  title: Text(l10n.googleDrive),
                  subtitle: Text(l10n.syncConnectHint),
                ),
                Padding(
                  padding: AppSpacing.screenPadding,
                  child: SecondaryButton(
                    label: l10n.syncConnect,
                    icon: PhosphorIconsRegular.cloudArrowUp,
                    expand: true,
                    onPressed: () => bloc.add(const SyncSignInRequested()),
                  ),
                ),
              ],
            );
          case SyncConnected(:final account, :final lastSyncAt):
            final last = lastSyncAt == null
                ? l10n.syncNever
                : l10n.syncLastSync(
                    '${l10n.shortDate(lastSyncAt)} ${l10n.time(lastSyncAt)}',
                  );
            final error = Theme.of(context).colorScheme.error;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ListTile(
                  leading: const Icon(PhosphorIconsRegular.cloudCheck),
                  title: Text(l10n.googleDrive),
                  subtitle: Text('${account.email}\n$last'),
                  isThreeLine: true,
                  trailing: SyncStatusChip(status: syncStatusOf(state)),
                ),
                ListTile(
                  enabled: state is! SyncInProgress,
                  leading: const Icon(PhosphorIconsRegular.arrowsClockwise),
                  title: Text(l10n.syncNow),
                  onTap: () => bloc.add(const SyncRequested(SyncReason.manual)),
                ),
                ListTile(
                  leading: Icon(PhosphorIconsRegular.signOut, color: error),
                  title: Text(
                    l10n.syncDisconnect,
                    style: TextStyle(color: error),
                  ),
                  onTap: () => _signOut(context),
                ),
              ],
            );
        }
      },
    );
  }
}

/// Triggers a sync when the app comes back to the foreground (the bloc
/// skips it if the last sync is recent).
class SyncLifecycleListener extends StatefulWidget {
  const SyncLifecycleListener({required this.child, super.key});

  final Widget child;

  @override
  State<SyncLifecycleListener> createState() => _SyncLifecycleListenerState();
}

class _SyncLifecycleListenerState extends State<SyncLifecycleListener> {
  AppLifecycleListener? _listener;

  @override
  void initState() {
    super.initState();
    _listener = AppLifecycleListener(
      onResume: () =>
          context.read<SyncBloc>().add(const SyncRequested(SyncReason.resumed)),
    );
  }

  @override
  void dispose() {
    _listener?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
