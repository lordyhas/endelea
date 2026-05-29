import '../models/settings.dart';
import 'app_repository.dart';
import 'demo_data.dart';
import 'exercise_store.dart';
import 'settings_store.dart';
import 'template_store.dart';
import 'workout_store.dart';

/// Every store of the app, filled from saved data.
typedef AppStores = ({
  WorkoutStore workouts,
  SettingsStore settings,
  ExerciseStore exercises,
  TemplateStore templates,
});

/// Builds the stores from [repository].
///
/// On the first launch nothing is saved yet, so the history and routines
/// start with demo data.
Future<AppStores> loadStores(AppRepository repository) async {
  final exercises = ExerciseStore(
    custom: await repository.loadCustomExercises(),
  );
  final lookup = exercises.byId;
  return (
    workouts: WorkoutStore(
      history: await repository.loadHistory(lookup) ?? demoHistory(),
      active: await repository.loadActive(lookup),
    ),
    settings: SettingsStore(
      await repository.loadSettings() ?? const AppSettings(),
    ),
    exercises: exercises,
    templates: TemplateStore(
      templates: await repository.loadRoutines(lookup) ?? demoTemplates(),
    ),
  );
}
