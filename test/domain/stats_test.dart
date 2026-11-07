import 'package:endelea/domain/models/exercise_enums.dart';
import 'package:endelea/domain/models/session_models.dart';
import 'package:endelea/domain/progress/personal_records.dart';
import 'package:endelea/domain/progress/stats.dart';
import 'package:flutter_test/flutter_test.dart';

/// Ten sessions, every Monday and Thursday from Monday 2 November 2026:
/// bench 3 × 8 starting at 60 kg (+2.5 kg each session), squat 3 × 5 at
/// 100 kg every other session.
List<PerformedSet> tenSessions() {
  final sets = <PerformedSet>[];
  for (var i = 0; i < 10; i++) {
    final week = i ~/ 2;
    final date = DateTime(2026, 11, 2 + week * 7 + (i.isEven ? 0 : 3), 18);
    final id = 's$i';
    for (var s = 0; s < 3; s++) {
      sets.add(
        PerformedSet(
          setId: '$id-b$s',
          sessionId: id,
          sessionStartedAt: date,
          exerciseId: 'bench',
          setIndex: s,
          isWarmup: false,
          reps: 8,
          weightKg: 60 + 2.5 * i,
        ),
      );
    }
    if (i.isEven) {
      for (var s = 0; s < 3; s++) {
        sets.add(
          PerformedSet(
            setId: '$id-q$s',
            sessionId: id,
            sessionStartedAt: date,
            exerciseId: 'squat',
            setIndex: s,
            isWarmup: false,
            reps: 5,
            weightKg: 100,
          ),
        );
      }
    }
  }
  return sets;
}

void main() {
  final sets = tenSessions();

  group('with ten test sessions', () {
    test('bench curve matches a manual calculation', () {
      final series = exerciseSeries(sets, 'bench');
      expect(series, hasLength(10));
      for (var i = 0; i < 10; i++) {
        final weight = 60 + 2.5 * i;
        expect(series[i].maxWeightKg, weight);
        // Epley: weight × (1 + 8 / 30).
        expect(series[i].bestOneRepMaxKg, closeTo(weight * 38 / 30, 1e-9));
        expect(series[i].volumeKg, closeTo(weight * 8 * 3, 1e-9));
        expect(series[i].maxReps, 8);
      }
    });

    test('squat curve has one point every other session', () {
      final series = exerciseSeries(sets, 'squat');
      expect(series, hasLength(5));
      expect(series.every((p) => p.volumeKg == 1500), isTrue);
    });

    test('records: bench beats weight, 1RM and volume every time', () {
      final events = recordHistory(sets, const {
        'bench': TrackingType.weightReps,
        'squat': TrackingType.weightReps,
      });
      final bench = events.where((e) => e.exerciseId == 'bench').toList();
      // Nothing the first time, then three records in each of 9 sessions.
      expect(bench, hasLength(27));
      expect(
        bench.where((e) => e.type == RecordType.maxWeight).last.set.weightKg,
        82.5,
      );
      // The squat never changes: no record.
      expect(events.where((e) => e.exerciseId == 'squat'), isEmpty);
    });

    test('weekly volume', () {
      final weeks = weeklyVolume(sets, DateTime(2026, 12, 6));
      expect(weeks, hasLength(5));
      // Week 1: bench 60 and 62.5 kg (3 × 8 each) + squat 1500.
      expect(weeks.first.weekStart, DateTime(2026, 11, 2));
      expect(weeks.first.volumeKg, closeTo((60 + 62.5) * 24 + 1500, 1e-9));
    });

    test('weekly volume from a date includes empty weeks', () {
      final weeks = weeklyVolume(
        sets,
        DateTime(2026, 12, 20),
        from: DateTime(2026, 11, 30),
      );
      expect(weeks.map((w) => w.weekStart.day), [30, 7, 14]);
      expect(weeks.last.volumeKg, 0);
    });

    test('top exercises by number of sessions', () {
      expect(topExercises(sets), ['bench', 'squat']);
      expect(topExercises(sets, limit: 1), ['bench']);
    });
  });

  group('activeWeekStreak', () {
    final dates = [
      DateTime(2026, 11, 2),
      DateTime(2026, 11, 10),
      DateTime(2026, 11, 18),
    ];

    test('counts consecutive weeks up to this week', () {
      expect(activeWeekStreak(dates, DateTime(2026, 11, 19)), 3);
    });

    test('still counts when this week is not done yet', () {
      expect(activeWeekStreak(dates, DateTime(2026, 11, 24)), 3);
    });

    test('broken by an empty week', () {
      expect(activeWeekStreak(dates, DateTime(2026, 12, 3)), 0);
      expect(activeWeekStreak(const [], DateTime(2026, 12, 3)), 0);
    });
  });

  test('periods', () {
    final now = DateTime(2026, 11, 21, 10);
    expect(ProgressPeriod.weeks4.start(now), DateTime(2026, 10, 26));
    expect(ProgressPeriod.months3.start(now), DateTime(2026, 8, 21));
    expect(ProgressPeriod.year.start(now), DateTime(2025, 11, 21));
    expect(ProgressPeriod.all.start(now), isNull);
  });
}
