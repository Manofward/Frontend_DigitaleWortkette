import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_links/app_links.dart';

// Local imports for app components
import 'factories/screen_factory.dart';
import 'screens/join_lobby.dart';
import 'services/api_service.dart';
import 'services/polling/navigator_poll_observer.dart';

// Function to request necessary permissions for the app (camera and microphone)
// This is done early in the app lifecycle to ensure features like video calls work
Future<void> askPermissions() async {
  await Permission.camera.request();
  await Permission.microphone.request();
}

// Main entry point of the Flutter app
// Initializes Flutter bindings, requests permissions, then starts the app
void main() async {
  // Ensure Flutter is initialized before any async operations
  WidgetsFlutterBinding.ensureInitialized();
  // Request permissions before running the app
  await askPermissions();
  // Run the main app widget
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

// Widget that acts as a gate for permissions and deep links
// It ensures permissions are granted before showing the child widget
// Also handles deep link navigation to join lobbies
class PermissionGate extends StatefulWidget {
  final Widget child;

  const PermissionGate({super.key, required this.child});

  @override
  State<PermissionGate> createState() => _PermissionGateState();
}

class _PermissionGateState extends State<PermissionGate> {
  // Flag to track if camera and microphone permissions are granted
  bool _permissionsGranted = false;
  // Flag to prevent multiple navigations from deep links
  bool _navigated = false;

  // Stores the pending deep link URI until permissions are granted
  Uri? _pendingUri;

  // Instance for handling app links (deep links)
  late final AppLinks _appLinks;
  // Subscription to listen for incoming deep links while app is running
  StreamSubscription<Uri>? _sub;

  // Initialize state: set up app links, deep links, and check permissions
  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();
    _initDeepLinks();
    _checkPermissions();
  }

  /* ─────────── Deep Links ─────────── */

  // Initialize deep link handling for both cold start (app launched from link)
  // and warm start (link opened while app is running)
  Future<void> _initDeepLinks() async {
    // Handle cold start: get the initial link that launched the app
    final uri = await _appLinks.getInitialAppLink();
    _handleUri(uri);

    // Handle warm start: listen for links while app is running
    _sub = _appLinks.uriLinkStream.listen(_handleUri);
  }

  // Handle incoming URIs from deep links
  // Stores the URI and attempts navigation if conditions are met
  void _handleUri(Uri? uri) {
    if (uri == null || _navigated) return;

    _pendingUri = uri;
    _tryNavigate();
  }

  /* ─────────── Navigation Logic ─────────── */

  // Attempt to navigate based on the pending deep link URI
  // Only proceeds if permissions are granted and URI is valid
  void _tryNavigate() async {
    if (!_permissionsGranted || _pendingUri == null || _navigated) return;

    final uri = _pendingUri!;
    // Check if URI matches the expected scheme and host for joining a lobby
    if (uri.scheme == 'dwk' && uri.host == 'player') {
      final segments = uri.pathSegments; // Expected format: ["<LOBBY_ID>", "join"]
      if (segments.length == 2 && segments[1] == 'join') {
        final lobbyId = int.tryParse(segments[0]);
        if (lobbyId != null) {
          _navigated = true; // Prevent multiple navigations

          // Fetch lobby and player data from the API
          final lobbyData = await ApiService.getLobby(lobbyId);
          final playersData = await ApiService.getLobbyPlayers(lobbyId);

          // Use post-frame callback to ensure navigation happens after build
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
                    "hostID": 0,   // Will be updated from API if available
                    "userID": 0,   // Will be assigned after joining the lobby
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

  // Check and request camera and microphone permissions
  // Updates state and attempts navigation if permissions are granted
  Future<void> _checkPermissions() async {
    final cameraStatus = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();

    if (cameraStatus.isGranted && micStatus.isGranted) {
      setState(() => _permissionsGranted = true);
      _tryNavigate(); // Try to navigate if there's a pending deep link
    } else if (cameraStatus.isPermanentlyDenied || micStatus.isPermanentlyDenied) {
      // Open app settings if permissions are permanently denied
      openAppSettings();
    }
  }

  // Clean up resources: cancel the deep link subscription
  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  /* ─────────── UI ─────────── */

  // Build the UI: show loading indicator until permissions are granted,
  // then display the child widget (typically the home screen)
  @override
  Widget build(BuildContext context) {
    if (!_permissionsGranted) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return widget.child; // Show the main app content once permissions are granted
  }
}
