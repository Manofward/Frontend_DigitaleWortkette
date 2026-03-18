import 'dart:async';
import 'dart:isolate';

class PollHandle {
  final Isolate isolate;
  final SendPort sendPort;

  PollHandle(this.isolate, this.sendPort);

  void stop() {
    sendPort.send({'stop': true});
  }
}

class PollManager {
  static final List<PollHandle> _activePolls = [];

  /// Start a background isolate polling loop
  static Future<PollHandle> startPolling({
    required Duration interval,
    required Future<dynamic> Function() task,
    required void Function(dynamic data) onUpdate,
  }) async {
    // 🔹 Port only to receive the initial sendPort from isolate
    final handshakePort = ReceivePort();

    // Create isolate
    final isolate = await Isolate.spawn(
      _pollIsolateEntry,
      {
        'sendPort': handshakePort.sendPort,
        'interval': interval.inMilliseconds,
      },
    );

    // Wait for isolate sendPort
    final SendPort isolateSendPort = await handshakePort.first;

    // 🔹 NEW: dedicated message port for updates
    final messagePort = ReceivePort();

    // Tell isolate where it should send messages
    isolateSendPort.send({'messagePort': messagePort.sendPort});

    // Listen to all subsequent messages
    messagePort.listen((message) async {
      if (message is Map && message['doTask'] == true) {
        final result = await task();
        isolateSendPort.send({'result': result});
      }

      if (message is Map && message['update'] != null) {
        onUpdate(message['update']);
      }
    });

    final handle = PollHandle(isolate, isolateSendPort);
    _activePolls.add(handle);

    return handle;
  }

  /// Stop all polling isolates
  static void cancelAll() {
    for (final poll in _activePolls) {
      poll.stop();
      poll.isolate.kill(priority: Isolate.immediate);
    }
    _activePolls.clear();
  }
}

/// --------------------------------------------
/// Isolate entry function (updated to use 2 ports)
/// --------------------------------------------
void _pollIsolateEntry(Map args) {
  final SendPort handshakeSendPort = args['sendPort'];
  final intervalMs = args['interval'];

  // Main port to receive commands from UI isolate
  final isolateReceivePort = ReceivePort();

  // Send UI isolate our receive-port so it can message us
  handshakeSendPort.send(isolateReceivePort.sendPort);

  SendPort? uiMessagePort;  
  Timer? timer;

  isolateReceivePort.listen((message) {
    // UI gives us the port to send updates back
    if (message is Map && message['messagePort'] != null) {
      uiMessagePort = message['messagePort'];
      timer = Timer.periodic(Duration(milliseconds: intervalMs), (_) {
        uiMessagePort?.send({'doTask': true});
      });
    }

    if (message is Map && message['stop'] == true) {
      timer?.cancel();
    }

    if (message is Map && message['result'] != null) {
      uiMessagePort?.send({'update': message['result']});
    }
  });
}
