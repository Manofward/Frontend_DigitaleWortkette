import 'package:flutter/material.dart';
import '../factories/screen_factory.dart';
import '../Widgets/footer_nav_bar.dart';
import 'api_service.dart';

class NavigationService {
  /// Keep single instances of non-Home pages
  static final Map<ScreenType, Widget> _pageInstances = {};

  static void navigate(BuildContext context, ScreenType screen,
      {Map<String, dynamic>? arguments}) {
    final currentRoute = ModalRoute.of(context);
    if (currentRoute?.settings.name == screen.name) return;

    // Home: always single instance, clears the stack
    if (screen == ScreenType.home) {
      final route = MaterialPageRoute(
        builder: (_) => ScreenFactory.createScreen(screen, arguments: arguments),
        settings: RouteSettings(name: screen.name, arguments: arguments),
      );
      Navigator.pushAndRemoveUntil(context, route, (r) => false);
      return;
    }

    // HostLobby: single instance, keep previous stack
    if (screen == ScreenType.hostLobby) {
      Widget page;
      if (_pageInstances.containsKey(screen)) {
        page = _pageInstances[screen]!;
      } else {
        page = ScreenFactory.createScreen(screen, arguments: arguments);
        _pageInstances[screen] = page;
      }

      final route = MaterialPageRoute(
        builder: (_) => page,
        settings: RouteSettings(name: screen.name, arguments: arguments),
      );

      // Remove any existing HostLobby in the stack
      Navigator.pushAndRemoveUntil(
          context, route, (r) => r.settings.name != ScreenType.hostLobby.name);
      return;
    }

    // Other pages: reuse existing instance if available
    Widget page;
    if (_pageInstances.containsKey(screen)) {
      page = _pageInstances[screen]!;
    } else {
      page = ScreenFactory.createScreen(screen, arguments: arguments);
      _pageInstances[screen] = page;
    }

    final route = MaterialPageRoute(
      builder: (_) => page,
      settings: RouteSettings(name: screen.name, arguments: arguments),
    );

    Navigator.push(context, route);
  }

  static void goBack(BuildContext context) {
    if (Navigator.canPop(context)) Navigator.pop(context);
  }
}

/// Handles footer button taps
Future<void> handleFooterButton(BuildContext context, FooterButtonType type) async {
  switch (type) {
    case FooterButtonType.settings:
      NavigationService.navigate(context, ScreenType.settings);
      break;
    case FooterButtonType.manual:
      NavigationService.navigate(context, ScreenType.manual);
      break;
    case FooterButtonType.home:
      NavigationService.navigate(context, ScreenType.home);
      break;
    case FooterButtonType.qrScanner:
      NavigationService.navigate(context, ScreenType.scanQr);
      break;
  }
}

/// Example: create a new lobby and navigate to HostLobby page
/// Example: create a new lobby and navigate to HostLobby page
Future<void> createGame(BuildContext context) async {
  final response = await ApiService.createLobby(
    subject: 'Default',
    maxGameLength: 10,
    maxPlayers: 6,
  );

  if (response != null) {
    NavigationService.navigate(
      context,
      ScreenType.hostLobby,
      arguments: response,
    );
  } else {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Error creating game')));
  }
}


/// Join an existing lobby by code
Future<void> joinLobby(BuildContext context, String lobbyCode) async {
  try {
    final lobbyData = await ApiService.getLobby(lobbyCode);

    if (lobbyData != null) {
      // Navigate to the join lobby screen with the data
      NavigationService.navigate(
        context,
        ScreenType.joinLobby,
        arguments: lobbyData,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lobby konnte nicht gefunden werden')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Fehler: $e')),
    );
  }
}

