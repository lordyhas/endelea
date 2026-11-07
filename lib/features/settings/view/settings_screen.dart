import 'package:endelea/core/l10n/l10n.dart';
import 'package:material_ui/material_ui.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: Center(child: Text(l10n.comingSoon)),
    );
  }
}
