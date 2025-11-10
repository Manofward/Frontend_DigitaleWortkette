import 'package:flutter/material.dart';
import '../screens/home.dart';
import '../screens/game.dart';
import '../screens/manual.dart';

/// Enum to identify available screens
enum ScreenType { home, game, manual }

/// Factory class that creates screens
class ScreenFactory {
  static Widget createScreen(ScreenType type) {
    switch (type) {
      case ScreenType.home:
        return const DWKHomePage();
      case ScreenType.game:
        return const GameScreen();
      case ScreenType.manual:
        return const ManualScreen();
      // Add more screens as needed
      default:
        throw Exception('Unknown screen type: $type');
    }
  }
}
