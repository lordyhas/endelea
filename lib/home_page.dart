import 'package:flutter/material.dart';

import 'app/settings_scope.dart';
import 'app/store_scope.dart';
import 'data/workout_stats.dart';
import 'screens/active_workout_screen.dart';
import 'screens/history_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/start_workout_sheet.dart';
import 'screens/workout_detail_screen.dart';
import 'utils/format.dart';
import 'widgets/stat_card.dart';
import 'widgets/week_strip.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, this.title});

  final String? title;

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final active = store.active;
    final stats = WorkoutStats(store.history);
    final unit = SettingsScope.of(context).settings.weightUnit;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: 'Settings',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
            ),
            icon: const Icon(Icons.settings),
          ),
        ],
        title: Text(title ?? 'Endelea'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(formatDay(stats.now), style: theme.textTheme.labelLarge),
          Text('Keep going!', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 16),
          WeekStrip(activity: stats.weekActivity, today: stats.now),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.event_available,
                  value: '${stats.workoutsThisWeek}',
                  label: 'This week',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatCard(
                  icon: Icons.local_fire_department_outlined,
                  value: '${stats.streak} d',
                  label: 'Streak',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatCard(
                  icon: Icons.scale_outlined,
                  value: formatWeight(stats.volumeThisWeek, unit),
                  label: 'Volume',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Recent workouts', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          if (store.history.isEmpty)
            const Text('Start your first workout with the button below.')
          else
            for (final workout in store.history.take(3)) ...[
              WorkoutSummaryCard(
                workout: workout,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => WorkoutDetailScreen(workout: workout),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          const SizedBox(height: 80),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (active != null) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const ActiveWorkoutScreen(),
              ),
            );
          } else {
            StartWorkoutSheet.show(context);
          }
        },
        icon: Icon(active != null ? Icons.timer_outlined : Icons.play_arrow),
        label: Text(active != null ? 'Resume workout' : 'Start workout'),
      ),
    );
  }
}
