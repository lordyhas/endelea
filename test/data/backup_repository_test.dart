import 'dart:convert';

import 'package:endelea/data/database.dart';
import 'package:endelea/data/repositories/backup_repository.dart';
import 'package:endelea/data/repositories/body_repository.dart';
import 'package:endelea/data/repositories/exercise_repository.dart';
import 'package:endelea/data/repositories/program_repository.dart';
import 'package:endelea/data/repositories/row_store.dart';
import 'package:endelea/data/repositories/session_repository.dart';
import 'package:endelea/domain/models/exercise_enums.dart';
import 'package:endelea/domain/models/program_models.dart';
import 'package:endelea/domain/models/session_models.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

/// A database with a program, a finished session, a custom exercise and a
/// body measurement.
Future<AppDatabase> filledDatabase(FakeClock clock, String device) async {
  final db = memoryDatabase();
  final stamp = testStamp(clock, device);
  final exercises = ExerciseRepository(db, stamp);
  await exercises.seedBuiltIns();
  final custom = await exercises.createCustom(
    name: 'Zercher',
    muscleGroup: MuscleGroup.legs,
    equipment: Equipment.barbell,
    trackingType: TrackingType.weightReps,
  );
  final programs = ProgramRepository(db, stamp);
  final program = await programs.createProgram('PPL', description: 'Push');
  final day = await programs.addDay(program, 'Push');
  await programs.addExercises(
    day,
    [builtInExerciseId('bench_press'), custom],
    defaults: const ExerciseTargets(
      sets: 3,
      repsMin: 8,
      repsMax: 12,
      weightKg: 62.5,
      restSeconds: 90,
    ),
  );
  final sessions = SessionRepository(db, stamp);
  final id = await sessions.start(
    programDayId: day,
    name: 'Push',
    plan: [
      PlannedSessionExercise(
        exerciseId: custom,
        restSeconds: 90,
        sets: const [SetValues(reps: 5, weightKg: 100.25)],
      ),
    ],
  );
  final set = (await sessions.getActive())!.exercises.single.sets.single;
  await sessions.completeSet(
    set.id,
    const SetValues(reps: 5, weightKg: 100.25),
    sessionId: id,
  );
  clock.advance(const Duration(minutes: 30));
  await sessions.finish(id, notes: 'Heavy');
  await BodyRepository(
    db,
    stamp,
  ).add(measuredAt: clock.now(), bodyWeightKg: 81.4, bodyFatPercent: 15.5);
  return db;
}

void main() {
  test(
    'export then import into an empty database gives the same data',
    () async {
      final clock = FakeClock();
      final source = await filledDatabase(clock, 'device-a');
      final json = await BackupRepository(
        source,
        RowStore(source),
      ).exportJson(clock.now());

      final target = memoryDatabase();
      await ExerciseRepository(
        target,
        testStamp(clock, 'device-b'),
      ).seedBuiltIns();
      final result = await BackupRepository(
        target,
        RowStore(target),
      ).importJson(json);
      expect(result.applied, greaterThan(5));

      final a = await RowStore(source).readAll();
      final b = await RowStore(target).readAll();
      for (final table in syncedTableNames) {
        final sortedA = [...a[table]!]..sort(_byId);
        final sortedB = [...b[table]!]..sort(_byId);
        expect(sortedB, sortedA, reason: table);
      }

      // The imported session reads back like the original.
      final history = await SessionRepository(
        target,
        testStamp(clock, 'device-b'),
      ).getHistory();
      expect(history.single.session.notes, 'Heavy');
      expect(history.single.exercises.single.sets.single.weightKg, 100.25);
      await source.close();
      await target.close();
    },
  );

  test('importing twice changes nothing', () async {
    final clock = FakeClock();
    final db = await filledDatabase(clock, 'device-a');
    final backup = BackupRepository(db, RowStore(db));
    final json = await backup.exportJson(clock.now());
    final again = await backup.importJson(json);
    expect(again.applied, 0);
    await db.close();
  });

  test('export format', () async {
    final clock = FakeClock();
    final db = await filledDatabase(clock, 'device-a');
    final json = jsonDecode(
      await BackupRepository(db, RowStore(db)).exportJson(clock.now()),
    ) as Map<String, Object?>;
    expect(json['format'], 'endelea-export');
    expect(json['formatVersion'], 1);
    final tables = json['tables']! as Map<String, Object?>;
    expect(tables.keys, containsAll(syncedTableNames));
    final sessions = tables['workout_sessions']! as List<Object?>;
    final session = sessions.single! as Map<String, Object?>;
    expect(session['updated_at'], isA<String>());
    expect(
      BackupRepository.fileName(DateTime(2026, 11, 21, 9)),
      'endelea-export-2026-11-21.json',
    );
    await db.close();
  });

  test('rejects other files', () async {
    final db = memoryDatabase();
    final backup = BackupRepository(db, RowStore(db));
    expect(
      () => backup.importJson('not json'),
      throwsA(isA<InvalidExportException>()),
    );
    expect(
      () => backup.importJson('{"format": "other"}'),
      throwsA(isA<InvalidExportException>()),
    );
    expect(
      () => backup.importJson(
        '{"format": "endelea-export", "formatVersion": 99}',
      ),
      throwsA(isA<InvalidExportException>()),
    );
    await db.close();
  });
}

int _byId(RawRow a, RawRow b) => '${a['id']}'.compareTo('${b['id']}');
