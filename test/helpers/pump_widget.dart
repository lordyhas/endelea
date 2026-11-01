import 'package:endelea/core/l10n/l10n.dart';
import 'package:endelea/core/theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Pumps [child] in a themed, localized app (French by default).
Future<void> pumpThemed(
  WidgetTester tester,
  Widget child, {
  bool dark = true,
  Locale locale = const Locale('fr'),
  bool scroll = true,
}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: dark ? AppTheme.dark : AppTheme.light,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      home: Scaffold(
        body: scroll ? SingleChildScrollView(child: child) : child,
      ),
    ),
  );
}
