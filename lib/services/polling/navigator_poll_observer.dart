import 'package:flutter/material.dart';
import 'poll_manager.dart';

class StopPollingObserver extends NavigatorObserver {

  @override
  void didPush(Route route, Route? previousRoute) {
    PollManager.cancelAll();
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    PollManager.cancelAll();
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    PollManager.cancelAll();
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    PollManager.cancelAll();
  }
}
