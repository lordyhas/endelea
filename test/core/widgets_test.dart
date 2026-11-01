import 'package:endelea/core/utils/units.dart';
import 'package:endelea/core/widgets/buttons.dart';
import 'package:endelea/core/widgets/cards.dart';
import 'package:endelea/core/widgets/feedback.dart';
import 'package:endelea/core/widgets/gallery_screen.dart';
import 'package:endelea/core/widgets/rest_timer.dart';
import 'package:endelea/core/widgets/set_row.dart';
import 'package:endelea/core/widgets/value_stepper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../helpers/pump_widget.dart';

void main() {
  group('buttons', () {
    testWidgets('PrimaryActionButton is 56 high and tappable', (tester) async {
      var taps = 0;
      await pumpThemed(
        tester,
        PrimaryActionButton(label: 'Go', onPressed: () => taps++),
      );
      expect(tester.getSize(find.byType(PrimaryActionButton)).height, 56);
      await tester.tap(find.text('Go'));
      expect(taps, 1);
    });

    testWidgets('SecondaryButton tonal and outlined', (tester) async {
      var taps = 0;
      await pumpThemed(
        tester,
        Column(
          children: [
            SecondaryButton(label: 'A', onPressed: () => taps++),
            SecondaryButton(
              label: 'B',
              outlined: true,
              onPressed: () => taps++,
            ),
          ],
        ),
      );
      await tester.tap(find.text('A'));
      await tester.tap(find.text('B'));
      expect(taps, 2);
      expect(find.byType(OutlinedButton), findsOneWidget);
    });
  });

  group('steppers', () {
    testWidgets('WeightStepper steps by 2.5 kg', (tester) async {
      double? value;
      await pumpThemed(
        tester,
        WeightStepper(
          weightKg: 60,
          unit: WeightUnit.kg,
          onChanged: (v) => value = v,
        ),
      );
      expect(find.text('60'), findsOneWidget);
      await tester.tap(find.byIcon(PhosphorIconsRegular.plus));
      expect(value, 62.5);
      await tester.tap(find.byIcon(PhosphorIconsRegular.minus));
      expect(value, 60);
    });

    testWidgets('WeightStepper in lb stores kg', (tester) async {
      double? value;
      await pumpThemed(
        tester,
        WeightStepper(
          weightKg: displayToKg(135, WeightUnit.lb),
          unit: WeightUnit.lb,
          onChanged: (v) => value = v,
        ),
      );
      expect(find.text('135'), findsOneWidget);
      await tester.tap(find.byIcon(PhosphorIconsRegular.plus));
      expect(kgToDisplay(value!, WeightUnit.lb), 140);
    });

    testWidgets('tapping the value opens a numeric entry', (tester) async {
      double? value;
      await pumpThemed(
        tester,
        WeightStepper(
          weightKg: 60,
          unit: WeightUnit.kg,
          onChanged: (v) => value = v,
        ),
      );
      await tester.tap(find.text('60'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '72,5');
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(value, 72.5);
    });

    testWidgets('long press repeats', (tester) async {
      var value = 8;
      await pumpThemed(
        tester,
        StatefulBuilder(
          builder: (context, setState) => RepsStepper(
            reps: value,
            onChanged: (v) => setState(() => value = v),
          ),
        ),
      );
      final gesture = await tester.startGesture(
        tester.getCenter(find.byIcon(PhosphorIconsRegular.plus)),
      );
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 500));
      await gesture.up();
      expect(value, greaterThan(10));
    });

    testWidgets('RepsStepper does not go below zero', (tester) async {
      int? value;
      await pumpThemed(
        tester,
        RepsStepper(reps: 0, onChanged: (v) => value = v),
      );
      await tester.tap(find.byIcon(PhosphorIconsRegular.minus));
      expect(value, isNull);
    });

    testWidgets('stepper is announced with its value', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpThemed(
        tester,
        WeightStepper(weightKg: 62.5, unit: WeightUnit.kg, onChanged: (_) {}),
      );
      expect(find.bySemanticsLabel('Charge, 62,5 kilos'), findsOneWidget);
      expect(find.bySemanticsLabel('Augmenter'), findsOneWidget);
      handle.dispose();
    });
  });

  group('SetRow', () {
    testWidgets('shows values and calls onCheck', (tester) async {
      var checks = 0;
      await pumpThemed(
        tester,
        SetRow(
          index: 2,
          state: SetRowState.current,
          previous: '60 × 8',
          value: '62,5',
          secondary: '8',
          onCheck: () => checks++,
        ),
      );
      expect(find.text('62,5'), findsOneWidget);
      expect(find.text('60 × 8'), findsOneWidget);
      await tester.tap(find.byIcon(PhosphorIconsRegular.check));
      expect(checks, 1);
    });

    testWidgets('warm-up shows its label', (tester) async {
      await pumpThemed(
        tester,
        const SetRow(
          index: 1,
          state: SetRowState.done,
          isWarmup: true,
          value: '40',
          secondary: '10',
        ),
      );
      expect(find.text('É'), findsOneWidget);
    });

    for (final dark in [true, false]) {
      testWidgets('all states render (dark: $dark)', (tester) async {
        await pumpThemed(
          tester,
          Column(
            children: [
              const SetRowHeader(valueLabel: 'kg', secondaryLabel: 'Reps'),
              for (final state in SetRowState.values)
                SetRow(index: 1, state: state, value: '60', secondary: '8'),
            ],
          ),
          dark: dark,
        );
        expect(find.byType(SetRow), findsNWidgets(3));
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('rest timer', () {
    testWidgets('bar shows time left and its actions', (tester) async {
      final calls = <String>[];
      await pumpThemed(
        tester,
        RestTimerBar(
          remaining: const Duration(seconds: 72),
          total: const Duration(seconds: 90),
          onMinus: () => calls.add('-'),
          onPlus: () => calls.add('+'),
          onSkip: () => calls.add('skip'),
        ),
      );
      expect(find.text('1:12'), findsOneWidget);
      await tester.tap(find.text('−15 s'));
      await tester.tap(find.text('+15 s'));
      await tester.tap(find.text('Passer'));
      expect(calls, ['-', '+', 'skip']);
    });

    testWidgets('full screen shows large digits', (tester) async {
      await pumpThemed(
        tester,
        RestTimerFullScreen(
          remaining: const Duration(seconds: 5),
          total: const Duration(seconds: 90),
          nextLabel: 'Next',
          onMinus: () {},
          onPlus: () {},
          onSkip: () {},
        ),
      );
      expect(find.text('0:05'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
    });
  });

  group('cards', () {
    testWidgets('ProgramCard', (tester) async {
      var started = false;
      await pumpThemed(
        tester,
        ProgramCard(
          name: 'PPL',
          dayCount: 3,
          lastSession: '18 nov.',
          isActive: true,
          onStart: () => started = true,
        ),
      );
      expect(find.text('Actif'), findsOneWidget);
      expect(find.text('3 jours · Dernière séance : 18 nov.'), findsOneWidget);
      await tester.tap(find.text('Démarrer'));
      expect(started, isTrue);
    });

    testWidgets('ExerciseTile shows a check when selected', (tester) async {
      await pumpThemed(
        tester,
        const ExerciseTile(
          name: 'Bench',
          subtitle: 'Chest',
          icon: PhosphorIconsRegular.barbell,
          selected: true,
        ),
      );
      expect(find.byIcon(PhosphorIconsRegular.check), findsOneWidget);
    });

    testWidgets('StatTile and PrBadge', (tester) async {
      await pumpThemed(
        tester,
        const Column(
          children: [
            StatTile(label: 'Volume', value: '1 200'),
            PrBadge(),
          ],
        ),
      );
      expect(find.text('1 200'), findsOneWidget);
      expect(find.text('Record'), findsOneWidget);
    });
  });

  group('feedback', () {
    testWidgets('EmptyState', (tester) async {
      await pumpThemed(
        tester,
        EmptyState(
          icon: PhosphorIconsDuotone.listChecks,
          title: 'Title',
          message: 'Message',
          action: TextButton(onPressed: () {}, child: const Text('Act')),
        ),
        scroll: false,
      );
      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Act'), findsOneWidget);
    });

    testWidgets('ConfirmSheet returns the choice', (tester) async {
      late BuildContext context;
      await pumpThemed(
        tester,
        Builder(
          builder: (c) {
            context = c;
            return const SizedBox();
          },
        ),
      );
      final result = ConfirmSheet.show(
        context,
        title: 'Delete?',
        message: 'Sure',
        confirmLabel: 'Delete',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(await result, isTrue);

      final cancelled = ConfirmSheet.show(
        context,
        title: 'Delete?',
        message: 'Sure',
        confirmLabel: 'Delete',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();
      expect(await cancelled, isFalse);
    });

    testWidgets('SyncStatusChip labels', (tester) async {
      await pumpThemed(
        tester,
        Wrap(
          children: [
            for (final status in SyncStatus.values)
              SyncStatusChip(status: status),
          ],
        ),
      );
      expect(find.text('À jour'), findsOneWidget);
      expect(find.text('Erreur de synchro'), findsOneWidget);
    });
  });

  testWidgets('gallery renders in both themes', (tester) async {
    await pumpThemed(tester, const GalleryScreen(), scroll: false);
    expect(find.text('Galerie'), findsOneWidget);
    await tester.tap(find.byIcon(PhosphorIconsRegular.sun));
    await tester.pumpAndSettle();
    expect(find.byIcon(PhosphorIconsRegular.moon), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
