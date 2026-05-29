import 'dart:io';

import 'package:endelea/data/storage/file_storage.dart';
import 'package:endelea/data/storage/key_value_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FileStorage', () {
    late Directory root;
    late FileStorage storage;

    setUp(() async {
      root = await Directory.systemTemp.createTemp('endelea_test');
      storage = FileStorage(Directory('${root.path}/data'));
    });

    tearDown(() => root.delete(recursive: true));

    test('reads null for a missing key', () async {
      expect(await storage.read('history'), isNull);
    });

    test('writes, overwrites and deletes a key', () async {
      await storage.write('history', '[1]');
      await storage.write('history', '[1,2]');
      expect(await storage.read('history'), '[1,2]');

      await storage.delete('history');
      expect(await storage.read('history'), isNull);
    });
  });

  test('MemoryStorage keeps values in a map', () async {
    final storage = MemoryStorage();
    await storage.write('settings', '{}');

    expect(storage.values, {'settings': '{}'});
    expect(await storage.read('settings'), '{}');
  });
}
