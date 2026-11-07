/// Rest-end notification, scheduled at `endsAt` so it rings even when the
/// app is in the background or killed.
abstract interface class RestAlerts {
  Future<void> schedule(DateTime endsAt);
  Future<void> cancel();
}

/// Haptic feedback of a session (PLAN.md §6.5).
abstract interface class SessionHaptics {
  /// A set was validated.
  Future<void> setCompleted();

  /// The rest ended while the app is in the foreground.
  Future<void> restEnded();
}

/// Does nothing: tests, and platforms without notifications.
class SilentRestAlerts implements RestAlerts {
  const SilentRestAlerts();

  @override
  Future<void> schedule(DateTime endsAt) async {}

  @override
  Future<void> cancel() async {}
}
