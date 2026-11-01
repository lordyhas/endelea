import 'package:endelea/core/l10n/l10n.dart';
import 'package:endelea/core/theme/app_spacing.dart';
import 'package:endelea/core/theme/app_theme.dart';
import 'package:endelea/core/utils/units.dart';
import 'package:endelea/core/widgets/buttons.dart';
import 'package:endelea/core/widgets/cards.dart';
import 'package:endelea/core/widgets/feedback.dart';
import 'package:endelea/core/widgets/rest_timer.dart';
import 'package:endelea/core/widgets/set_row.dart';
import 'package:endelea/core/widgets/value_stepper.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Debug-only page showing every shared component in its states
/// (`/_gallery`).
class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  bool _dark = true;
  double _weightKg = 62.5;
  int _reps = 8;
  int _seconds = 45;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Theme(
      data: _dark ? AppTheme.dark : AppTheme.light,
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(l10n.galleryTitle),
            actions: [
              IconButton(
                tooltip: l10n.galleryToggleTheme,
                icon: Icon(
                  _dark ? PhosphorIconsRegular.sun : PhosphorIconsRegular.moon,
                ),
                onPressed: () => setState(() => _dark = !_dark),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              _Section('PrimaryActionButton', [
                PrimaryActionButton(label: l10n.start, onPressed: () {}),
                PrimaryActionButton(
                  label: l10n.start,
                  icon: PhosphorIconsRegular.play,
                  onPressed: null,
                ),
              ]),
              _Section('SecondaryButton', [
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    SecondaryButton(label: l10n.save, onPressed: () {}),
                    SecondaryButton(
                      label: l10n.cancel,
                      outlined: true,
                      onPressed: () {},
                    ),
                    SecondaryButton(
                      label: l10n.delete,
                      icon: PhosphorIconsRegular.trash,
                      destructive: true,
                      outlined: true,
                      onPressed: () {},
                    ),
                  ],
                ),
              ]),
              _Section('WeightStepper / RepsStepper / DurationStepper', [
                WeightStepper(
                  weightKg: _weightKg,
                  unit: WeightUnit.kg,
                  onChanged: (v) => setState(() => _weightKg = v),
                ),
                WeightStepper(
                  weightKg: _weightKg,
                  unit: WeightUnit.lb,
                  onChanged: (v) => setState(() => _weightKg = v),
                ),
                RepsStepper(
                  reps: _reps,
                  onChanged: (v) => setState(() => _reps = v),
                ),
                DurationStepper(
                  seconds: _seconds,
                  onChanged: (v) => setState(() => _seconds = v),
                ),
              ]),
              _Section('SetRow', [
                SetRowHeader(
                  valueLabel: l10n.unitKg,
                  secondaryLabel: l10n.setColumnReps,
                ),
                SetRow(
                  index: 1,
                  state: SetRowState.done,
                  isWarmup: true,
                  previous: '40 × 10',
                  value: '40',
                  secondary: '10',
                  onCheck: () {},
                ),
                SetRow(
                  index: 2,
                  state: SetRowState.done,
                  previous: '60 × 8',
                  value: '62,5',
                  secondary: '8',
                  onCheck: () {},
                ),
                SetRow(
                  index: 3,
                  state: SetRowState.current,
                  previous: '60 × 8',
                  value: '62,5',
                  secondary: '8',
                  onCheck: () {},
                ),
                SetRow(
                  index: 4,
                  state: SetRowState.pending,
                  value: '62,5',
                  secondary: '8',
                  onCheck: () {},
                ),
              ]),
              _Section('RestTimerBar', [
                RestTimerBar(
                  remaining: const Duration(seconds: 72),
                  total: const Duration(seconds: 90),
                  onMinus: () {},
                  onPlus: () {},
                  onSkip: () {},
                ),
              ]),
              _Section('RestTimerFullScreen', [
                SizedBox(
                  height: 480,
                  child: RestTimerFullScreen(
                    remaining: const Duration(seconds: 72),
                    total: const Duration(seconds: 90),
                    nextLabel:
                        '${l10n.setColumnSet} 3 · ${l10n.exercise_bench_press}',
                    onMinus: () {},
                    onPlus: () {},
                    onSkip: () {},
                  ),
                ),
              ]),
              _Section('ExerciseTile', [
                ExerciseTile(
                  name: l10n.exercise_bench_press,
                  subtitle: '${l10n.muscleChest} · ${l10n.equipmentBarbell}',
                  icon: PhosphorIconsRegular.barbell,
                  onTap: () {},
                ),
                ExerciseTile(
                  name: l10n.exercise_back_squat,
                  subtitle: '${l10n.muscleLegs} · ${l10n.equipmentBarbell}',
                  icon: PhosphorIconsRegular.sneakerMove,
                  selected: true,
                  onTap: () {},
                ),
              ]),
              _Section('ProgramCard', [
                ProgramCard(
                  name: 'Push / Pull / Legs',
                  dayCount: 3,
                  lastSession: '18 nov.',
                  isActive: true,
                  onStart: () {},
                  onTap: () {},
                ),
                ProgramCard(
                  name: 'Full body',
                  dayCount: 2,
                  lastSession: null,
                  isActive: false,
                  onTap: () {},
                ),
              ]),
              _Section('StatTile / PrBadge', [
                Row(
                  children: [
                    Expanded(
                      child: StatTile(label: l10n.repsLabel, value: '3'),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: StatTile(label: l10n.weightLabel, value: '12 450'),
                    ),
                  ],
                ),
                const Align(alignment: Alignment.centerLeft, child: PrBadge()),
              ]),
              _Section('EmptyState', [
                EmptyState(
                  icon: PhosphorIconsDuotone.listChecks,
                  title: l10n.emptyGalleryTitle,
                  message: l10n.emptyGalleryMessage,
                  action: SecondaryButton(label: l10n.start, onPressed: () {}),
                ),
              ]),
              _Section('ConfirmSheet', [
                Builder(
                  builder: (context) => SecondaryButton(
                    label: l10n.delete,
                    destructive: true,
                    onPressed: () => ConfirmSheet.show(
                      context,
                      title: l10n.delete,
                      message: l10n.emptyGalleryMessage,
                      confirmLabel: l10n.delete,
                    ),
                  ),
                ),
              ]),
              _Section('SyncStatusChip', [
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final status in SyncStatus.values)
                      SyncStatusChip(status: status),
                  ],
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title, this.children);

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: AppSpacing.sm),
          for (final child in children) ...[
            child,
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}
