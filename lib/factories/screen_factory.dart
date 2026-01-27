import 'package:flutter/material.dart';

// Screens
import '../screens/home.dart';
import '../screens/game.dart';
import '../screens/manual.dart';
import '../screens/host_lobby.dart';
import '../screens/join_lobby.dart';

enum ScreenType {
  home,
  game,
  manual,
  hostLobby,
  joinLobby,
  results,
  settings,
  scanQr,
}

// Factory class for creating screen widgets based on ScreenType
// This centralizes screen creation logic and ensures consistency
// across navigation throughout the app
class ScreenFactory {
  // Map of screen types to their builder functions
  // Some screens require arguments (like lobby data), others are stateless
  static final Map<ScreenType, Widget Function(Map<String, dynamic>? args)> _screens = {
    ScreenType.home: (_) => const DWKHomePage(), // Home screen, no arguments needed
    ScreenType.manual: (_) => const ManualScreen(), // Manual/rules screen

    // These screens MUST be rebuilt each time because they contain dynamic state
    // Reusing the same instance would cause state to persist incorrectly
    ScreenType.hostLobby: (args) => HostLobbyPage(data: args ?? {}),
    ScreenType.joinLobby: (args) => JoinLobbyPage(lobbyData: args ?? {}),
    ScreenType.game: (args) => GameScreen(lobbyData: args ?? {}), // Game state changes frequently

    // Placeholder screens for features not yet implemented
    ScreenType.results: (_) => const _PlaceholderScreen(title: 'Results'),
    ScreenType.settings: (_) => const _PlaceholderScreen(title: 'Settings'),
    ScreenType.scanQr: (_) => const _PlaceholderScreen(title: 'QR Scanner'),
  };

  // Create and return a screen widget based on the type
  // Arguments are passed to screens that need them (like lobby data)
  static Widget createScreen(ScreenType type, {Map<String, dynamic>? arguments}) {
    final builder = _screens[type];
    if (builder != null) return builder(arguments);
    throw Exception('Screen not implemented for type: $type');
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(
          child: Text('$title\n(Not implemented yet)', textAlign: TextAlign.center),
        ),
      );
}
