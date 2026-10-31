import 'package:endelea/data/database.dart';
import 'package:endelea/data/repositories/sync_meta_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

void main() {
  late AppDatabase db;
  late SyncMetaRepository repo;

  setUp(() {
    db = memoryDatabase();
    repo = SyncMetaRepository(db);
  });

  tearDown(() => db.close());

  test('deviceId is generated once', () async {
    final id = await repo.ensureDeviceId();
    expect(id, isNotEmpty);
    expect(await repo.ensureDeviceId(), id);
  });

  test('stores dates in UTC', () async {
    final date = DateTime(2026, 11, 2, 18, 30);
    await repo.writeDate(SyncMetaKeys.lastPushAt, date);
    final read = await repo.readDate(SyncMetaKeys.lastPushAt);
    expect(read!.isAtSameMomentAs(date), isTrue);

    await repo.remove(SyncMetaKeys.lastPushAt);
    expect(await repo.read(SyncMetaKeys.lastPushAt), isNull);
  });
}
