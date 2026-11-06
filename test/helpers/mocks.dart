import 'package:endelea/data/repositories/body_repository.dart';
import 'package:endelea/data/repositories/exercise_repository.dart';
import 'package:endelea/data/repositories/program_repository.dart';
import 'package:endelea/data/repositories/session_repository.dart';
import 'package:endelea/data/repositories/sync_meta_repository.dart';
import 'package:endelea/features/settings/data/settings_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockExerciseRepository extends Mock implements ExerciseRepository;

class MockProgramRepository extends Mock implements ProgramRepository;

class MockSessionRepository extends Mock implements SessionRepository;

class MockBodyRepository extends Mock implements BodyRepository;

class MockSettingsRepository extends Mock implements SettingsRepository;

class MockSyncMetaRepository extends Mock implements SyncMetaRepository;
