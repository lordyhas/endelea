/// Monday 00:00 (local) of the week containing [date].
DateTime startOfWeek(DateTime date) {
  final local = date.toLocal();
  final day = DateTime(local.year, local.month, local.day);
  return day.subtract(Duration(days: day.weekday - DateTime.monday));
}

/// Local midnight of [date].
DateTime startOfDay(DateTime date) {
  final local = date.toLocal();
  return DateTime(local.year, local.month, local.day);
}

bool isSameDay(DateTime a, DateTime b) => startOfDay(a) == startOfDay(b);
