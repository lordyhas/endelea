import 'package:endelea/core/l10n/formatters.dart';
import 'package:endelea/core/l10n/l10n.dart';
import 'package:endelea/core/theme/app_spacing.dart';
import 'package:endelea/core/utils/clock.dart';
import 'package:endelea/core/utils/units.dart';
import 'package:endelea/core/widgets/buttons.dart';
import 'package:endelea/core/widgets/charts.dart';
import 'package:endelea/core/widgets/feedback.dart';
import 'package:endelea/core/widgets/value_stepper.dart';
import 'package:endelea/data/database.dart';
import 'package:endelea/data/repositories/body_repository.dart';
import 'package:endelea/features/body/bloc/body_cubit.dart';
import 'package:endelea/features/settings/bloc/settings_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Body weight entries and curve (`/body`).
class BodyScreen extends StatelessWidget {
  const BodyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BodyCubit(context.read<BodyRepository>()),
      child: const BodyView(),
    );
  }
}

class BodyView extends StatelessWidget {
  const BodyView({super.key});

  Future<void> _add(BuildContext context, BodyMeasurement? last) async {
    final cubit = context.read<BodyCubit>();
    final clock = context.read<Clock>();
    final result = await showModalBottomSheet<_BodyEntry>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: context.read<SettingsCubit>(),
        child: _BodyEntrySheet(
          initialWeightKg: last?.bodyWeightKg ?? 75,
          initialFat: last?.bodyFatPercent,
        ),
      ),
    );
    if (result == null) return;
    await cubit.add(
      measuredAt: clock.now(),
      bodyWeightKg: result.weightKg,
      bodyFatPercent: result.fatPercent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final unit = context.select<SettingsCubit, WeightUnit>(
      (c) => c.settings.unit,
    );
    return BlocBuilder<BodyCubit, BodyState>(
      builder: (context, state) {
        final measurements = state is BodyLoaded
            ? state.measurements
            : const <BodyMeasurement>[];
        final weights = [
          for (final m in measurements)
            if (m.bodyWeightKg case final kg?)
              ChartPoint(m.measuredAt, kgToUnit(kg, unit)),
        ];
        return Scaffold(
          appBar: AppBar(title: Text(l10n.bodyWeightTitle)),
          body: switch (state) {
            BodyLoading() => const Center(child: CircularProgressIndicator()),
            BodyLoaded(measurements: []) => EmptyState(
              icon: PhosphorIconsDuotone.scales,
              title: l10n.bodyEmptyTitle,
              message: l10n.bodyEmptyMessage,
            ),
            BodyLoaded() => ListView(
              padding: const EdgeInsets.all(AppSpacing.screen),
              children: [
                if (weights.length > 1) ...[
                  ProgressLineChart(
                    points: weights,
                    semanticLabel: l10n.bodyWeightTitle,
                    formatValue: (v) =>
                        formatDecimal(v, l10n.localeName, maxDecimals: 0),
                    formatDate: l10n.shortDate,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
                for (final m in measurements.reversed)
                  Dismissible(
                    key: ValueKey(m.id),
                    direction: DismissDirection.endToStart,
                    background: ColoredBox(
                      color: theme.colorScheme.error,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.xl),
                          child: Icon(
                            PhosphorIconsRegular.trash,
                            semanticLabel: l10n.bodyMeasurementDelete,
                            color: theme.colorScheme.onError,
                          ),
                        ),
                      ),
                    ),
                    onDismissed: (_) => context.read<BodyCubit>().delete(m.id),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        m.bodyWeightKg == null
                            ? '–'
                            : l10n.weightWithUnit(m.bodyWeightKg!, unit),
                      ),
                      subtitle: Text(
                        [
                          l10n.longDate(m.measuredAt),
                          if (m.bodyFatPercent case final fat?)
                            l10n.bodyFatShort(
                              formatDecimal(fat, l10n.localeName),
                            ),
                        ].join(' · '),
                      ),
                    ),
                  ),
              ],
            ),
          },
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.all(AppSpacing.lg),
            child: PrimaryActionButton(
              label: l10n.bodyAdd,
              icon: PhosphorIconsRegular.plus,
              onPressed: () => _add(context, measurements.lastOrNull),
            ),
          ),
        );
      },
    );
  }
}

class _BodyEntry {
  const _BodyEntry(this.weightKg, this.fatPercent);

  final double weightKg;
  final double? fatPercent;
}

class _BodyEntrySheet extends StatefulWidget {
  const _BodyEntrySheet({required this.initialWeightKg, this.initialFat});

  final double initialWeightKg;
  final double? initialFat;

  @override
  State<_BodyEntrySheet> createState() => _BodyEntrySheetState();
}

class _BodyEntrySheetState extends State<_BodyEntrySheet> {
  late double _weightKg = widget.initialWeightKg;
  late double _fat = widget.initialFat ?? 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final unit = context.select<SettingsCubit, WeightUnit>(
      (c) => c.settings.unit,
    );
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.bodyAdd, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.lg),
            WeightStepper(
              weightKg: _weightKg,
              unit: unit,
              step: unit == WeightUnit.kg ? 0.5 : 1,
              onChanged: (kg) => setState(() => _weightKg = kg),
            ),
            const SizedBox(height: AppSpacing.sm),
            ValueStepper(
              value: _fat,
              step: 0.5,
              max: 70,
              decimals: 1,
              label: l10n.bodyFat,
              unitLabel: '%',
              semanticUnit: '%',
              onChanged: (v) => setState(() => _fat = v),
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryActionButton(
              label: l10n.save,
              onPressed: () =>
                  Navigator.of(context)
                      .pop(_BodyEntry(_weightKg, _fat > 0 ? _fat : null)),
            ),
          ],
        ),
      ),
    );
  }
}
