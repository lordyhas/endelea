import 'package:endelea/utils/format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formatDuration', () {
    expect(formatDuration(const Duration(seconds: 45)), '45s');
    expect(formatDuration(const Duration(minutes: 28)), '28min');
    expect(formatDuration(const Duration(minutes: 62)), '1h 02m');
    expect(formatDuration(const Duration(seconds: 75), clock: true), '1:15');
    expect(
      formatDuration(const Duration(hours: 1, seconds: 5), clock: true),
      '1:00:05',
    );
  });

  test('formatWeight', () {
    expect(formatWeight(60), '60 kg');
    expect(formatWeight(12.5), '12.5 kg');
    expect(formatWeight(2400), '2.4 t');
  });

  test('formatDay and formatTime', () {
    final date = DateTime(2026, 4, 30, 9, 5);
    expect(formatDay(date), 'Thu 30 Apr');
    expect(formatTime(date), '09:05');
  });
}
