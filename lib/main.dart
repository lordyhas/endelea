import 'dart:io';

import 'package:drift_flutter/drift_flutter.dart';
import 'package:endelea/app.dart';
import 'package:endelea/bootstrap.dart';
import 'package:endelea/data/database.dart';
import 'package:endelea/features/session/data/platform_session_effects.dart';
import 'package:endelea/sync/google_drive_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Fonts are embedded in assets/fonts: the app must work offline.
  GoogleFonts.config.allowRuntimeFetching = false;

  final dependencies = await AppDependencies.create(
    database: AppDatabase(driftDatabase(name: 'endelea')),
    restAlerts: (settings) => LocalRestAlerts(settings: settings),
    haptics: (settings) => PlatformSessionHaptics(settings: settings),
    cloud: GoogleDriveProvider(
      serverClientId: const String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID'),
    ),
    // Not in the system backup: a restored database gets a new device id.
    deviceMarker: File('${(await getTemporaryDirectory()).path}/device_id'),
  );
  runApp(EndeleaApp(dependencies: dependencies));
}
