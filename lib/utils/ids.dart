var _last = 0;

/// Unique id made of [prefix] and the current time in microseconds.
///
/// Two ids created in the same microsecond still differ.
String newId(String prefix) {
  var now = DateTime.now().microsecondsSinceEpoch;
  if (now <= _last) now = _last + 1;
  _last = now;
  return '$prefix-$now';
}
