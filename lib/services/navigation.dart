import 'package:flutter/material.dart';
import 'api_service.dart';
import '../factories/screen_factory.dart';
import '../Widgets/footer_nav_bar.dart';

// This class has the navigation methods
class NavigationService {
  static void navigate(BuildContext context, ScreenType screen) {
    final currentRoute = ModalRoute.of(context);
    // when you press the button for the page your already on
    if (currentRoute?.settings.name == screen.name) {
      debugPrint("Already on ${screen.name}, not navigating.");
      return;
    }

    // If navigating to "home" or "manual", replace; else push
    if (screen == ScreenType.home || screen == ScreenType.manual) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ScreenFactory.createScreen(screen),
          settings: RouteSettings(name: screen.name),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ScreenFactory.createScreen(screen),
          settings: RouteSettings(name: screen.name),
        ),
      );
    }
  }

  static void goBack(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }
}

/// This function has to be changed later on so that when creating the game you use a get/post from api_service.dart
Future<void> createGame(BuildContext context) async {
  final response = await ApiService.post('create_game', {'player': 'Alice'});
  if (response != null) {
    debugPrint('Game created: $response');
    // After creating game, navigate to the game screen
    NavigationService.navigate(context, ScreenType.game);
  }
}

// this Method handles the footer button navigation
// For example i want to go from home to manual which works. But i cant go from home to home
Future<void> handleFooterButton(
    BuildContext context,
    FooterButtonType type,
) async {
  final currentRouteName = ModalRoute.of(context)?.settings.name;

  switch (type) {
    case FooterButtonType.settings:
      debugPrint("$currentRouteName - Einstellungen geöffnet");
      break;

    case FooterButtonType.manual:
      NavigationService.navigate(context, ScreenType.manual);
      break;

    case FooterButtonType.home:
      if (currentRouteName == ScreenType.game.name) {
        await _confirmLeaveGame(context);
      } else {
        NavigationService.navigate(context, ScreenType.home);
      }
      break;

    case FooterButtonType.qrScanner:
      if (currentRouteName == ScreenType.home.name) {
        debugPrint("QR-Code Scanner geöffnet");
      } else {
        debugPrint("QR-Code Scanner nur auf der Startseite verfügbar");
      }
      break;
  }
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
    NavigationService.navigate(context, ScreenType.home);
  }
}