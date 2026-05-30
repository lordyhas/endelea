import 'package:endelea/utils/ids.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('newId keeps the prefix and never repeats', () {
    final ids = [for (var i = 0; i < 1000; i++) newId('tpl')];

    expect(ids.toSet(), hasLength(1000));
    expect(ids.every((id) => id.startsWith('tpl-')), isTrue);
  });
}
