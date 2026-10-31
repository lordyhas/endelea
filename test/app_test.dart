import 'package:endelea/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('starts in French, dark mode, with five tabs', (tester) async {
    await tester.pumpWidget(const EndeleaApp());
    await tester.pumpAndSettle();

    expect(find.byType(NavigationDestination), findsNWidgets(5));
    expect(find.text('Programmes'), findsOneWidget);
    final context = tester.element(find.byType(NavigationBar));
    expect(Theme.of(context).brightness, Brightness.dark);
  });
}
