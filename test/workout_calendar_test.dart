import 'package:endelea/data/workout_calendar.dart';
import 'package:endelea/models/exercise.dart';
import 'package:endelea/models/workout.dart';
import 'package:flutter_test/flutter_test.dart';

Workout _workoutAt(DateTime date) => Workout(
  id: date.toIso8601String(),
  name: 'w',
  place: TrainingPlace.gym,
  startedAt: date,
  finishedAt: date.add(const Duration(hours: 1)),
);

void main() {
  final history = [
    _workoutAt(DateTime(2026, 8, 3, 18)),
    _workoutAt(DateTime(2026, 8, 3, 7)),
    _workoutAt(DateTime(2026, 8, 22, 9)),
    _workoutAt(DateTime(2026, 7, 31, 9)),
    _workoutAt(DateTime(2025, 8, 3, 9)),
  ];

  test('keeps only the workouts of the month, by day', () {
    final calendar = WorkoutCalendar(history, DateTime(2026, 8, 22));

    expect(calendar.month, DateTime(2026, 8));
    expect(calendar.workoutCount, 3);
    expect(calendar.activeDays, 2);
    expect(calendar.workoutsOn(3).map((w) => w.startedAt.hour), [7, 18]);
    expect(calendar.workoutsOn(4), isEmpty);
  });

  test('knows the month layout', () {
    // August 2026 starts on a Saturday.
    final august = WorkoutCalendar(history, DateTime(2026, 8));

    expect(august.daysInMonth, 31);
    expect(august.leadingBlanks, 5);
    expect(WorkoutCalendar([], DateTime(2028, 2)).daysInMonth, 29);
  });

  test('moves to the previous and next month across years', () {
    final january = WorkoutCalendar(history, DateTime(2026));

    expect(january.previous(history).month, DateTime(2025, 12));
    expect(january.next(history).month, DateTime(2026, 2));
    expect(
      WorkoutCalendar(
        history,
        DateTime(2026, 8),
      ).previous(history).workoutCount,
      1,
    );
  });
}
