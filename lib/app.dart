import 'package:endelea/bootstrap.dart';
import 'package:endelea/core/l10n/l10n.dart';
import 'package:endelea/core/router/app_router.dart';
import 'package:endelea/core/theme/app_theme.dart';
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
      child: MaterialApp.router(
        onGenerateTitle: (context) => context.l10n.appTitle,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.dark,
        locale: const Locale('fr'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        routerConfig: _router,
      ),
    );
  }
}
