import 'package:flutter/material.dart';

import '../app/store_scope.dart';
import '../widgets/workout_summary_card.dart';
import 'workout_detail_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = StoreScope.of(context).history;
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: history.isEmpty
          ? const _EmptyHistory()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) => WorkoutSummaryCard(
                workout: history[index],
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        WorkoutDetailScreen(workout: history[index]),
                  ),
                ),
              ),
            ),
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
