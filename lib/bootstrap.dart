import 'package:endelea/core/utils/clock.dart';
import 'package:endelea/core/utils/files_bridge.dart';
import 'package:endelea/data/database.dart';
import 'package:endelea/data/repositories/backup_repository.dart';
import 'package:endelea/data/repositories/body_repository.dart';
import 'package:endelea/data/repositories/exercise_repository.dart';
import 'package:endelea/data/repositories/program_repository.dart';
import 'package:endelea/data/repositories/row_store.dart';
import 'package:endelea/data/repositories/session_repository.dart';
import 'package:endelea/data/repositories/sync_meta_repository.dart';
import 'package:endelea/data/repositories/write_stamp.dart';
import 'package:endelea/features/session/bloc/session_bloc.dart';
import 'package:endelea/features/session/data/session_effects.dart';
import 'package:endelea/features/settings/bloc/settings_cubit.dart';
import 'package:endelea/features/settings/data/app_settings.dart';
import 'package:endelea/features/settings/data/settings_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// Everything created once at startup and shared through the widget tree.
class AppDependencies {
  AppDependencies._({
    required this.database,
    required this.clock,
    required this.stamp,
    required this.syncMeta,
    required this.exercises,
    required this.programs,
    required this.sessions,
    required this.body,
    required this.settings,
    required this.rows,
    required this.backup,
    required this.restAlerts,
    required this.haptics,
  });

  final AppDatabase database;
  final Clock clock;
  final WriteStamp stamp;
  final SyncMetaRepository syncMeta;
  final ExerciseRepository exercises;
  final ProgramRepository programs;
  final SessionRepository sessions;
  final BodyRepository body;
  final SettingsRepository settings;
  final RowStore rows;
  final BackupRepository backup;
  final RestAlerts restAlerts;
  final SessionHaptics? haptics;

  /// Opens the repositories on [database]: device id, built-in seed.
  static Future<AppDependencies> create({
    required AppDatabase database,
    Clock clock = const SystemClock(),
    RestAlerts Function(AppSettings Function() settings)? restAlerts,
    SessionHaptics Function(AppSettings Function() settings)? haptics,
  }) async {
    final syncMeta = SyncMetaRepository(database);
    final deviceId = await syncMeta.ensureDeviceId();
    final stamp = WriteStamp(clock: clock, deviceId: deviceId);
    final exercises = ExerciseRepository(database, stamp);
    await exercises.seedBuiltIns();
    final settings = await SettingsRepository.open();
    AppSettings current() => settings.load();
    final rows = RowStore(database);
    return AppDependencies._(
      database: database,
      clock: clock,
      stamp: stamp,
      syncMeta: syncMeta,
      exercises: exercises,
      programs: ProgramRepository(database, stamp),
      sessions: SessionRepository(database, stamp),
      body: BodyRepository(database, stamp),
      settings: settings,
      rows: rows,
      backup: BackupRepository(database, rows),
      restAlerts: restAlerts?.call(current) ?? const SilentRestAlerts(),
      haptics: haptics?.call(current),
    );
  }

  /// Provides every repository and the global cubits to [child].
  Widget provide({required Widget child}) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<Clock>.value(value: clock),
        RepositoryProvider.value(value: syncMeta),
        RepositoryProvider.value(value: exercises),
        RepositoryProvider.value(value: programs),
        RepositoryProvider.value(value: sessions),
        RepositoryProvider.value(value: body),
        RepositoryProvider.value(value: settings),
        RepositoryProvider.value(value: rows),
        RepositoryProvider.value(value: backup),
        RepositoryProvider(create: (_) => const FilesBridge()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => SettingsCubit(settings)),
          BlocProvider(
            lazy: false,
            create: (context) => SessionBloc(
              sessions: sessions,
              programs: programs,
              clock: clock,
              settings: () => context.read<SettingsCubit>().settings,
              alerts: restAlerts,
              haptics: haptics,
            ),
          ),
        ],
        child: child,
      ),
    );
  }
}
