import 'package:flutter/material.dart';

import '../app/app_info.dart';
import '../app/settings_scope.dart';
import '../app/store_scope.dart';
import '../data/workout_stats.dart';
import '../utils/format.dart';
import '../widgets/stat_card.dart';
import '../widgets/week_strip.dart';
import '../widgets/workout_summary_card.dart';
import 'active_workout_screen.dart';
import 'start_workout_sheet.dart';
import 'workout_detail_screen.dart';

/// First tab: weekly progress and recent workouts.
class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  static String _greeting(DateTime now) {
    if (now.hour < 12) return 'Good morning';
    if (now.hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final active = store.active;
    final stats = WorkoutStats(store.history);
    final settings = SettingsScope.of(context).settings;
    final unit = settings.weightUnit;
    final goal = settings.weeklyGoal;
    final goalReached = stats.workoutsThisWeek >= goal;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text(AppInfo.name)),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(formatDay(stats.now), style: theme.textTheme.labelLarge),
          Text(switch (stats.workoutsThisWeek) {
            0 => '${_greeting(stats.now)}, ready to train?',
            _ when goalReached => '${_greeting(stats.now)}, goal reached!',
            _ => '${_greeting(stats.now)}, keep going!',
          }, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 16),
          WeekStrip(activity: stats.weekActivity, today: stats.now),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: goalReached ? Icons.emoji_events : Icons.flag_outlined,
                  value: '${stats.workoutsThisWeek}/$goal',
                  label: 'Weekly goal',
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
            const Text('Tap Start workout below to log your first session.')
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
        label: Text(active == null ? 'Start workout' : 'Resume workout'),
      ),
    );
  }
}
