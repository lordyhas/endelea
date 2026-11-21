import 'package:endelea/core/app_info.dart';
import 'package:endelea/core/l10n/l10n.dart';
import 'package:endelea/core/theme/app_spacing.dart';
import 'package:endelea/core/utils/clock.dart';
import 'package:endelea/core/utils/files_bridge.dart';
import 'package:endelea/core/utils/units.dart';
import 'package:endelea/core/widgets/value_stepper.dart';
import 'package:endelea/data/repositories/backup_repository.dart';
import 'package:endelea/features/settings/bloc/data_transfer_cubit.dart';
import 'package:endelea/features/settings/bloc/settings_cubit.dart';
import 'package:endelea/features/settings/data/app_settings.dart';
import 'package:endelea/features/settings/view/sync_section.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Settings (PLAN.md §8.10).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DataTransferCubit(
        backup: context.read<BackupRepository>(),
        files: context.read<FilesBridge>(),
        clock: context.read<Clock>(),
      ),
      child: const SettingsView(),
    );
  }
}

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<SettingsCubit>();
    final settings = context.select<SettingsCubit, AppSettings>(
      (c) => c.settings,
    );
    final unit = settings.unit;
    final steps = unit == WeightUnit.kg
        ? const [1.0, 1.25, 2.5, 5.0]
        : const [2.5, 5.0, 10.0];

    return BlocListener<DataTransferCubit, DataTransferState>(
      listener: (context, state) {
        final message = switch (state) {
          DataExported() => l10n.exportDone,
          DataImported(:final rows) => l10n.importDone(rows),
          DataTransferFailed(invalidFile: true) => l10n.importInvalid,
          DataTransferFailed() => l10n.transferFailed,
          _ => null,
        };
        if (message != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(message)));
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.settingsTitle)),
        body: ListView(
          padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
          children: [
            _Header(l10n.settingsUnits),
            _Choice<WeightUnit>(
              label: l10n.settingsWeightUnit,
              values: WeightUnit.values,
              selected: unit,
              labelOf: (u) => u == WeightUnit.kg ? l10n.unitKg : l10n.unitLb,
              onSelected: cubit.setUnit,
            ),
            _Choice<double>(
              label: l10n.settingsWeightStep,
              values: steps,
              selected: steps.contains(settings.effectiveWeightStep)
                  ? settings.effectiveWeightStep
                  : unit.defaultStep,
              labelOf: (step) => formatDecimal(
                step,
                Localizations.localeOf(context).toString(),
                maxDecimals: 2,
              ),
              onSelected: cubit.setWeightStep,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                AppSpacing.sm,
                AppSpacing.screen,
                AppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.settingsDefaultRest),
                  const SizedBox(height: AppSpacing.sm),
                  DurationStepper(
                    seconds: settings.defaultRestSeconds,
                    step: 15,
                    label: l10n.settingsDefaultRest,
                    onChanged: cubit.setDefaultRest,
                  ),
                ],
              ),
            ),
            SwitchListTile(
              title: Text(l10n.settingsProgression),
              subtitle: Text(l10n.settingsProgressionHint),
              value: settings.progressionSuggestion,
              onChanged: (v) => cubit.setProgressionSuggestion(enabled: v),
            ),
            _Header(l10n.settingsAppearance),
            _Choice<ThemeMode>(
              label: l10n.settingsTheme,
              values: const [ThemeMode.system, ThemeMode.dark, ThemeMode.light],
              selected: settings.themeMode,
              labelOf: (mode) => switch (mode) {
                ThemeMode.system => l10n.themeSystem,
                ThemeMode.dark => l10n.themeDark,
                ThemeMode.light => l10n.themeLight,
              },
              onSelected: cubit.setThemeMode,
            ),
            _Choice<String>(
              label: l10n.settingsLanguage,
              values: const ['fr', 'en'],
              selected: settings.languageCode,
              labelOf: (code) =>
                  code == 'fr' ? l10n.languageFrench : l10n.languageEnglish,
              onSelected: cubit.setLanguage,
            ),
            _Header(l10n.settingsWorkout),
            SwitchListTile(
              title: Text(l10n.settingsKeepScreenOn),
              value: settings.keepScreenOn,
              onChanged: (v) => cubit.setKeepScreenOn(enabled: v),
            ),
            SwitchListTile(
              title: Text(l10n.settingsRestSound),
              value: settings.restSound,
              onChanged: (v) => cubit.setRestSound(enabled: v),
            ),
            SwitchListTile(
              title: Text(l10n.settingsRestVibration),
              value: settings.restVibration,
              onChanged: (v) => cubit.setRestVibration(enabled: v),
            ),
            _Header(l10n.settingsSync),
            const SyncSection(),
            _Header(l10n.settingsData),
            const _DataTiles(),
            _Header(l10n.settingsAbout),
            ListTile(
              leading: const Icon(PhosphorIconsRegular.info),
              title: Text(l10n.appTitle),
              subtitle: Text(
                '${l10n.aboutVersion(appVersion)} · ${l10n.appTagline}',
              ),
            ),
            ListTile(
              leading: const Icon(PhosphorIconsRegular.shieldCheck),
              title: Text(l10n.privacyPolicy),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const PrivacyPolicyScreen(),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(PhosphorIconsRegular.scroll),
              title: Text(l10n.licenses),
              onTap: () => showLicensePage(
                context: context,
                applicationName: l10n.appTitle,
                applicationVersion: appVersion,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        AppSpacing.xl,
        AppSpacing.screen,
        AppSpacing.xs,
      ),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }
}

/// A label and a segmented choice.
class _Choice<T> extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
  });

  final String label;
  final List<T> values;
  final T selected;
  final String Function(T) labelOf;
  final void Function(T) onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screen,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(label),
          const SizedBox(height: AppSpacing.sm),
          SegmentedButton<T>(
            segments: [
              for (final value in values)
                ButtonSegment(value: value, label: Text(labelOf(value))),
            ],
            selected: {selected},
            showSelectedIcon: false,
            onSelectionChanged: (selection) => onSelected(selection.first),
          ),
        ],
      ),
    );
  }
}

class _DataTiles extends StatelessWidget {
  const _DataTiles();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<DataTransferCubit>();
    final busy = context.select<DataTransferCubit, bool>(
      (c) => c.state is DataTransferBusy,
    );
    return Column(
      children: [
        ListTile(
          enabled: !busy,
          leading: const Icon(PhosphorIconsRegular.upload),
          title: Text(l10n.exportJson),
          subtitle: Text(l10n.exportJsonHint),
          onTap: () => cubit.export(shareTitle: l10n.exportShareTitle),
        ),
        ListTile(
          enabled: !busy,
          leading: const Icon(PhosphorIconsRegular.download),
          title: Text(l10n.importJson),
          subtitle: Text(l10n.importJsonHint),
          onTap: cubit.import,
        ),
      ],
    );
  }
}

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.privacyPolicy)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        child: Text(
          l10n.privacyBody,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
