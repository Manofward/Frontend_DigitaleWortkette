import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Local imports
import 'factories/screen_factory.dart';
import 'screens/join_lobby.dart';
import 'services/api_service.dart';
import 'services/polling/navigator_poll_observer.dart';
import 'screens/dsgvo_screen.dart';

/* ────────────────────────────────────────────── */
/* MAIN */
/* ────────────────────────────────────────────── */

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DWKApp());
}

class DWKApp extends StatelessWidget {
  const DWKApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digitale Wortkette Client',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: ConsentGate(
        child: PermissionGate(
          child: ScreenFactory.createScreen(ScreenType.home),
        ),
      ),
      navigatorObservers: [
        StopPollingObserver(),
      ],
    );
  }
}

/* ────────────────────────────────────────────── */
/* DSGVO CONSENT GATE */
/* ────────────────────────────────────────────── */

class ConsentGate extends StatefulWidget {
  final Widget child;

  const ConsentGate({super.key, required this.child});

  @override
  State<ConsentGate> createState() => _ConsentGateState();
}

class _ConsentGateState extends State<ConsentGate> {
  final _storage = const FlutterSecureStorage();

  bool _checked = false;
  bool _accepted = false;

  @override
  void initState() {
    super.initState();
    _checkConsent();
  }

  Future<void> _checkConsent() async {
    final value = await _storage.read(key: 'gdprAccepted');

    setState(() {
      _accepted = value == 'true';
      _checked = true;
    });
  }

  Future<void> _accept() async {
    await _storage.write(key: 'gdprAccepted', value: 'true');

    setState(() {
      _accepted = true;
    });
  }

  void _decline() {
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    if (!_checked) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_accepted) {
      return DsgvoScreen(
        onAccepted: _accept,
        onDeclined: _decline,
      );
    }

    return widget.child;
  }
}

/* ────────────────────────────────────────────── */
/* PERMISSION + DEEPLINK GATE */
/* ────────────────────────────────────────────── */

class PermissionGate extends StatefulWidget {
  final Widget child;

  const PermissionGate({super.key, required this.child});

  @override
  State<PermissionGate> createState() => _PermissionGateState();
}

class _PermissionGateState extends State<PermissionGate> {
  bool _permissionsGranted = false;
  bool _navigated = false;

  Uri? _pendingUri;

  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _sub;

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();
    _initDeepLinks();
    _checkPermissions();
  }

  /* ─────────── Deep Links ─────────── */

  Future<void> _initDeepLinks() async {
    final uri = await _appLinks.getInitialAppLink();
    _handleUri(uri);
    _sub = _appLinks.uriLinkStream.listen(_handleUri);
  }

  void _handleUri(Uri? uri) {
    if (uri == null || _navigated) return;
    _pendingUri = uri;
    _tryNavigate();
  }

  void _tryNavigate() async {
    if (!_permissionsGranted || _pendingUri == null || _navigated) return;

    final uri = _pendingUri!;
    if (uri.scheme == 'dwk' && uri.host == 'player') {
      final segments = uri.pathSegments;

      if (segments.length == 2 && segments[1] == 'join') {
        final lobbyId = int.tryParse(segments[0]);

        if (lobbyId != null) {
          _navigated = true;

          final lobbyData = await ApiService.getLobby(lobbyId);
          final playersData = await ApiService.getLobbyPlayers(lobbyId);

          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => JoinLobbyPage(
                  lobbyData: {
                    "lobbyID": lobbyId,
                    "chosenSubjectName": lobbyData["chosenSubjectName"],
                    "chosenMaxPlayers": lobbyData["chosenMaxPlayers"],
                    "chosenMaxGameLength": lobbyData["chosenMaxGameLength"],
                    "players": playersData,
                    "hostID": 0,
                    "userID": 0,
                  },
                ),
              ),
            );
          });
        }
      }
    }
  }

  /* ─────────── Permissions ─────────── */

  Future<void> _checkPermissions() async {
    final cameraStatus = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();

    if (cameraStatus.isGranted && micStatus.isGranted) {
      setState(() => _permissionsGranted = true);
      _tryNavigate();
    } else if (cameraStatus.isPermanentlyDenied ||
        micStatus.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_permissionsGranted) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return widget.child;
  }
}