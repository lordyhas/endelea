import 'package:flutter/material.dart';

import '../app/store_scope.dart';
import '../utils/format.dart';
import '../widgets/workout_summary_card.dart';
import 'workout_detail_screen.dart';

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
    final now = DateTime.now();
    final children = <Widget>[];
    DateTime? currentWeek;
    for (final workout in history) {
      final week = _weekOf(workout.startedAt);
      if (week != currentWeek) {
        currentWeek = week;
        children.add(
          Padding(
            padding: EdgeInsets.only(top: children.isEmpty ? 0 : 12, bottom: 8),
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
          ? const _EmptyHistory()
          : ListView(padding: const EdgeInsets.all(16), children: children),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history, size: 48),
          SizedBox(height: 8),
          Text('No workout yet'),
          Text('Finished workouts will show up here'),
        ],
      ),
    );
  }
}
