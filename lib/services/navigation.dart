import 'package:flutter/material.dart';
import '../factories/screen_factory.dart';
import '../Widgets/footer_nav_bar.dart';
import 'api_service.dart';

class NavigationService {
  static void navigate(BuildContext context, ScreenType screen,
      {Map<String, dynamic>? arguments}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ScreenFactory.createScreen(screen, arguments: arguments),
        settings: RouteSettings(name: screen.name, arguments: arguments),
      ),
    );
  }

  static void goHome(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => ScreenFactory.createScreen(ScreenType.home),
        settings: const RouteSettings(name: "home"),
      ),
      (_) => false,
    );
  }

  static void goBack(BuildContext context) {
    if (Navigator.canPop(context)) Navigator.pop(context);
  }
}

/// Handles footer button taps
Future<void> handleFooterButton(
    BuildContext context, FooterButtonType type) async {
  switch (type) {
    case FooterButtonType.settings:
      NavigationService.navigate(context, ScreenType.settings);
      break;
    case FooterButtonType.manual:
      NavigationService.navigate(context, ScreenType.manual);
      break;
    case FooterButtonType.home:
      // This ensures only one home page exists
      NavigationService.goHome(context);
      break;
    case FooterButtonType.qrScanner:
      NavigationService.navigate(context, ScreenType.scanQr);
      break;
  }
}


/// Example: create a new lobby and navigate to HostLobby page
Future<void> createGame(BuildContext context) async {
  final Map<String, dynamic> response = await ApiService.createLobby();

  if (response.isNotEmpty) {
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
Future<void> joinLobby(BuildContext context, int lobbyID) async {
  try {
    final Map<String, dynamic> lobbyData =
        await ApiService.getLobby(lobbyID);

    if (lobbyData.isNotEmpty) {
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
