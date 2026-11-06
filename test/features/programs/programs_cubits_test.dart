import 'package:bloc_test/bloc_test.dart';
import 'package:endelea/domain/models/exercise_enums.dart';
import 'package:endelea/domain/models/program_models.dart';
import 'package:endelea/features/programs/bloc/day_editor_cubit.dart';
import 'package:endelea/features/programs/bloc/program_editor_cubit.dart';
import 'package:endelea/features/programs/bloc/programs_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/builders.dart';
import '../../helpers/mocks.dart';

void main() {
  late MockProgramRepository repository;

  setUpAll(() {
    registerFallbackValue(const ExerciseTargets(sets: 3, restSeconds: 90));
  });

  setUp(() => repository = MockProgramRepository());

  final ppl = ProgramSummary(
    program: program('p1', isActive: true),
    dayCount: 3,
  );

  group('ProgramsCubit', () {
    blocTest<ProgramsCubit, ProgramsState>(
      'emits the programs from the repository',
      build: () {
        when(() => repository.watchSummaries()).thenAnswer(
          (_) => Stream.fromIterable([
            [],
            [ppl],
          ]),
        );
        return ProgramsCubit(repository);
      },
      expect: () => [
        const ProgramsLoaded([]),
        ProgramsLoaded([ppl]),
      ],
    );

    blocTest<ProgramsCubit, ProgramsState>(
      'emits an error when the stream fails',
      build: () {
        when(() => repository.watchSummaries())
            .thenAnswer((_) => Stream.error(Exception('db')));
        return ProgramsCubit(repository);
      },
      expect: () => [const ProgramsError()],
    );

    blocTest<ProgramsCubit, ProgramsState>(
      'actions are delegated to the repository',
      build: () {
        when(() => repository.watchSummaries())
            .thenAnswer((_) => const Stream.empty());
        when(() => repository.createProgram('PPL'))
            .thenAnswer((_) async => 'p1');
        when(() => repository.duplicate('p1', name: 'PPL (copie)'))
            .thenAnswer((_) async => 'p2');
        when(() => repository.activate('p2')).thenAnswer((_) async {});
        when(() => repository.deleteProgram('p1')).thenAnswer((_) async {});
        when(() => repository.updateProgram('p2', name: 'Upper'))
            .thenAnswer((_) async {});
        return ProgramsCubit(repository);
      },
      act: (cubit) async {
        expect(await cubit.create('PPL'), 'p1');
        await cubit.duplicate('p1', name: 'PPL (copie)');
        await cubit.activate('p2');
        await cubit.rename('p2', 'Upper');
        await cubit.delete('p1');
      },
      verify: (_) {
        verify(() => repository.activate('p2')).called(1);
        verify(() => repository.deleteProgram('p1')).called(1);
      },
    );
  });

  group('ProgramEditorCubit', () {
    final details = ProgramDetails(
      program: program('p1'),
      days: [
        ProgramDaySummary(day: programDay('a'), exerciseCount: 2),
        ProgramDaySummary(day: programDay('b', order: 20), exerciseCount: 0),
      ],
    );

    blocTest<ProgramEditorCubit, ProgramEditorState>(
      'loads the program, then reports it deleted',
      build: () {
        when(() => repository.watchDetails('p1'))
            .thenAnswer((_) => Stream.fromIterable([details, null]));
        return ProgramEditorCubit(repository, 'p1');
      },
      expect: () => [
        ProgramEditorLoaded(details),
        const ProgramEditorNotFound(),
      ],
    );

    blocTest<ProgramEditorCubit, ProgramEditorState>(
      'moveDay reorders right away',
      build: () {
        when(() => repository.watchDetails('p1'))
            .thenAnswer((_) => Stream.value(details));
        when(() => repository.moveDay('p1', 1, 0)).thenAnswer((_) async {});
        return ProgramEditorCubit(repository, 'p1');
      },
      act: (cubit) async {
        await Future<void>.delayed(Duration.zero);
        await cubit.moveDay(1, 0);
      },
      skip: 1,
      expect: () => [
        isA<ProgramEditorLoaded>().having(
          (s) => s.details.days.map((d) => d.day.id),
          'days',
          ['b', 'a'],
        ),
      ],
      verify: (_) => verify(() => repository.moveDay('p1', 1, 0)).called(1),
    );

    blocTest<ProgramEditorCubit, ProgramEditorState>(
      'day actions are delegated',
      build: () {
        when(() => repository.watchDetails('p1'))
            .thenAnswer((_) => const Stream.empty());
        when(() => repository.addDay('p1', 'Push'))
            .thenAnswer((_) async => 'd');
        when(() => repository.renameDay('d', 'Pull')).thenAnswer((_) async {});
        when(() => repository.deleteDay('d')).thenAnswer((_) async {});
        when(
          () => repository.updateProgram('p1', name: 'PPL', description: 'x'),
        ).thenAnswer((_) async {});
        return ProgramEditorCubit(repository, 'p1');
      },
      act: (cubit) async {
        expect(await cubit.addDay('Push'), 'd');
        await cubit.renameDay('d', 'Pull');
        await cubit.deleteDay('d');
        await cubit.update(name: 'PPL', description: 'x');
      },
      verify: (_) => verify(() => repository.deleteDay('d')).called(1),
    );
  });

  group('DayEditorCubit', () {
    blocTest<DayEditorCubit, DayEditorState>(
      'adds exercises with defaults per tracking type',
      build: () {
        when(() => repository.watchDay('d'))
            .thenAnswer((_) => const Stream.empty());
        when(
          () => repository.addExercises(
            'd',
            any(),
            defaults: any(named: 'defaults'),
          ),
        ).thenAnswer((_) async {});
        return DayEditorCubit(repository, 'd', defaultRestSeconds: 120);
      },
      act: (cubit) => cubit.addExercises({
        'bench': TrackingType.weightReps,
        'plank': TrackingType.duration,
      }),
      verify: (_) {
        verify(
          () => repository.addExercises(
            'd',
            ['bench'],
            defaults: const ExerciseTargets(
              sets: 3,
              repsMin: 8,
              repsMax: 12,
              restSeconds: 120,
            ),
          ),
        ).called(1);
        verify(
          () => repository.addExercises(
            'd',
            ['plank'],
            defaults: const ExerciseTargets(
              sets: 3,
              durationSeconds: 60,
              restSeconds: 120,
            ),
          ),
        ).called(1);
      },
    );

    blocTest<DayEditorCubit, DayEditorState>(
      'reports a deleted day',
      build: () {
        when(() => repository.watchDay('d'))
            .thenAnswer((_) => Stream.value(null));
        return DayEditorCubit(repository, 'd', defaultRestSeconds: 90);
      },
      expect: () => [const DayEditorNotFound()],
    );

    blocTest<DayEditorCubit, DayEditorState>(
      'target and order changes are delegated',
      build: () {
        when(() => repository.watchDay('d'))
            .thenAnswer((_) => const Stream.empty());
        when(() => repository.updateTargets('x', any()))
            .thenAnswer((_) async {});
        when(() => repository.removePlannedExercise('x'))
            .thenAnswer((_) async {});
        when(() => repository.movePlannedExercise('d', 0, 1))
            .thenAnswer((_) async {});
        when(() => repository.renameDay('d', 'Legs')).thenAnswer((_) async {});
        return DayEditorCubit(repository, 'd', defaultRestSeconds: 90);
      },
      act: (cubit) async {
        await cubit.updateTargets(
          'x',
          const ExerciseTargets(sets: 5, restSeconds: 60),
        );
        await cubit.move(0, 1);
        await cubit.remove('x');
        await cubit.rename('Legs');
      },
      verify: (_) {
        verify(() => repository.movePlannedExercise('d', 0, 1)).called(1);
        verify(() => repository.removePlannedExercise('x')).called(1);
      },
    );
  });
}
