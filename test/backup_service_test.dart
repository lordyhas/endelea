import 'package:endelea/data/demo_data.dart';
import 'package:endelea/data/exercise_store.dart';
import 'package:endelea/data/settings_store.dart';
import 'package:endelea/data/sync/backup_service.dart';
import 'package:endelea/data/sync/memory_sync_provider.dart';
import 'package:endelea/data/template_store.dart';
import 'package:endelea/data/workout_store.dart';
import 'package:flutter_test/flutter_test.dart';

BackupService _service(
  MemorySyncProvider provider, {
  WorkoutStore? workouts,
  SettingsStore? settings,
}) => BackupService(
  provider: provider,
  workouts: workouts ?? WorkoutStore(),
  settings: settings ?? SettingsStore(),
  exercises: ExerciseStore(),
  templates: TemplateStore(),
);

void main() {
  test('backs up after signing in and records the date', () async {
    final provider = MemorySyncProvider();
    final settings = SettingsStore();
    final service = _service(
      provider,
      workouts: WorkoutStore(history: demoHistory()),
      settings: settings,
    );

    await service.backUp();

    expect(provider.isSignedIn, isTrue);
    expect(provider.files.keys, [BackupService.fileName]);
    expect(settings.settings.lastBackupAt, isNotNull);
    expect(service.busy, isFalse);
  });

  test('restores a backup on another device', () async {
    final provider = MemorySyncProvider();
    await _service(
      provider,
      workouts: WorkoutStore(history: demoHistory()),
    ).backUp();
    final workouts = WorkoutStore();
    final other = _service(provider, workouts: workouts);

    final data = await other.download();
    other.restore(data!);

    expect(workouts.history, hasLength(demoHistory().length));
  });

  test('download returns null when there is no backup yet', () async {
    expect(await _service(MemorySyncProvider()).download(), isNull);
  });
}
