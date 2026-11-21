import 'package:endelea/bootstrap.dart';
import 'package:endelea/core/l10n/l10n.dart';
import 'package:endelea/core/router/app_router.dart';
import 'package:endelea/core/theme/app_theme.dart';
import 'package:endelea/features/session/view/session_effects_listener.dart';
import 'package:endelea/features/settings/bloc/settings_cubit.dart';
import 'package:endelea/features/settings/view/sync_section.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

class EndeleaApp extends StatefulWidget {
  const EndeleaApp({required this.dependencies, super.key});

  final AppDependencies dependencies;

  @override
  State<EndeleaApp> createState() => _EndeleaAppState();
}

class _EndeleaAppState extends State<EndeleaApp> {
  late final GoRouter _router = createRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.dependencies.provide(
      child: BlocBuilder<SettingsCubit, SettingsState>(
        buildWhen: (a, b) =>
            a.settings.themeMode != b.settings.themeMode ||
            a.settings.languageCode != b.settings.languageCode,
        builder: (context, state) => MaterialApp.router(
          onGenerateTitle: (context) => context.l10n.appTitle,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: state.settings.themeMode,
          locale: Locale(state.settings.languageCode),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          routerConfig: _router,
          builder: (context, child) => SyncLifecycleListener(
            child: SessionEffectsListener(
              router: _router,
              alerts: widget.dependencies.restAlerts,
              child: child!,
            ),
          ),
        ),
      ),
    );
  }
}
