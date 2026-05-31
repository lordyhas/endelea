import 'package:flutter/material.dart';

import '../models/exercise.dart';

/// Chips listing how many sets each muscle group got this week.
class MuscleSummary extends StatelessWidget {
  const MuscleSummary({super.key, required this.sets});

  final Map<MuscleGroup, int> sets;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Muscles this week', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final MapEntry(key: muscle, value: count) in sets.entries)
              Chip(
                label: Text('${muscle.label} · $count'),
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
      ],
    );
  }
}
