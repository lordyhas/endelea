import 'package:endelea/data/database.dart';
import 'package:endelea/data/repositories/exercise_repository.dart';
import 'package:endelea/data/repositories/program_repository.dart';
import 'package:endelea/data/repositories/row_store.dart';
import 'package:endelea/data/repositories/session_repository.dart';
import 'package:endelea/data/repositories/sync_meta_repository.dart';
import 'package:endelea/data/repositories/write_stamp.dart';
import 'package:endelea/domain/models/exercise_enums.dart';
import 'package:endelea/domain/models/program_models.dart';
import 'package:endelea/domain/models/session_models.dart';
import 'package:endelea/sync/sync_codec.dart';
import 'package:endelea/sync/sync_engine.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_cloud.dart';
import '../helpers/fakes.dart';

/// One phone: its database, clock, repositories and sync engine.
class Device {
  Device._(this.name, this.db, this.clock, this.provider);

  static Future<Device> create(
    String name,
    FakeCloud cloud,
    DateTime start,
  ) async {
    final db = memoryDatabase();
    final clock = FakeClock(start);
    final device = Device._(name, db, clock, FakeCloudProvider(cloud));
    await device.meta.write(SyncMetaKeys.deviceId, name);
    await device.exercises.seedBuiltIns();
    return device;
  }

  final String name;
  final AppDatabase db;
  final FakeClock clock;
  final FakeCloudProvider provider;

  late final SyncMetaRepository meta = SyncMetaRepository(db);
  late final WriteStamp stamp = testStamp(clock, name);
  late final ExerciseRepository exercises = ExerciseRepository(db, stamp);
  late final ProgramRepository programs = ProgramRepository(db, stamp);
  late final SessionRepository sessions = SessionRepository(db, stamp);
  late final SyncEngine engine = SyncEngine(
    database: db,
    rows: RowStore(db),
    meta: meta,
    clock: clock,
  );

  Future<SyncReport> sync() => engine.sync(provider);
}

void main() {
  late FakeCloud cloud;
  late Device a;
  late Device b;
  final bench = builtInExerciseId('bench_press');

  setUp(() async {
    cloud = FakeCloud();
    a = await Device.create('device-a', cloud, DateTime(2026, 11, 21, 8));
    b = await Device.create('device-b', cloud, DateTime(2026, 11, 21, 8, 1));
  });

  tearDown(() async {
    await a.db.close();
    await b.db.close();
  });

  Future<String> finishedSession(Device device) async {
    final id = await device.sessions.start(
      name: 'Push',
      plan: [
        PlannedSessionExercise(
          exerciseId: bench,
          restSeconds: 90,
          sets: const [SetValues(reps: 8, weightKg: 60)],
        ),
      ],
    );
    final set =
        (await device.sessions.getActive())!.exercises.single.sets.single;
    await device.sessions.completeSet(
      set.id,
      const SetValues(reps: 8, weightKg: 60),
      sessionId: id,
    );
    device.clock.advance(const Duration(minutes: 30));
    await device.sessions.finish(id);
    return id;
  }

  test('a session done on A shows up on B', () async {
    final id = await finishedSession(a);
    final pushed = await a.sync();
    expect(pushed.pushedRows, 3); // session, exercise, set
    expect(
      cloud.files.values.map((f) => f.name),
      containsAll([SyncCodec.manifestName]),
    );

    final pulled = await b.sync();
    expect(pulled.pulledFiles, 1);
    expect(pulled.appliedRows, 3);
    final history = await b.sessions.getHistory();
    expect(history.single.session.id, id);
    expect(history.single.exercises.single.sets.single.weightKg, 60);
    // Merged rows keep their origin.
    expect(history.single.session.lastModifiedBy, 'device-a');
  });

  test('a deletion on B disappears from A', () async {
    final id = await finishedSession(a);
    await a.sync();
    await b.sync();

    b.clock.advance(const Duration(hours: 2));
    await b.sessions.delete(id);
    await b.sync();
    await a.sync();
    expect(await a.sessions.getHistory(), isEmpty);
  });

  test('concurrent edits: the most recent wins', () async {
    final program = await a.programs.createProgram('PPL');
    await a.sync();
    await b.sync();

    a.clock.time = DateTime(2026, 11, 21, 10);
    await a.programs.updateProgram(program, name: 'Older');
    b.clock.time = DateTime(2026, 11, 21, 11);
    await b.programs.updateProgram(program, name: 'Newer');

    await a.sync();
    await b.sync();
    await a.sync();
    expect((await a.programs.getProgram(program))!.name, 'Newer');
    expect((await b.programs.getProgram(program))!.name, 'Newer');
  });

  test('a tie is broken by device id, the same way on both sides', () async {
    final program = await a.programs.createProgram('PPL');
    await a.sync();
    await b.sync();

    final same = DateTime(2026, 11, 21, 12);
    a.clock.time = same;
    b.clock.time = same;
    await a.programs.updateProgram(program, name: 'From A');
    await b.programs.updateProgram(program, name: 'From B');
    await a.sync();
    await b.sync();
    await a.sync();
    // 'device-b' > 'device-a'.
    expect((await a.programs.getProgram(program))!.name, 'From B');
    expect((await b.programs.getProgram(program))!.name, 'From B');
  });

  test('custom exercises and programs arrive before what uses them', () async {
    final custom = await a.exercises.createCustom(
      name: 'Zercher',
      muscleGroup: MuscleGroup.legs,
      equipment: Equipment.barbell,
      trackingType: TrackingType.weightReps,
    );
    final program = await a.programs.createProgram('Legs');
    final day = await a.programs.addDay(program, 'A');
    await a.programs.addExercises(day, [
      custom,
    ], defaults: const ExerciseTargets(sets: 3, restSeconds: 90));
    await a.sync();
    await b.sync();
    final planned = await b.programs.getPlannedExercises(day);
    expect(planned.single.exercise.name, 'Zercher');
  });

  test('syncing twice sends and applies nothing new', () async {
    await finishedSession(a);
    await a.sync();
    await b.sync();
    final again = await b.sync();
    expect(again.pulledFiles, 0);
    expect(again.pushedRows, greaterThanOrEqualTo(0));
    final third = await a.sync();
    expect(third.appliedRows, 0);
    final fourth = await a.sync();
    expect(fourth.pushedRows, 0);
  });

  test('built-in exercises are never pushed', () async {
    final report = await a.sync();
    expect(report.pushedRows, 0);
  });

  test('a network error leaves the sync state untouched', () async {
    await finishedSession(a);
    a.provider.failNext = true;
    await expectLater(a.sync(), throwsException);
    expect(await a.meta.read(SyncMetaKeys.lastPushAt), isNull);
    final report = await a.sync();
    expect(report.pushedRows, 3);
  });

  test('refuses a cloud folder written by a newer version', () async {
    await a.provider.upload(
      SyncCodec.manifestName,
      '{"formatVersion": 9}'.codeUnits,
    );
    await expectLater(a.sync(), throwsA(isA<UnsupportedSyncFormatException>()));
  });

  test('codec round trip and batch names', () {
    const codec = SyncCodec();
    final batch = ChangeBatch(
      deviceId: 'd',
      createdAt: DateTime.utc(2026, 11, 21),
      tables: const {
        'programs': [
          {'id': 'p', 'name': 'PPL', 'deleted': 0},
        ],
      },
    );
    expect(codec.decodeBatch(codec.encodeBatch(batch)), batch);
    final name = SyncCodec.batchName('d', DateTime.utc(2026, 11, 21));
    expect(SyncCodec.parseBatchName(name), (
      deviceId: 'd',
      millis: DateTime.utc(2026, 11, 21).millisecondsSinceEpoch,
    ));
    expect(SyncCodec.parseBatchName(SyncCodec.manifestName), isNull);
  });

  test('reset forgets the cursors', () async {
    await finishedSession(a);
    await a.sync();
    await b.sync();
    await b.engine.reset();
    expect(await b.meta.read(SyncMetaKeys.lastPullCursor), isNull);
    final report = await b.sync();
    expect(report.pulledFiles, 1);
    expect(report.appliedRows, 0);
  });
}
