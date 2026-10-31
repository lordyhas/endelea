import 'package:drift/drift.dart';
import 'package:endelea/data/database.dart';
import 'package:endelea/data/repositories/write_stamp.dart';
import 'package:endelea/data/seed/exercises_seed.dart';
import 'package:endelea/domain/models/exercise_enums.dart';
import 'package:uuid/uuid.dart';

/// Built-in exercises get the same id on every device (UUID v5 of their key),
/// so two devices that seeded independently converge when they sync.
String builtInExerciseId(String key) =>
    const Uuid().v5(Namespace.url.value, 'https://endelea.app/exercise/$key');

class ExerciseRepository {
  ExerciseRepository(this._db, this._stamp);

  final AppDatabase _db;
  final WriteStamp _stamp;

  /// Every non-deleted exercise, built-in and custom.
  Stream<List<Exercise>> watchAll() {
    return (_db.select(_db.exercises)
          ..where((t) => t.deleted.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }

  Future<List<Exercise>> getAll() {
    return (_db.select(
      _db.exercises,
    )..where((t) => t.deleted.equals(false))).get();
  }

  Stream<Exercise?> watchById(String id) {
    return (_db.select(_db.exercises)
          ..where((t) => t.id.equals(id) & t.deleted.equals(false)))
        .watchSingleOrNull();
  }

  Future<Exercise?> getById(String id) {
    return (_db.select(_db.exercises)
          ..where((t) => t.id.equals(id) & t.deleted.equals(false)))
        .getSingleOrNull();
  }

  Future<String> createCustom({
    required String name,
    required MuscleGroup muscleGroup,
    required Equipment equipment,
    required TrackingType trackingType,
  }) async {
    final now = _stamp.now();
    final row = await _db
        .into(_db.exercises)
        .insertReturning(
          ExercisesCompanion.insert(
            name: name.trim(),
            muscleGroup: Value(muscleGroup.key),
            equipment: Value(equipment.key),
            trackingType: Value(trackingType.key),
            createdAt: Value(now),
            updatedAt: Value(now),
            lastModifiedBy: Value(_stamp.deviceId),
          ),
        );
    return row.id;
  }

  Future<void> updateCustom(
    String id, {
    required String name,
    required MuscleGroup muscleGroup,
    required Equipment equipment,
    required TrackingType trackingType,
  }) {
    return (_db.update(_db.exercises)..where((t) => t.id.equals(id))).write(
      ExercisesCompanion(
        name: Value(name.trim()),
        muscleGroup: Value(muscleGroup.key),
        equipment: Value(equipment.key),
        trackingType: Value(trackingType.key),
        updatedAt: Value(_stamp.now()),
        lastModifiedBy: Value(_stamp.deviceId),
      ),
    );
  }

  Future<void> delete(String id) {
    return (_db.update(_db.exercises)..where((t) => t.id.equals(id))).write(
      ExercisesCompanion(
        deleted: const Value(true),
        updatedAt: Value(_stamp.now()),
        lastModifiedBy: Value(_stamp.deviceId),
      ),
    );
  }

  /// Timestamp of seeded rows: older than any user edit, so an edit synced
  /// from another device always wins, and seeded rows are never pushed.
  static final seedTimestamp = DateTime.utc(2000);

  /// Inserts the built-in exercises whose key is not in the database yet.
  ///
  /// Idempotent. A built-in the user deleted is not brought back.
  Future<int> seedBuiltIns([List<ExerciseSeed> seeds = exerciseSeeds]) {
    return _db.transaction(() async {
      final existing =
          await (_db.selectOnly(_db.exercises)
                ..addColumns([_db.exercises.builtInKey]))
              .map((r) => r.read(_db.exercises.builtInKey))
              .get();
      final known = existing.whereType<String>().toSet();
      final missing = seeds.where((s) => !known.contains(s.key)).toList();
      await _db.batch((batch) {
        batch.insertAll(_db.exercises, [
          for (final seed in missing)
            ExercisesCompanion.insert(
              id: Value(builtInExerciseId(seed.key)),
              name: seed.name,
              builtInKey: Value(seed.key),
              muscleGroup: Value(seed.muscleGroup.key),
              equipment: Value(seed.equipment.key),
              trackingType: Value(seed.trackingType.key),
              isCustom: const Value(false),
              createdAt: Value(seedTimestamp),
              updatedAt: Value(seedTimestamp),
            ),
        ]);
      });
      return missing.length;
    });
  }
}
