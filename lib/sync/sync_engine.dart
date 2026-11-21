import 'dart:convert';

import 'package:endelea/core/utils/clock.dart';
import 'package:endelea/data/database.dart';
import 'package:endelea/data/repositories/exercise_repository.dart';
import 'package:endelea/data/repositories/row_store.dart';
import 'package:endelea/data/repositories/sync_meta_repository.dart';
import 'package:endelea/sync/cloud_sync_provider.dart';
import 'package:endelea/sync/sync_codec.dart';
import 'package:equatable/equatable.dart';

/// What one sync did.
class SyncReport extends Equatable {
  const SyncReport({
    required this.pushedRows,
    required this.pulledFiles,
    required this.appliedRows,
  });

  final int pushedRows;
  final int pulledFiles;
  final int appliedRows;

  @override
  List<Object?> get props => [pushedRows, pulledFiles, appliedRows];
}

/// Push, pull and merge through the user's cloud (PLAN.md §9.3).
///
/// - Push: every row changed since the last push goes into a new batch file
///   under `changes/<deviceId>/` (append-only).
/// - Pull: batch files of other devices newer than their cursor are merged,
///   last write wins per row (see [RowStore.merge]).
/// - Merged rows keep their `updated_at`: the sync never makes a change
///   look new.
class SyncEngine {
  SyncEngine({
    required this.database,
    required this.rows,
    required this.meta,
    required this.clock,
    this.codec = const SyncCodec(),
  });

  final AppDatabase database;
  final RowStore rows;
  final SyncMetaRepository meta;
  final Clock clock;
  final SyncCodec codec;

  /// Pull, then push.
  Future<SyncReport> sync(CloudSyncProvider provider) async {
    final files = await provider.listFiles(prefix: '${SyncCodec.root}/');
    await _checkManifest(provider, files);
    final (pulledFiles, appliedRows) = await _pull(provider, files);
    final pushedRows = await _push(provider);
    await meta.writeDate(SyncMetaKeys.lastSyncAt, clock.now());
    return SyncReport(
      pushedRows: pushedRows,
      pulledFiles: pulledFiles,
      appliedRows: appliedRows,
    );
  }

  Future<void> _checkManifest(
    CloudSyncProvider provider,
    List<CloudFile> files,
  ) async {
    final manifest = files
        .where((f) => f.name == SyncCodec.manifestName)
        .firstOrNull;
    if (manifest == null) {
      await provider.upload(
        SyncCodec.manifestName,
        codec.encodeManifest(
          schemaVersion: database.schemaVersion,
          createdAt: clock.now(),
        ),
      );
      return;
    }
    final version = codec.manifestVersion(await provider.download(manifest.id));
    if (version == null || version > SyncCodec.formatVersion) {
      throw UnsupportedSyncFormatException(version);
    }
  }

  Future<(int, int)> _pull(
    CloudSyncProvider provider,
    List<CloudFile> files,
  ) async {
    final deviceId = await meta.ensureDeviceId();
    final cursors = await _readCursors();
    final batches = <({CloudFile file, String deviceId, int millis})>[];
    for (final file in files) {
      final parsed = SyncCodec.parseBatchName(file.name);
      if (parsed == null || parsed.deviceId == deviceId) continue;
      if (parsed.millis <= (cursors[parsed.deviceId] ?? -1)) continue;
      batches.add((
        file: file,
        deviceId: parsed.deviceId,
        millis: parsed.millis,
      ));
    }
    // Oldest first, so a device's later batch overrides its earlier one.
    batches.sort((a, b) => a.millis.compareTo(b.millis));

    var applied = 0;
    for (final batch in batches) {
      final decoded = codec.decodeBatch(await provider.download(batch.file.id));
      applied += (await rows.merge(decoded.tables)).applied;
      cursors[batch.deviceId] = batch.millis;
      await _writeCursors(cursors);
    }
    return (batches.length, applied);
  }

  Future<int> _push(CloudSyncProvider provider) async {
    final deviceId = await meta.ensureDeviceId();
    // Seeded built-ins are identical on every device: never pushed.
    final since =
        await meta.readDate(SyncMetaKeys.lastPushAt) ??
        ExerciseRepository.seedTimestamp;
    // Taken before reading, so a write during the push is pushed next time.
    final startedAt = clock.now();
    final tables = {
      for (final table in syncedTableNames)
        table: await rows.changedSince(table, since),
    };
    final batch = ChangeBatch(
      deviceId: deviceId,
      createdAt: startedAt,
      tables: tables,
    );
    if (!batch.isEmpty) {
      await provider.upload(
        SyncCodec.batchName(deviceId, startedAt),
        codec.encodeBatch(batch),
      );
    }
    await meta.writeDate(SyncMetaKeys.lastPushAt, startedAt);
    return batch.rowCount;
  }

  Future<Map<String, int>> _readCursors() async {
    final raw = await meta.read(SyncMetaKeys.lastPullCursor);
    if (raw == null) return {};
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, Object?>) return {};
    return {
      for (final MapEntry(key: device, value: millis) in decoded.entries)
        if (millis is int) device: millis,
    };
  }

  Future<void> _writeCursors(Map<String, int> cursors) =>
      meta.write(SyncMetaKeys.lastPullCursor, jsonEncode(cursors));

  /// Forgets the account's sync state (sign out): the next sign-in pushes
  /// everything again and reads every batch.
  Future<void> reset() async {
    await meta.remove(SyncMetaKeys.lastPushAt);
    await meta.remove(SyncMetaKeys.lastPullCursor);
    await meta.remove(SyncMetaKeys.lastSyncAt);
    await meta.remove(SyncMetaKeys.accountEmail);
    await meta.remove(SyncMetaKeys.provider);
  }
}
