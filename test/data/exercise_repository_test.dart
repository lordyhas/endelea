import 'package:endelea/data/database.dart';
import 'package:endelea/data/repositories/exercise_repository.dart';
import 'package:endelea/data/repositories/write_stamp.dart';
import 'package:endelea/data/seed/exercises_seed.dart';
import 'package:endelea/domain/models/exercise_enums.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

void main() {
  late AppDatabase db;
  late FakeClock clock;
  late ExerciseRepository repo;

  setUp(() {
    db = memoryDatabase();
    clock = FakeClock();
    repo = ExerciseRepository(db, testStamp(clock));
  });

  tearDown(() => db.close());

  group('seedBuiltIns', () {
    test('inserts every built-in once', () async {
      expect(await repo.seedBuiltIns(), exerciseSeeds.length);
      expect(await repo.seedBuiltIns(), 0);
      expect(await repo.getAll(), hasLength(exerciseSeeds.length));
    });

    test('adds only new keys', () async {
      await repo.seedBuiltIns(exerciseSeeds.take(10).toList());
      expect(await repo.seedBuiltIns(), exerciseSeeds.length - 10);
    });

    test('does not bring back a deleted built-in', () async {
      await repo.seedBuiltIns();
      final benchId = builtInExerciseId('bench_press');
      await repo.delete(benchId);
      expect(await repo.seedBuiltIns(), 0);
      expect(await repo.getById(benchId), isNull);
    });

    test('uses the same id on every device', () async {
      await repo.seedBuiltIns();
      final bench = await repo.getById(builtInExerciseId('bench_press'));
      expect(bench?.builtInKey, 'bench_press');
      expect(bench?.isCustom, isFalse);
      expect(bench?.updatedAt, ExerciseRepository.seedTimestamp);
    });

    test('seed keys are unique', () {
      final keys = exerciseSeeds.map((s) => s.key).toSet();
      expect(keys, hasLength(exerciseSeeds.length));
    });
  });

  test('custom exercises are stamped and soft-deleted', () async {
    final id = await repo.createCustom(
      name: ' Zercher squat ',
      muscleGroup: MuscleGroup.legs,
      equipment: Equipment.barbell,
      trackingType: TrackingType.weightReps,
    );
    var row = await repo.getById(id);
    expect(row?.name, 'Zercher squat');
    expect(row?.isCustom, isTrue);
    expect(row?.lastModifiedBy, 'device-a');
    expect(row?.updatedAt, normalizeTimestamp(clock.now()));

    clock.advance(const Duration(minutes: 5));
    await repo.updateCustom(
      id,
      name: 'Zercher',
      muscleGroup: MuscleGroup.legs,
      equipment: Equipment.barbell,
      trackingType: TrackingType.weightReps,
    );
    row = await repo.getById(id);
    expect(row?.updatedAt, normalizeTimestamp(clock.now()));

    clock.advance(const Duration(minutes: 5));
    await repo.delete(id);
    expect(await repo.getById(id), isNull);
    final raw = await (db.select(
      db.exercises,
    )..where((t) => t.id.equals(id))).getSingle();
    expect(raw.deleted, isTrue);
    expect(raw.updatedAt, normalizeTimestamp(clock.now()));
  });
}
