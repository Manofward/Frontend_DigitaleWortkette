import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_links/app_links.dart';

import 'factories/screen_factory.dart';
import 'screens/join_lobby.dart';
import 'services/api_service.dart';
import 'services/polling/navigator_poll_observer.dart';

Future<void> askPermissions() async {
  await Permission.camera.request();
  await Permission.microphone.request();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await askPermissions();
  runApp(const DWKApp());
}

class DWKApp extends StatelessWidget {
  const DWKApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digitale Wortkette Client',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: PermissionGate(
        child: ScreenFactory.createScreen(ScreenType.home),
      ),
      navigatorObservers: [
        StopPollingObserver(),
      ],
    );
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
    // Cold start
    final uri = await _appLinks.getInitialAppLink();
    _handleUri(uri);

    // Warm start / already running
    _sub = _appLinks.uriLinkStream.listen(_handleUri);
  }

  void _handleUri(Uri? uri) {
    if (uri == null || _navigated) return;

    _pendingUri = uri;
    _tryNavigate();
  }

  /* ─────────── Navigation Logic ─────────── */

  void _tryNavigate() async {
    if (!_permissionsGranted || _pendingUri == null || _navigated) return;

    final uri = _pendingUri!;
    if (uri.scheme == 'dwk' && uri.host == 'player') {
      final segments = uri.pathSegments; // ["<LOBBY_ID>", "join"]
      if (segments.length == 2 && segments[1] == 'join') {
        final lobbyId = int.tryParse(segments[0]);
        if (lobbyId != null) {
          _navigated = true;

          // Fetch lobby data from API
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
                    "hostID": 0,   // Optional: update from API if available
                    "userID": 0,   // Will be assigned after postJoinLobby
                  },
                ),
              ),
            );
          });
        }
      }
    }
  }


  /* ─────────── Permission Gate ─────────── */

  Future<void> _checkPermissions() async {
    final cameraStatus = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();

    if (cameraStatus.isGranted && micStatus.isGranted) {
      setState(() => _permissionsGranted = true);
      _tryNavigate();
    } else if (cameraStatus.isPermanentlyDenied || micStatus.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  /* ─────────── UI ─────────── */

  @override
  Widget build(BuildContext context) {
    if (!_permissionsGranted) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return widget.child; // fallback home screen
  }
}
