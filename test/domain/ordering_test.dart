import 'package:endelea/domain/models/ordering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('nextOrderIndex appends with a gap', () {
    expect(nextOrderIndex(null), 10);
    expect(nextOrderIndex(30), 40);
  });

  group('moveOrderIndex', () {
    test('moves one item between its new neighbours', () {
      expect(moveOrderIndex([10, 20, 30, 40], 3, 1), {3: 15});
      expect(moveOrderIndex([10, 20, 30, 40], 0, 2), {0: 35});
    });

    test('moves to the ends', () {
      expect(moveOrderIndex([10, 20, 30], 2, 0), {2: 0});
      expect(moveOrderIndex([10, 20, 30], 0, 2), {0: 40});
    });

    test('renumbers when there is no gap left', () {
      expect(moveOrderIndex([10, 11, 12], 2, 1), {2: 20, 1: 30});
    });

    test('does nothing when the item stays in place', () {
      expect(moveOrderIndex([10, 20], 1, 1), isEmpty);
    });
  });
}
