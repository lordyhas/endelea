import 'package:bloc_test/bloc_test.dart';
import 'package:endelea/core/utils/files_bridge.dart';
import 'package:endelea/data/repositories/backup_repository.dart';
import 'package:endelea/data/repositories/row_store.dart';
import 'package:endelea/features/settings/bloc/data_transfer_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fakes.dart';
import '../../helpers/pump_app.dart';

class MockBackupRepository extends Mock implements BackupRepository;

class MockFilesBridge extends Mock implements FilesBridge;

void main() {
  group('DataTransferCubit', () {
    late MockBackupRepository backup;
    late MockFilesBridge files;
    final clock = FakeClock(DateTime(2026, 11, 21, 9));

    setUp(() {
      backup = MockBackupRepository();
      files = MockFilesBridge();
    });

    DataTransferCubit build() =>
        DataTransferCubit(backup: backup, files: files, clock: clock);

    blocTest<DataTransferCubit, DataTransferState>(
      'export shares the JSON file',
      build: () {
        when(() => backup.exportJson(any())).thenAnswer((_) async => '{}');
        when(
          () => files.shareText(
            fileName: any(named: 'fileName'),
            content: any(named: 'content'),
            title: any(named: 'title'),
          ),
        ).thenAnswer((_) async {});
        return build();
      },
      act: (cubit) => cubit.export(shareTitle: 'Export'),
      expect: () => [const DataTransferBusy(), const DataExported()],
      verify: (_) => verify(
        () => files.shareText(
          fileName: 'endelea-export-2026-11-21.json',
          content: '{}',
          title: 'Export',
        ),
      ).called(1),
    );

    blocTest<DataTransferCubit, DataTransferState>(
      'import merges the picked file',
      build: () {
        when(() => files.openText()).thenAnswer((_) async => '{"x": 1}');
        when(() => backup.importJson('{"x": 1}'))
            .thenAnswer((_) async => const MergeResult(applied: 12));
        return build();
      },
      act: (cubit) => cubit.import(),
      expect: () => [const DataTransferBusy(), const DataImported(12)],
    );

    blocTest<DataTransferCubit, DataTransferState>(
      'cancelled import goes back to idle',
      build: () {
        when(() => files.openText()).thenAnswer((_) async => null);
        return build();
      },
      act: (cubit) => cubit.import(),
      expect: () => [const DataTransferBusy(), const DataTransferIdle()],
    );

    blocTest<DataTransferCubit, DataTransferState>(
      'reports an invalid file',
      build: () {
        when(() => files.openText()).thenAnswer((_) async => 'nope');
        when(() => backup.importJson('nope'))
            .thenThrow(const InvalidExportException('not JSON'));
        return build();
      },
      act: (cubit) => cubit.import(),
      expect: () => [
        const DataTransferBusy(),
        const DataTransferFailed(invalidFile: true),
      ],
    );

    blocTest<DataTransferCubit, DataTransferState>(
      'reports other failures',
      build: () {
        when(() => backup.exportJson(any())).thenThrow(Exception('disk'));
        return build();
      },
      act: (cubit) => cubit.export(),
      expect: () => [
        const DataTransferBusy(),
        const DataTransferFailed(invalidFile: false),
      ],
    );
  });

  testWidgets('settings switch unit, theme and language', (tester) async {
    await pumpEndeleaApp(tester);
    await tester.tap(find.byTooltip('Réglages'));
    await tester.pumpAndSettle();

    expect(find.text('Unité de poids'), findsOneWidget);
    await tester.tap(find.text('lb'));
    await tester.pumpAndSettle();
    expect(find.text('10'), findsOneWidget);

    await tester.tap(find.text('Clair'));
    await tester.pumpAndSettle();
    final context = tester.element(find.text('Unité de poids'));
    expect(Theme.of(context).brightness, Brightness.light);

    await tester.ensureVisible(find.text('English'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Keep the screen on'), findsOneWidget);
  });
}
