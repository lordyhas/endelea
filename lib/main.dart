import 'package:drift_flutter/drift_flutter.dart';
import 'package:endelea/app.dart';
import 'package:endelea/bootstrap.dart';
import 'package:endelea/data/database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Fonts are embedded in assets/fonts: the app must work offline.
  GoogleFonts.config.allowRuntimeFetching = false;

  final dependencies = await AppDependencies.create(
    database: AppDatabase(driftDatabase(name: 'endelea')),
  );
  runApp(EndeleaApp(dependencies: dependencies));
}
