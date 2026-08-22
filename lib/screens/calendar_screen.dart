import 'package:flutter/material.dart';

import '../app/store_scope.dart';
import '../data/workout_calendar.dart';
import '../utils/format.dart';
import '../widgets/month_grid.dart';
import '../widgets/workout_summary_card.dart';
import 'workout_detail_screen.dart';

/// Month by month view of the days with a workout.
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key, this.now});

  /// Today, given by tests.
  final DateTime? now;

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late final DateTime _today = widget.now ?? DateTime.now();
  late DateTime _month = DateTime(_today.year, _today.month);
  int? _selectedDay;

  void _moveMonth(int delta) => setState(() {
    _month = DateTime(_month.year, _month.month + delta);
    _selectedDay = null;
  });

  void _selectDay(int day) =>
      setState(() => _selectedDay = _selectedDay == day ? null : day);

  @override
  Widget build(BuildContext context) {
    final history = StoreScope.of(context).history;
    final calendar = WorkoutCalendar(history, _month);
    final theme = Theme.of(context);
    final isCurrentMonth =
        _month.year == _today.year && _month.month == _today.month;
    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Previous month',
                onPressed: () => _moveMonth(-1),
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Text(
                  formatMonth(_month),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              IconButton(
                tooltip: 'Next month',
                onPressed: isCurrentMonth ? null : () => _moveMonth(1),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          const SizedBox(height: 8),
          MonthGrid(
            calendar: calendar,
            today: _today,
            selectedDay: _selectedDay,
            onDayTap: _selectDay,
          ),
          const SizedBox(height: 8),
          Text(
            '${plural(calendar.workoutCount, 'workout')} on '
            '${plural(calendar.activeDays, 'day')}',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          if (_selectedDay case final day?) ...[
            const SizedBox(height: 16),
            Text(
              formatDay(DateTime(_month.year, _month.month, day)),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (calendar.workoutsOn(day).isEmpty)
              const Text('Rest day')
            else
              for (final workout in calendar.workoutsOn(day)) ...[
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
          ],
        ],
      ),
    );
  }
}
