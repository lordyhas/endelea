import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers/pump_app.dart';

void main() {
  testWidgets('starts in French, dark mode, with five tabs', (tester) async {
    await pumpEndeleaApp(tester);

    expect(find.byType(NavigationDestination), findsNWidgets(5));
    expect(find.text('Programmes'), findsOneWidget);
    final context = tester.element(find.byType(NavigationBar));
    expect(Theme.of(context).brightness, Brightness.dark);
  });
}
