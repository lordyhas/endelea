import 'dart:async';

import 'package:endelea/core/l10n/l10n.dart';
import 'package:endelea/core/theme/app_colors.dart';
import 'package:endelea/core/theme/app_spacing.dart';
import 'package:endelea/core/theme/app_typography.dart';
import 'package:endelea/core/utils/units.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// A value with −/+ buttons (56 dp). Long press repeats; tapping the value
/// opens a numeric keyboard.
///
/// Works on display values; [WeightStepper] converts from and to kg.
class ValueStepper extends StatefulWidget {
  const ValueStepper({
    required this.value,
    required this.onChanged,
    required this.step,
    required this.label,
    required this.unitLabel,
    required this.semanticUnit,
    this.min = 0,
    this.max = 9999,
    this.decimals = 0,
    super.key,
  });

  final double value;
  final ValueChanged<double> onChanged;
  final double step;
  final double min;
  final double max;
  final int decimals;

  /// Field name, e.g. "Weight".
  final String label;

  /// Short unit shown under the value, e.g. "kg".
  final String unitLabel;

  /// Unit read by screen readers, e.g. "kilos".
  final String semanticUnit;

  @override
  State<ValueStepper> createState() => _ValueStepperState();
}

class _ValueStepperState extends State<ValueStepper> {
  Timer? _repeat;

  /// Last value sent, ahead of [ValueStepper.value] until the parent
  /// rebuilds (repeats can fire faster than frames).
  double? _sent;

  @override
  void didUpdateWidget(ValueStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sent = null;
  }

  @override
  void dispose() {
    _repeat?.cancel();
    super.dispose();
  }

  void _change(int direction) {
    final current = _sent ?? widget.value;
    final next = (current + direction * widget.step).clamp(
      widget.min,
      widget.max,
    );
    if (next == current) return;
    unawaited(HapticFeedback.selectionClick());
    // Round away floating-point drift (62.49999…).
    final rounded = (next * 100).roundToDouble() / 100;
    _sent = rounded;
    widget.onChanged(rounded);
  }

  void _startRepeat(int direction) {
    _repeat?.cancel();
    _repeat = Timer.periodic(
      const Duration(milliseconds: 120),
      (_) => _change(direction),
    );
  }

  void _stopRepeat() {
    _repeat?.cancel();
    _repeat = null;
  }

  Future<void> _edit() async {
    final locale = Localizations.localeOf(context).toString();
    final result = await showDialog<double>(
      context: context,
      builder: (context) => _ValueDialog(
        initial: formatDecimal(
          widget.value,
          locale,
          maxDecimals: widget.decimals,
        ),
        label: widget.label,
        unitLabel: widget.unitLabel,
        decimals: widget.decimals,
      ),
    );
    if (result != null) {
      widget.onChanged(result.clamp(widget.min, widget.max));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final text = formatDecimal(
      widget.value,
      locale,
      maxDecimals: widget.decimals,
    );

    return Semantics(
      container: true,
      label: l10n.stepperSemantics(widget.label, text, widget.semanticUnit),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.of(context).surfaceHigh,
          borderRadius: BorderRadius.circular(AppRadius.field),
        ),
        child: Row(
          children: [
            _StepButton(
              icon: PhosphorIconsRegular.minus,
              tooltip: l10n.stepperDecrease,
              onTap: () => _change(-1),
              onLongPressStart: () => _startRepeat(-1),
              onLongPressEnd: _stopRepeat,
            ),
            Expanded(
              child: ExcludeSemantics(
                child: InkWell(
                  onTap: _edit,
                  borderRadius: BorderRadius.circular(AppRadius.field),
                  child: SizedBox(
                    height: AppSizes.sessionTouch,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FittedBox(
                          child: Text(
                            text,
                            style: theme.textTheme.titleLarge.tabular,
                          ),
                        ),
                        Text(
                          widget.unitLabel,
                          style: theme.textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            _StepButton(
              icon: PhosphorIconsRegular.plus,
              tooltip: l10n.stepperIncrease,
              onTap: () => _change(1),
              onLongPressStart: () => _startRepeat(1),
              onLongPressEnd: _stopRepeat,
            ),
          ],
        ),
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    required this.onLongPressStart,
    required this.onLongPressEnd,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final VoidCallback onLongPressStart;
  final VoidCallback onLongPressEnd;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tooltip,
      child: Listener(
        // Stops the repeat however the long press ends.
        onPointerUp: (_) => onLongPressEnd(),
        onPointerCancel: (_) => onLongPressEnd(),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPressStart,
          borderRadius: BorderRadius.circular(AppRadius.field),
          child: SizedBox.square(
            dimension: AppSizes.sessionTouch,
            child: Icon(icon, size: AppSizes.icon),
          ),
        ),
      ),
    );
  }
}

class _ValueDialog extends StatefulWidget {
  const _ValueDialog({
    required this.initial,
    required this.label,
    required this.unitLabel,
    required this.decimals,
  });

  final String initial;
  final String label;
  final String unitLabel;
  final int decimals;

  @override
  State<_ValueDialog> createState() => _ValueDialogState();
}

class _ValueDialogState extends State<_ValueDialog> {
  late final _controller = TextEditingController(text: widget.initial)
    ..selection = TextSelection(
      baseOffset: 0,
      extentOffset: widget.initial.length,
    );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final raw = _controller.text.replaceAll(',', '.').replaceAll(' ', '');
    final value = double.tryParse(raw);
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(widget.label),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.numberWithOptions(
          decimal: widget.decimals > 0,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.allow(
            RegExp(widget.decimals > 0 ? '[0-9.,]' : '[0-9]'),
          ),
        ],
        style: Theme.of(context).textTheme.headlineSmall.tabular,
        decoration: InputDecoration(suffixText: widget.unitLabel),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        TextButton(onPressed: _submit, child: Text(l10n.ok)),
      ],
    );
  }
}

/// Weight in the user's unit, stored in kg.
class WeightStepper extends StatelessWidget {
  const WeightStepper({
    required this.weightKg,
    required this.onChanged,
    required this.unit,
    this.step,
    super.key,
  });

  final double weightKg;
  final ValueChanged<double> onChanged;
  final WeightUnit unit;

  /// Step in [unit]; defaults to 2.5 kg / 5 lb.
  final double? step;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ValueStepper(
      value: kgToDisplay(weightKg, unit),
      step: step ?? unit.defaultStep,
      decimals: unit == WeightUnit.kg ? 2 : 1,
      label: l10n.weightLabel,
      unitLabel: unit == WeightUnit.kg ? l10n.unitKg : l10n.unitLb,
      semanticUnit: unit == WeightUnit.kg ? l10n.unitKilos : l10n.unitPounds,
      onChanged: (value) => onChanged(displayToKg(value, unit)),
    );
  }
}

/// Repetitions, step 1.
class RepsStepper extends StatelessWidget {
  const RepsStepper({required this.reps, required this.onChanged, super.key});

  final int reps;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ValueStepper(
      value: reps.toDouble(),
      step: 1,
      max: 999,
      label: l10n.repsLabel,
      unitLabel: l10n.setColumnReps,
      semanticUnit: l10n.unitRepetitions,
      onChanged: (value) => onChanged(value.round()),
    );
  }
}

/// Duration in seconds, step 5 s (shown as m:ss).
class DurationStepper extends StatelessWidget {
  const DurationStepper({
    required this.seconds,
    required this.onChanged,
    this.step = 5,
    super.key,
  });

  final int seconds;
  final ValueChanged<int> onChanged;
  final int step;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ValueStepper(
      value: seconds.toDouble(),
      step: step.toDouble(),
      max: 24 * 3600,
      label: l10n.durationLabel,
      unitLabel: l10n.unitSeconds,
      semanticUnit: l10n.unitSeconds,
      onChanged: (value) => onChanged(value.round()),
    );
  }
}
