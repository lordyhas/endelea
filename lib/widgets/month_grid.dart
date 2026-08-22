import 'package:flutter/material.dart';

import '../data/workout_calendar.dart';

/// Days of a month in a Monday-first grid, highlighting days with workouts.
class MonthGrid extends StatelessWidget {
  const MonthGrid({
    super.key,
    required this.calendar,
    this.selectedDay,
    this.today,
    this.onDayTap,
  });

  final WorkoutCalendar calendar;
  final int? selectedDay;

  /// Today, outlined when it falls in the shown month.
  final DateTime? today;
  final ValueChanged<int>? onDayTap;

  static const _weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final month = calendar.month;
    final todayDay =
        today != null &&
            today!.year == month.year &&
            today!.month == month.month
        ? today!.day
        : null;
    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (final day in _weekdays)
          Center(child: Text(day, style: theme.textTheme.labelMedium)),
        for (var i = 0; i < calendar.leadingBlanks; i++) const SizedBox(),
        for (var day = 1; day <= calendar.daysInMonth; day++)
          _DayCell(
            day: day,
            count: calendar.workoutsOn(day).length,
            selected: day == selectedDay,
            today: day == todayDay,
            scheme: scheme,
            onTap: onDayTap == null ? null : () => onDayTap!(day),
          ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.count,
    required this.selected,
    required this.today,
    required this.scheme,
    this.onTap,
  });

  final int day;
  final int count;
  final bool selected;
  final bool today;
  final ColorScheme scheme;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final active = count > 0;
    return Padding(
      padding: const EdgeInsets.all(3),
      child: Material(
        color: selected
            ? scheme.primary
            : active
            ? scheme.primaryContainer
            : Colors.transparent,
        shape: CircleBorder(
          side: today
              ? BorderSide(color: scheme.primary, width: 2)
              : BorderSide.none,
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Center(
            child: Text(
              '$day',
              style: TextStyle(
                fontWeight: active ? FontWeight.bold : null,
                color: selected
                    ? scheme.onPrimary
                    : active
                    ? scheme.onPrimaryContainer
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
