import 'package:endelea/app.dart';
import 'package:endelea/bootstrap.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes.dart';

/// Pumps the whole app on an in-memory database.
Future<AppDependencies> pumpEndeleaApp(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  final dependencies = (await tester.runAsync(
    () =>
        AppDependencies.create(database: memoryDatabase(), clock: FakeClock()),
  ))!;
  addTearDown(dependencies.database.close);
  await tester.pumpWidget(EndeleaApp(dependencies: dependencies));
  await tester.pumpAndSettle();
  return dependencies;
}
