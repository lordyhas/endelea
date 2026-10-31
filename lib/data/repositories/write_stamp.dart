import 'package:endelea/core/utils/clock.dart';

/// Who and when, for every local write (`updatedAt`, `lastModifiedBy`).
class WriteStamp {
  const WriteStamp({required this.clock, required this.deviceId});

  final Clock clock;
  final String deviceId;

  /// Current time, normalized for storage.
  DateTime now() => normalizeTimestamp(clock.now());
}

/// Drift stores dates as ISO-8601 text and compares them as strings, so every
/// stored timestamp must use the same format: UTC, millisecond precision.
/// Convert with `toLocal()` for display.
DateTime normalizeTimestamp(DateTime value) {
  final utc = value.toUtc();
  return DateTime.fromMillisecondsSinceEpoch(
    utc.millisecondsSinceEpoch,
    isUtc: true,
  );
}
