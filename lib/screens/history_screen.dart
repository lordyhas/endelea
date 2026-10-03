import 'package:flutter/material.dart';

import '../app/settings_scope.dart';
import '../app/store_scope.dart';
import '../data/workout_stats.dart';
import '../utils/format.dart';
import '../widgets/workout_summary_card.dart';
import 'workout_detail_screen.dart';

/// Finished workouts grouped by week, with all-time totals.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  static DateTime _weekOf(DateTime date) =>
      DateTime(date.year, date.month, date.day - (date.weekday - 1));

  static String _weekLabel(DateTime week, DateTime now) {
    final thisWeek = _weekOf(now);
    if (week == thisWeek) return 'This week';
    if (week == DateTime(thisWeek.year, thisWeek.month, thisWeek.day - 7)) {
      return 'Last week';
    }
    return 'Week of ${formatDay(week)}';
  }

  @override
  Widget build(BuildContext context) {
    final history = StoreScope.of(context).history;
    final unit = SettingsScope.of(context).settings.weightUnit;
    final now = DateTime.now();
    final stats = WorkoutStats(history, now: now);
    final children = <Widget>[
      if (history.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Card.filled(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  _Total('Workouts', '${stats.totalWorkouts}'),
                  _Total('Time', formatDuration(stats.totalTime)),
                  _Total('Volume', formatWeight(stats.totalVolume, unit)),
                ],
              ),
            ),
          ),
        ),
    ];
    DateTime? currentWeek;
    for (final workout in history) {
      final week = _weekOf(workout.startedAt);
      if (week != currentWeek) {
        final first = currentWeek == null;
        currentWeek = week;
        children.add(
          Padding(
            padding: EdgeInsets.only(top: first ? 0 : 12, bottom: 8),
            child: Text(
              _weekLabel(week, now),
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        );
      }
      children
        ..add(
          WorkoutSummaryCard(
            workout: workout,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => WorkoutDetailScreen(workout: workout),
              ),
            ),
          ),
        )
        ..add(const SizedBox(height: 12));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: history.isEmpty
          ? const _NoHistory()
          : ListView(padding: const EdgeInsets.all(16), children: children),
    );
  }
}

class _NoHistory extends StatelessWidget {
  const _NoHistory();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history, size: 48),
          SizedBox(height: 8),
          Text('No workouts yet'),
          Text('Finished workouts show up here'),
        ],
      ),
    );
  }
}

class _Total extends StatelessWidget {
  const _Total(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(value, style: theme.textTheme.titleMedium),
          Text(label, style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}
