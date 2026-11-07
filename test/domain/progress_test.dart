import 'package:endelea/domain/models/exercise_enums.dart';
import 'package:endelea/domain/models/session_models.dart';
import 'package:endelea/domain/progress/one_rep_max.dart';
import 'package:endelea/domain/progress/personal_records.dart';
import 'package:endelea/domain/progress/volume.dart';
import 'package:endelea/domain/session/session_planner.dart';
import 'package:flutter_test/flutter_test.dart';

PerformedSet performed(
  String session,
  int index, {
  double? weight,
  int? reps,
  bool warmup = false,
  String exercise = 'bench',
  int day = 1,
}) {
  return PerformedSet(
    setId: '$session-$exercise-$index',
    sessionId: session,
    sessionStartedAt: DateTime.utc(2026, 11, day),
    exerciseId: exercise,
    setIndex: index,
    isWarmup: warmup,
    reps: reps,
    weightKg: weight,
  );
}

void main() {
  group('estimatedOneRepMax (Epley)', () {
    test('weight × (1 + reps / 30)', () {
      expect(estimatedOneRepMax(100, 10), closeTo(133.33, 0.01));
      expect(estimatedOneRepMax(60, 8), closeTo(76, 0.001));
    });

    test('one rep is the weight itself', () {
      expect(estimatedOneRepMax(140, 1), 140);
    });

    test('only for 1 to 12 reps', () {
      expect(estimatedOneRepMax(100, 13), isNull);
      expect(estimatedOneRepMax(100, 0), isNull);
      expect(estimatedOneRepMax(null, 5), isNull);
      expect(estimatedOneRepMax(0, 5), isNull);
    });
  });

  group('volume', () {
    test('weight × reps, warm-ups excluded', () {
      expect(setVolume(weightKg: 60, reps: 8), 480);
      expect(setVolume(weightKg: 60, reps: 8, isWarmup: true), 0);
      expect(setVolume(weightKg: null, reps: 8), 0);
      expect(
        totalVolume([
          performed('a', 0, weight: 40, reps: 10, warmup: true),
          performed('a', 1, weight: 60, reps: 8),
          performed('a', 2, weight: 60, reps: 6),
        ]),
        840,
      );
    });
  });

  group('PersonalRecords', () {
    final history = [
      performed('a', 0, weight: 100, reps: 10, warmup: true),
      performed('a', 1, weight: 60, reps: 8),
      performed('a', 2, weight: 60, reps: 8),
      performed('b', 0, weight: 65, reps: 5, day: 3),
    ];
    final records = PersonalRecords.fromSets(history);

    test('built from working sets only', () {
      expect(records.maxWeightKg, 65);
      expect(records.bestOneRepMaxKg, closeTo(76, 0.001));
      expect(records.maxRepsAtWeight, {60.0: 8, 65.0: 5});
      expect(records.bestSessionVolumeKg, 960);
      expect(records.maxReps, 8);
    });

    test('a heavier set beats weight and 1RM', () {
      expect(
        records.beatenBy(
          set: const SetValues(weightKg: 70, reps: 5),
          trackingType: TrackingType.weightReps,
          sessionVolumeKg: 350,
        ),
        {RecordType.maxWeight, RecordType.estimatedOneRepMax},
      );
    });

    test('more reps at a known weight', () {
      expect(
        records.beatenBy(
          set: const SetValues(weightKg: 60, reps: 9),
          trackingType: TrackingType.weightReps,
          sessionVolumeKg: 540,
        ),
        {RecordType.repsAtWeight, RecordType.estimatedOneRepMax},
      );
    });

    test('session volume', () {
      expect(
        records.beatenBy(
          set: const SetValues(weightKg: 50, reps: 5),
          trackingType: TrackingType.weightReps,
          sessionVolumeKg: 1000,
        ),
        {RecordType.sessionVolume},
      );
    });

    test('nothing the first time, nothing for warm-ups', () {
      expect(
        PersonalRecords.empty.beatenBy(
          set: const SetValues(weightKg: 200, reps: 5),
          trackingType: TrackingType.weightReps,
          sessionVolumeKg: 1000,
        ),
        isEmpty,
      );
      expect(
        records.beatenBy(
          set: const SetValues(weightKg: 200, reps: 5, isWarmup: true),
          trackingType: TrackingType.weightReps,
          sessionVolumeKg: 1000,
        ),
        isEmpty,
      );
    });

    test('reps-only exercises count reps', () {
      final pullUps = PersonalRecords.fromSets([
        performed('a', 0, reps: 8, exercise: 'pull'),
      ]);
      expect(
        pullUps.beatenBy(
          set: const SetValues(reps: 9),
          trackingType: TrackingType.repsOnly,
          sessionVolumeKg: 0,
        ),
        {RecordType.repsAtWeight},
      );
    });

    test('previous sets come from the last session with the exercise', () {
      final sets = previousSets([
        ...history,
        performed('c', 0, weight: 100, reps: 5, exercise: 'squat', day: 5),
      ], 'bench');
      expect(sets.map((s) => s.setId), ['b-bench-0']);
      expect(previousSets(history, 'unknown'), isEmpty);
    });
  });

  group('progression suggestion', () {
    final topOfRange = [
      performed('a', 0, weight: 60, reps: 10),
      performed('a', 1, weight: 60, reps: 10),
    ];
    final missed = [
      performed('a', 0, weight: 60, reps: 10),
      performed('a', 1, weight: 60, reps: 9),
    ];

    test('+2.5 kg on a barbell when every set reached the top', () {
      expect(
        suggestWeightKg(
          lastSets: topOfRange,
          equipment: Equipment.barbell,
          enabled: true,
          targetRepsMax: 10,
        ),
        62.5,
      );
    });

    test('+1 kg on dumbbells and machines', () {
      for (final equipment in [Equipment.dumbbell, Equipment.machine]) {
        expect(
          suggestWeightKg(
            lastSets: topOfRange,
            equipment: equipment,
            enabled: true,
            targetRepsMax: 10,
          ),
          61,
        );
      }
    });

    test('same weight otherwise, or when disabled', () {
      expect(
        suggestWeightKg(
          lastSets: missed,
          equipment: Equipment.barbell,
          enabled: true,
          targetRepsMax: 10,
        ),
        60,
      );
      expect(
        suggestWeightKg(
          lastSets: topOfRange,
          equipment: Equipment.barbell,
          enabled: false,
          targetRepsMax: 10,
        ),
        60,
      );
    });

    test('the target without history', () {
      expect(
        suggestWeightKg(
          lastSets: const [],
          equipment: Equipment.barbell,
          enabled: true,
          targetRepsMax: 10,
          targetWeightKg: 40,
        ),
        40,
      );
    });
  });
}
