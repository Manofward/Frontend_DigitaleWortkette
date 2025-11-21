import 'dart:async';

class PollManager {
  static final Set<Timer> _timers = {};

  /// Register a timer so it can be auto-cancelled on navigation
  static Timer register(Timer timer) {
    _timers.add(timer);
    return timer;
  }

  /// Cancel all active polling timers
  static void cancelAll() {
    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();
  }
}
