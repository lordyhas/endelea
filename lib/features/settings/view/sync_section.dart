import 'package:endelea/core/l10n/l10n.dart';
import 'package:endelea/core/widgets/feedback.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Settings › Sync. Google Drive comes with the sync engine (phase 7).
class SyncSection extends StatelessWidget {
  const SyncSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(PhosphorIconsRegular.cloudSlash),
      title: Text(context.l10n.googleDrive),
      trailing: const SyncStatusChip(status: SyncStatus.disabled),
    );
  }
}
