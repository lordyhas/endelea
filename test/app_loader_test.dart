import 'package:endelea/data/app_loader.dart';
import 'package:endelea/data/app_repository.dart';
import 'package:endelea/data/demo_data.dart';
import 'package:endelea/data/storage/key_value_storage.dart';
import 'package:endelea/models/settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('starts with demo data on the first launch', () async {
    final stores = await loadStores(AppRepository(MemoryStorage()));

    expect(stores.workouts.history, hasLength(demoHistory().length));
    expect(stores.workouts.active, isNull);
    expect(stores.templates.templates, hasLength(demoTemplates().length));
    expect(stores.exercises.custom, isEmpty);
    expect(stores.settings.settings.weightUnit, WeightUnit.kg);
  });

  test('uses saved data instead of the demo data', () async {
    final repository = AppRepository(MemoryStorage());
    await repository.saveHistory([]);
    await repository.saveRoutines([]);
    await repository.saveSettings(const AppSettings(weightUnit: WeightUnit.lb));

    final stores = await loadStores(repository);

    expect(stores.workouts.history, isEmpty);
    expect(stores.templates.templates, isEmpty);
    expect(stores.settings.settings.weightUnit, WeightUnit.lb);
  });
}
