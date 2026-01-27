import 'package:flutter/material.dart';
import '../factories/screen_factory.dart';
import '../Widgets/footer_nav_bar.dart';
import 'api_service.dart';
import '../Widgets/pop_leave_game.dart';

class LobbySession {
  static int? lobbyID;
  static int? userID;
  static int? hostID;

  static bool get isActive => lobbyID != null;

  static void clear() {
    lobbyID = null;
    userID = null;
    hostID = null;
  }
}

// Service class for handling navigation throughout the app
// Centralizes navigation logic and uses ScreenFactory for consistency
class NavigationService {
  // Navigate to a new screen by pushing it onto the navigation stack
  // Arguments can be passed to screens that need them (like lobby data)
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

  // Navigate to the home screen and clear the entire navigation stack
  // This ensures there's only one home screen instance and resets the app state
  static void goHome(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => ScreenFactory.createScreen(ScreenType.home),
        settings: const RouteSettings(name: "home"),
      ),
      (_) => false, // Remove all previous routes
    );
  }

  // Go back to the previous screen if possible
  static void goBack(BuildContext context) {
    if (Navigator.canPop(context)) Navigator.pop(context);
  }
}

/// Handles footer button taps
Future<void> handleFooterButton(BuildContext context, FooterButtonType type) async {
  if (type == FooterButtonType.qrScanner || type == FooterButtonType.home && LobbySession.isActive) {
    final left = await LeaveLobby.confirmLeave(
      context: context,
      lobbyID: LobbySession.lobbyID!,
      userID: LobbySession.userID!,
      hostID: LobbySession.hostID!,
    );

    if (!left) return;
  } 

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


// Create a new game lobby and navigate to the host lobby screen
// This function handles the API call and navigation logic for starting a new game
Future<void> createGame(BuildContext context) async {
  final Map<String, dynamic> response = await ApiService.createLobby();

  if (response.isNotEmpty) {
    // Successfully created lobby, navigate to host screen with lobby data
    NavigationService.navigate(
      context,
      ScreenType.hostLobby,
      arguments: response,
    );
  } else {
    // Failed to create lobby, show error message
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Error creating game')));
  }
}

// Join an existing lobby using its ID and navigate to the join lobby screen
// Handles API calls, error checking, and navigation for joining games
Future<void> joinLobby(BuildContext context, int lobbyID) async {
  try {
    // Fetch lobby data from the API
    final Map<String, dynamic> lobbyData =
        await ApiService.getLobby(lobbyID);

    if (lobbyData.isNotEmpty) {
      // Lobby found, navigate to join screen with lobby data
      NavigationService.navigate(
        context,
        ScreenType.joinLobby,
        arguments: lobbyData,
      );
    } else {
      // Lobby not found or empty response
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lobby konnte nicht gefunden werden')),
      );
    }
  } catch (e) {
    // Handle any errors during the API call
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Fehler: $e')),
    );
  }
}
