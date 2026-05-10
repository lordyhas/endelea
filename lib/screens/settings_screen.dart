import 'package:flutter/material.dart';

import '../app/settings_scope.dart';
import '../models/settings.dart';
import '../utils/format.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const _restOptions = [30, 60, 90, 120, 180];

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
