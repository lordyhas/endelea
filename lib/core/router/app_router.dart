import 'package:endelea/core/widgets/app_shell.dart';
import 'package:endelea/core/widgets/gallery_screen.dart';
import 'package:endelea/features/exercises/view/exercise_detail_screen.dart';
import 'package:endelea/features/exercises/view/exercise_library_screen.dart';
import 'package:endelea/features/history/view/history_screen.dart';
import 'package:endelea/features/home/view/home_screen.dart';
import 'package:endelea/features/programs/view/day_editor_screen.dart';
import 'package:endelea/features/programs/view/program_editor_screen.dart';
import 'package:endelea/features/programs/view/programs_screen.dart';
import 'package:endelea/features/progress/view/progress_screen.dart';
import 'package:endelea/features/session/view/session_tab_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

abstract final class AppRoutes {
  static const home = '/';
  static const programs = '/programs';
  static const session = '/session';
  static const history = '/history';
  static const progress = '/progress';
  static const exercises = '/exercises';
  static const exercisePicker = '/exercise-picker';
  static const gallery = '/_gallery';

  static String program(String id) => '/programs/$id';
  static String programDay(String programId, String dayId) =>
      '/programs/$programId/days/$dayId';
  static String exercise(String id) => '/exercises/$id';
}

GoRouter createRouter() {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          _branch(AppRoutes.home, const HomeScreen()),
          _branch(
            AppRoutes.programs,
            const ProgramsScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) =>
                    ProgramEditorScreen(programId: state.pathParameters['id']!),
                routes: [
                  GoRoute(
                    path: 'days/:dayId',
                    builder: (context, state) =>
                        DayEditorScreen(dayId: state.pathParameters['dayId']!),
                  ),
                ],
              ),
            ],
          ),
          _branch(AppRoutes.session, const SessionTabScreen()),
          _branch(AppRoutes.history, const HistoryScreen()),
          _branch(AppRoutes.progress, const ProgressScreen()),
        ],
      ),
      GoRoute(
        path: AppRoutes.exercises,
        builder: (context, state) => const ExerciseLibraryScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) =>
                ExerciseDetailScreen(exerciseId: state.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.exercisePicker,
        builder: (context, state) => const ExerciseLibraryScreen(pick: true),
      ),
      if (kDebugMode)
        GoRoute(
          path: AppRoutes.gallery,
          builder: (context, state) => const GalleryScreen(),
        ),
    ],
  );
}

StatefulShellBranch _branch(
  String path,
  Widget screen, {
  List<RouteBase> routes = const [],
}) {
  return StatefulShellBranch(
    routes: [
      GoRoute(path: path, builder: (context, state) => screen, routes: routes),
    ],
  );
}
