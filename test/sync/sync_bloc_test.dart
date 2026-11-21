import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:endelea/data/database.dart';
import 'package:endelea/data/repositories/row_store.dart';
import 'package:endelea/data/repositories/sync_meta_repository.dart';
import 'package:endelea/features/settings/bloc/sync_bloc.dart';
import 'package:endelea/sync/cloud_sync_provider.dart';
import 'package:endelea/sync/sync_engine.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_cloud.dart';
import '../helpers/fakes.dart';

class CancellingProvider extends FakeCloudProvider {
  CancellingProvider(super.cloud);

  @override
  Future<CloudAccount> signIn() => Future.error(const CloudSignInCancelled());
}

class FailingProvider extends FakeCloudProvider {
  FailingProvider(super.cloud);

  @override
  Future<CloudAccount> signIn() => Future.error(Exception('no network'));
}

void main() {
  late AppDatabase db;
  late FakeClock clock;
  late SyncMetaRepository meta;
  late SyncEngine engine;
  late FakeCloud cloud;
  late FakeCloudProvider provider;
  var sessionActive = false;
  const account = CloudAccount(email: 'user@example.com');

  setUp(() {
    db = memoryDatabase();
    clock = FakeClock(DateTime(2026, 11, 21, 9));
    meta = SyncMetaRepository(db);
    engine = SyncEngine(
      database: db,
      rows: RowStore(db),
      meta: meta,
      clock: clock,
    );
    cloud = FakeCloud();
    provider = FakeCloudProvider(cloud);
    sessionActive = false;
  });

  tearDown(() => db.close());

  SyncBloc build([CloudSyncProvider? other]) => SyncBloc(
    provider: other ?? provider,
    engine: engine,
    meta: meta,
    clock: clock,
    sessionActive: () => sessionActive,
  );

  blocTest<SyncBloc, SyncState>(
    'stays disabled at start without a connected account',
    build: build,
    act: (bloc) => bloc.add(const SyncStarted()),
    expect: () => <SyncState>[],
  );

  blocTest<SyncBloc, SyncState>(
    'sign in then sync',
    build: build,
    act: (bloc) => bloc.add(const SyncSignInRequested()),
    expect: () => [
      const SyncUpToDate(account: account),
      const SyncInProgress(account: account),
      isA<SyncUpToDate>().having((s) => s.lastSyncAt, 'lastSyncAt', isNotNull),
    ],
    verify: (_) async {
      expect(await meta.read(SyncMetaKeys.provider), 'fake');
      expect(await meta.read(SyncMetaKeys.accountEmail), account.email);
      expect(cloud.files, isNotEmpty);
    },
  );

  blocTest<SyncBloc, SyncState>(
    'a cancelled sign-in stays disabled, a failed one says so',
    build: () => build(CancellingProvider(cloud)),
    act: (bloc) => bloc.add(const SyncSignInRequested()),
    expect: () => [const SyncDisabled()],
  );

  blocTest<SyncBloc, SyncState>(
    'a failed sign-in is reported',
    build: () => build(FailingProvider(cloud)),
    act: (bloc) => bloc.add(const SyncSignInRequested()),
    expect: () => [const SyncDisabled(signInFailed: true)],
  );

  group('once connected', () {
    setUp(() async {
      await meta.write(SyncMetaKeys.provider, 'fake');
    });

    blocTest<SyncBloc, SyncState>(
      'restores the account and syncs at start',
      build: build,
      act: (bloc) => bloc.add(const SyncStarted()),
      expect: () => [
        const SyncUpToDate(account: account),
        const SyncInProgress(account: account),
        isA<SyncUpToDate>(),
      ],
    );

    blocTest<SyncBloc, SyncState>(
      'no automatic sync during a workout, manual sync still works',
      build: build,
      seed: () => const SyncUpToDate(account: account),
      act: (bloc) async {
        sessionActive = true;
        bloc.add(const SyncRequested(SyncReason.sessionFinished));
        await Future<void>.delayed(Duration.zero);
        bloc.add(const SyncRequested(SyncReason.manual));
      },
      expect: () => [
        const SyncInProgress(account: account),
        isA<SyncUpToDate>(),
      ],
    );

    blocTest<SyncBloc, SyncState>(
      'back to the foreground: only after 15 minutes',
      build: build,
      seed: () => SyncUpToDate(
        account: account,
        lastSyncAt: DateTime(2026, 11, 21, 8, 50),
      ),
      act: (bloc) async {
        bloc.add(const SyncRequested(SyncReason.resumed));
        await Future<void>.delayed(Duration.zero);
        clock.advance(const Duration(minutes: 10));
        bloc.add(const SyncRequested(SyncReason.resumed));
      },
      expect: () => [isA<SyncInProgress>(), isA<SyncUpToDate>()],
    );

    blocTest<SyncBloc, SyncState>(
      'network errors are silent and keep the account',
      build: () {
        provider.failNext = true;
        return build();
      },
      seed: () => const SyncUpToDate(account: account),
      act: (bloc) => bloc.add(const SyncRequested(SyncReason.manual)),
      expect: () => [
        const SyncInProgress(account: account),
        const SyncFailed(account: account),
      ],
    );

    blocTest<SyncBloc, SyncState>(
      'sign out forgets the sync state',
      build: build,
      seed: () => const SyncUpToDate(account: account),
      act: (bloc) => bloc.add(const SyncSignOutRequested()),
      expect: () => [const SyncDisabled()],
      verify: (_) async {
        expect(provider.signedIn, isFalse);
        expect(await meta.read(SyncMetaKeys.provider), isNull);
      },
    );
  });

  test('device id: a restored backup gets a new id', () async {
    final dir = await Directory.systemTemp.createTemp('endelea');
    final marker = File('${dir.path}/device_id');
    final first = await meta.ensureDeviceId(marker: marker);
    expect(await meta.ensureDeviceId(marker: marker), first);

    await meta.writeDate(SyncMetaKeys.lastPushAt, DateTime(2026));
    await marker.delete();
    final second = await meta.ensureDeviceId(marker: marker);
    expect(second, isNot(first));
    expect(await meta.read(SyncMetaKeys.lastPushAt), isNull);
    await dir.delete(recursive: true);
  });
}
