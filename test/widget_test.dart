import 'package:flutter_test/flutter_test.dart';

import 'package:endelea/main.dart';

void main() {
  testWidgets('App starts on the home page', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Endelea'), findsOneWidget);
  });
}
