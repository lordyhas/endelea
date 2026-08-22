import '../models/settings.dart';

/// Formats a duration as `1h 05m`, `12:04` or `0:45`.
String formatDuration(Duration duration, {bool clock = false}) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);
  if (clock) {
    final mm = minutes.toString().padLeft(hours > 0 ? 2 : 1, '0');
    final ss = seconds.toString().padLeft(2, '0');
    return hours > 0 ? '$hours:$mm:$ss' : '$mm:$ss';
  }
  if (hours > 0) return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
  if (minutes > 0) return '${minutes}min';
  return '${seconds}s';
}

/// Formats a weight stored in kilograms in the given [unit], without
/// useless decimals.
String formatWeight(double kg, [WeightUnit unit = WeightUnit.kg]) {
  final value = unit.fromKg(kg);
  if (value >= 1000) {
    final thousands = (value / 1000).toStringAsFixed(1);
    return unit == WeightUnit.kg ? '$thousands t' : '${thousands}k lb';
  }
  return '${formatNumber(value)} ${unit.label}';
}

/// Formats a number with at most one decimal, dropping a trailing `.0`.
String formatNumber(double value) {
  final rounded = (value * 10).round() / 10;
  return rounded == rounded.roundToDouble()
      ? rounded.toStringAsFixed(0)
      : rounded.toStringAsFixed(1);
}

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

/// Formats a date as `Thu 30 Apr`.
String formatDay(DateTime date) =>
    '${_weekdays[date.weekday - 1]} ${date.day} ${_months[date.month - 1]}';

/// Formats a time as `14:05`.
String formatTime(DateTime date) =>
    '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

const _monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

/// Formats a month as `August 2026`.
String formatMonth(DateTime date) =>
    '${_monthNames[date.month - 1]} ${date.year}';

/// Writes [count] followed by [word], adding an `s` unless count is 1.
String plural(int count, String word) => '$count $word${count == 1 ? '' : 's'}';
