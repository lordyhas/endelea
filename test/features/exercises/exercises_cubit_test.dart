import 'package:bloc_test/bloc_test.dart';
import 'package:endelea/data/database.dart';
import 'package:endelea/domain/models/exercise_enums.dart';
import 'package:endelea/features/exercises/bloc/exercise_detail_cubit.dart';
import 'package:endelea/features/exercises/bloc/exercises_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/builders.dart';
import '../../helpers/mocks.dart';

void main() {
  late MockExerciseRepository repository;

  final bench = exercise('bench', name: 'Développé couché');
  final squat = exercise('squat', name: 'Squat', muscleGroup: 'legs');
  final curl = exercise(
    'curl',
    name: 'Curl haltères',
    muscleGroup: 'biceps',
    equipment: 'dumbbell',
  );

  setUp(() {
    repository = MockExerciseRepository();
    when(() => repository.watchAll())
        .thenAnswer((_) => Stream.value([squat, curl, bench]));
  });

  ExercisesCubit build() => ExercisesCubit(repository, nameOf: (e) => e.name);

  group('ExercisesCubit', () {
    blocTest<ExercisesCubit, ExercisesState>(
      'lists exercises sorted by name',
      build: build,
      expect: () => [
        isA<ExercisesLoaded>().having((s) => s.visible, 'visible', [
          curl,
          bench,
          squat,
        ]),
      ],
    );

    blocTest<ExercisesCubit, ExercisesState>(
      'search ignores case and accents',
      build: build,
      act: (cubit) async {
        await Future<void>.delayed(Duration.zero);
        cubit.search('DEVELOPPE');
      },
      skip: 1,
      expect: () => [
        isA<ExercisesLoaded>()
            .having((s) => s.visible, 'visible', [bench])
            .having((s) => s.hasFilters, 'hasFilters', isTrue),
      ],
    );

    blocTest<ExercisesCubit, ExercisesState>(
      'filters by muscle group and equipment, then clears',
      build: build,
      act: (cubit) async {
        await Future<void>.delayed(Duration.zero);
        cubit
          ..toggleMuscleGroup(MuscleGroup.legs)
          ..toggleMuscleGroup(MuscleGroup.biceps)
          ..toggleEquipment(Equipment.dumbbell)
          ..clearFilters();
      },
      skip: 1,
      expect: () => [
        isA<ExercisesLoaded>().having((s) => s.visible, 'visible', [squat]),
        isA<ExercisesLoaded>().having((s) => s.visible, 'visible', [
          curl,
          squat,
        ]),
        isA<ExercisesLoaded>().having((s) => s.visible, 'visible', [curl]),
        isA<ExercisesLoaded>()
            .having((s) => s.visible, 'visible', hasLength(3))
            .having((s) => s.hasFilters, 'hasFilters', isFalse),
      ],
    );

    blocTest<ExercisesCubit, ExercisesState>(
      'create returns the new exercise',
      build: () {
        when(
          () => repository.createCustom(
            name: 'Zercher',
            muscleGroup: MuscleGroup.legs,
            equipment: Equipment.barbell,
            trackingType: TrackingType.weightReps,
          ),
        ).thenAnswer((_) async => 'z');
        when(() => repository.getById('z'))
            .thenAnswer((_) async => exercise('z', name: 'Zercher'));
        return build();
      },
      act: (cubit) async {
        final created = await cubit.create(
          name: 'Zercher',
          muscleGroup: MuscleGroup.legs,
          equipment: Equipment.barbell,
          trackingType: TrackingType.weightReps,
        );
        expect(created?.id, 'z');
      },
      skip: 1,
      expect: () => <ExercisesState>[],
    );
  });

  group('ExerciseDetailCubit', () {
    blocTest<ExerciseDetailCubit, ExerciseDetailState>(
      'loads, then reports a deleted exercise',
      build: () {
        when(() => repository.watchById('bench'))
            .thenAnswer((_) => Stream.fromIterable(<Exercise?>[bench, null]));
        return ExerciseDetailCubit(repository, 'bench');
      },
      expect: () => [
        ExerciseDetailLoaded(bench),
        const ExerciseDetailNotFound(),
      ],
    );

    blocTest<ExerciseDetailCubit, ExerciseDetailState>(
      'delete and update go to the repository',
      build: () {
        when(() => repository.watchById('bench'))
            .thenAnswer((_) => const Stream.empty());
        when(() => repository.delete('bench')).thenAnswer((_) async {});
        when(
          () => repository.updateCustom(
            'bench',
            name: 'Bench',
            muscleGroup: MuscleGroup.chest,
            equipment: Equipment.barbell,
            trackingType: TrackingType.weightReps,
          ),
        ).thenAnswer((_) async {});
        return ExerciseDetailCubit(repository, 'bench');
      },
      act: (cubit) async {
        await cubit.update(
          name: 'Bench',
          muscleGroup: MuscleGroup.chest,
          equipment: Equipment.barbell,
          trackingType: TrackingType.weightReps,
        );
        await cubit.delete();
      },
      verify: (_) {
        verify(() => repository.delete('bench')).called(1);
      },
    );
  });
}
