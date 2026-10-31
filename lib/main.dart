import 'package:endelea/app.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Fonts are embedded in assets/fonts: the app must work offline.
  GoogleFonts.config.allowRuntimeFetching = false;
  runApp(const EndeleaApp());
}
