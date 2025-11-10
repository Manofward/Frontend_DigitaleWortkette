import 'package:flutter/material.dart';
import 'api_service.dart';
import '../factories/screen_factory.dart';
import '../factories/footer_factory.dart';

/// Handles in-app navigation using Navigator and the ScreenFactory
class NavigationService {
  /// Navigate to a new screen (replaces current route)
  static void goTo(BuildContext context, ScreenType screen) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ScreenFactory.createScreen(screen)),
    );
  }

  /// Push a new screen on top of the current one
  static void push(BuildContext context, ScreenType screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ScreenFactory.createScreen(screen)),
    );
  }

  /// Go back to previous screen
  static void goBack(BuildContext context) {
    Navigator.pop(context);
  }
}

/// Example function combining API + Navigation
Future<void> createGame(BuildContext context) async {
  final response = await ApiService.post('create_game', {'player': 'Alice'});
  if (response != null) {
    debugPrint('Game created: $response');
    // After creating game, navigate to the game screen
    NavigationService.goTo(context, ScreenType.game);
  }
}

Future<void> handleFooterButton(
    BuildContext context,
    FooterButtonType type,
    ScreenType currentScreen,
) async {
  // Map of handlers for each screen
  final Map<FooterButtonType, Future<void> Function()> handlers = {
    FooterButtonType.settings: () async {
      debugPrint("${currentScreen.name} - Einstellungen geöffnet");
    },
    FooterButtonType.manual: () async {
      NavigationService.push(context, ScreenType.manual);
      debugPrint("${currentScreen.name} - Anleitung geöffnet");
    },
    FooterButtonType.home: () async {
      if (currentScreen == ScreenType.game) {
        await _confirmLeaveGame(context);
      } else if (currentScreen != ScreenType.game || currentScreen != ScreenType.home) {
        // here needs to be the linking to go to the manual page
        NavigationService.goBack(context);
      } else {
        debugPrint("Bereits auf der Startseite");
      }
    },
    FooterButtonType.qrScanner: () async {
      if (currentScreen == ScreenType.home) {
        debugPrint("QR-Code Scanner geöffnet");
      }
    },
  };

  // Call the handler if it exists
  final action = handlers[type];
  if (action != null) await action();
}

/// Shows a dialog to confirm leaving the game
Future<void> _confirmLeaveGame(BuildContext context) async {
  final leave = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Spiel verlassen?'),
      content: const Text(
          'Bist du sicher, dass du das aktuelle Spiel verlassen möchtest?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Abbrechen'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Verlassen'),
        ),
      ],
    ),
  );

  if (leave == true) {
    NavigationService.goTo(context, ScreenType.home);
  }
}