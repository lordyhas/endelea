import 'package:endelea/core/widgets/app_shell.dart';
import 'package:endelea/features/history/view/history_screen.dart';
import 'package:endelea/features/home/view/home_screen.dart';
import 'package:endelea/features/programs/view/programs_screen.dart';
import 'package:endelea/features/progress/view/progress_screen.dart';
import 'package:endelea/features/session/view/session_tab_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

abstract final class AppRoutes {
  static const home = '/';
  static const programs = '/programs';
  static const session = '/session';
  static const history = '/history';
  static const progress = '/progress';
}

GoRouter createRouter() {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          _branch(AppRoutes.home, const HomeScreen()),
          _branch(AppRoutes.programs, const ProgramsScreen()),
          _branch(AppRoutes.session, const SessionTabScreen()),
          _branch(AppRoutes.history, const HistoryScreen()),
          _branch(AppRoutes.progress, const ProgressScreen()),
        ],
      ),
    ],
  );
}

StatefulShellBranch _branch(String path, Widget screen) {
  return StatefulShellBranch(
    routes: [GoRoute(path: path, builder: (context, state) => screen)],
  );
}
