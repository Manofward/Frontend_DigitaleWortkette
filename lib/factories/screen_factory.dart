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

class ScreenFactory {
  static final Map<ScreenType, Widget Function(Map<String, dynamic>? args)> _screens = {
    ScreenType.home: (_) => const DWKHomePage(),
    ScreenType.manual: (_) => const ManualScreen(),

    /// ⛔ MUST BE REBUILT EVERY TIME
    ScreenType.hostLobby: (args) => HostLobbyPage(data: args ?? {}),

    /// ⛔ MUST BE REBUILT EVERY TIME
    ScreenType.joinLobby: (args) => JoinLobbyPage(lobbyData: args ?? {}),

    /// ⛔ Game must also rebuild (new state)
    ScreenType.game: (args) => GameScreen(
          code: args != null && args.containsKey('code') ? args['code'].toString() : '',
        ),

    ScreenType.results: (_) => const _PlaceholderScreen(title: 'Results'),
    ScreenType.settings: (_) => const _PlaceholderScreen(title: 'Settings'),
    ScreenType.scanQr: (_) => const _PlaceholderScreen(title: 'QR Scanner'),
  };

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
