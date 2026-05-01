import 'package:flutter/material.dart';

/// Seven dots, Monday to Sunday, filled on days with a workout.
class WeekStrip extends StatelessWidget {
  const WeekStrip({super.key, required this.activity, required this.today});

  /// Workouts per weekday, Monday first.
  final List<int> activity;
  final DateTime today;

  static const _letters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (var i = 0; i < 7; i++)
          Column(
            children: [
              Text(
                _letters[i],
                style: TextStyle(
                  fontWeight: i == today.weekday - 1
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 6),
              CircleAvatar(
                radius: 14,
                backgroundColor: activity[i] > 0
                    ? scheme.primary
                    : scheme.surfaceContainerHighest,
                child: activity[i] > 0
                    ? Icon(Icons.check, size: 16, color: scheme.onPrimary)
                    : null,
              ),
            ],
          ),
      ],
    );
  }
}
