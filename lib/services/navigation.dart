import 'package:flutter/material.dart';
import '../factories/screen_factory.dart';
import '../Widgets/footer_nav_bar.dart';
import 'api_service.dart';

class NavigationService {
  static void navigate(BuildContext context, ScreenType screen,
      {Map<String, dynamic>? arguments, bool replaceIfHome = true}) {
    final currentRoute = ModalRoute.of(context);
    if (currentRoute?.settings.name == screen.name) return;

    final route = MaterialPageRoute(
      builder: (_) => ScreenFactory.createScreen(screen, arguments: arguments),
      settings: RouteSettings(name: screen.name, arguments: arguments),
    );

    if (replaceIfHome && (screen == ScreenType.home || screen == ScreenType.manual)) {
      Navigator.pushReplacement(context, route);
    } else {
      Navigator.push(context, route);
    }
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

/// Example: create lobby and navigate to host lobby
Future<void> createGame(BuildContext context) async {
  final response = await ApiService.createLobbyPost(
    chosenSubjectName: 'Default',
    chosenGameLength: 10,
    chosenMaxPlayer: 6,
  );

  if (response != null) {
    NavigationService.navigate(context, ScreenType.hostLobby, arguments: response);
  } else {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Error creating game')));
  }
}
