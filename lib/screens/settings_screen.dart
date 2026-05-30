import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/app_info.dart';
import '../app/exercise_scope.dart';
import '../app/settings_scope.dart';
import '../app/store_scope.dart';
import '../app/template_scope.dart';
import '../data/export.dart';
import '../models/settings.dart';
import '../utils/format.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/show_message.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const _restOptions = [30, 60, 90, 120, 180];

  Future<void> _copyData(BuildContext context) async {
    final json = exportData(
      workouts: StoreScope.of(context),
      settings: SettingsScope.of(context),
      exercises: ExerciseScope.of(context),
      templates: TemplateScope.of(context),
    );
    await Clipboard.setData(ClipboardData(text: json));
    if (!context.mounted) return;
    showMessage(context, 'Data copied as JSON');
  }

  Future<void> _eraseAll(BuildContext context) async {
    final confirmed = await confirm(
      context,
      title: 'Erase all data?',
      message:
          'Your workouts, routines, custom exercises and settings will be '
          'deleted. This cannot be undone.',
      action: 'Erase',
    );
    if (!confirmed || !context.mounted) return;
    StoreScope.of(context).clear();
    TemplateScope.of(context).clear();
    ExerciseScope.of(context).clear();
    SettingsScope.of(context).reset();
    showMessage(context, 'All data erased');
  }

  @override
  Widget build(BuildContext context) {
    final store = SettingsScope.of(context);
    final settings = store.settings;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          const _SectionTitle('Appearance'),
          ListTile(
            title: const Text('Theme'),
            trailing: SegmentedButton<ThemeMode>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: Icon(Icons.brightness_auto_outlined),
                  tooltip: 'System',
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: Icon(Icons.light_mode_outlined),
                  tooltip: 'Light',
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: Icon(Icons.dark_mode_outlined),
                  tooltip: 'Dark',
                ),
              ],
              selected: {settings.themeMode},
              onSelectionChanged: (selection) =>
                  store.themeMode = selection.first,
            ),
          ),
          const _SectionTitle('Units'),
          ListTile(
            title: const Text('Weight'),
            trailing: SegmentedButton<WeightUnit>(
              segments: [
                for (final unit in WeightUnit.values)
                  ButtonSegment(value: unit, label: Text(unit.label)),
              ],
              selected: {settings.weightUnit},
              onSelectionChanged: (selection) =>
                  store.weightUnit = selection.first,
            ),
          ),
          const _SectionTitle('Rest timer'),
          ListTile(
            title: const Text('Default rest'),
            subtitle: const Text('Started when a set is completed'),
            trailing: Text(
              formatDuration(settings.restDuration, clock: true),
              style: theme.textTheme.titleMedium,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              children: [
                for (final seconds in _restOptions)
                  ChoiceChip(
                    label: Text(
                      formatDuration(Duration(seconds: seconds), clock: true),
                    ),
                    selected: settings.restDuration.inSeconds == seconds,
                    onSelected: (_) =>
                        store.restDuration = Duration(seconds: seconds),
                  ),
              ],
            ),
          ),
          const _SectionTitle('Data'),
          ListTile(
            leading: const Icon(Icons.copy_all_outlined),
            title: const Text('Copy data as JSON'),
            subtitle: const Text('Workouts, routines, exercises and settings'),
            onTap: () => _copyData(context),
          ),
          ListTile(
            leading: Icon(
              Icons.delete_forever_outlined,
              color: theme.colorScheme.error,
            ),
            title: Text(
              'Erase all data',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            onTap: () => _eraseAll(context),
          ),
          const _SectionTitle('About'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About ${AppInfo.name}'),
            subtitle: const Text('Version ${AppInfo.version}'),
            onTap: () => showAboutDialog(
              context: context,
              applicationName: AppInfo.name,
              applicationVersion: AppInfo.version,
              applicationLegalese: 'Track your workouts at the gym or at home.',
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
