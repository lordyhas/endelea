import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Countdown started between two sets.
class RestTimer extends ChangeNotifier {
  RestTimer({this.defaultDuration = const Duration(seconds: 90)});

  final Duration defaultDuration;

  Timer? _ticker;
  Duration _remaining = Duration.zero;

  Duration get remaining => _remaining;
  bool get isRunning => _ticker != null;

  void start([Duration? duration]) {
    _ticker?.cancel();
    _remaining = duration ?? defaultDuration;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    notifyListeners();
  }

  void add(Duration extra) {
    if (!isRunning) return;
    _remaining += extra;
    notifyListeners();
  }

  void stop() {
    _ticker?.cancel();
    _ticker = null;
    _remaining = Duration.zero;
    notifyListeners();
  }

  void _tick() {
    _remaining -= const Duration(seconds: 1);
    if (_remaining <= Duration.zero) {
      stop();
      HapticFeedback.heavyImpact();
    } else {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
