import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:endelea/core/utils/clock.dart';
import 'package:endelea/data/database.dart';
import 'package:endelea/data/repositories/write_stamp.dart';

/// A clock tests move by hand.
class FakeClock implements Clock {
  FakeClock([DateTime? start]) : _now = start ?? DateTime(2026, 11, 2, 18);

  DateTime _now;

  @override
  DateTime now() => _now;

  void advance(Duration duration) => _now = _now.add(duration);
}

AppDatabase memoryDatabase() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return AppDatabase(NativeDatabase.memory());
}

WriteStamp testStamp(FakeClock clock, [String deviceId = 'device-a']) =>
    WriteStamp(clock: clock, deviceId: deviceId);
