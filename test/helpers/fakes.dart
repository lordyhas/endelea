import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:endelea/core/utils/clock.dart';
import 'package:endelea/data/database.dart';
import 'package:endelea/data/repositories/write_stamp.dart';

/// A clock tests move by hand.
class FakeClock implements Clock {
  FakeClock([DateTime? start]) : time = start ?? DateTime(2026, 11, 2, 18);

  /// Current time, set by tests.
  DateTime time;

  @override
  DateTime now() => time;

  void advance(Duration duration) => time = time.add(duration);
}

AppDatabase memoryDatabase() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return AppDatabase(NativeDatabase.memory());
}

WriteStamp testStamp(FakeClock clock, [String deviceId = 'device-a']) =>
    WriteStamp(clock: clock, deviceId: deviceId);
