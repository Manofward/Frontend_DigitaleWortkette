import 'package:flutter/material.dart';
import '../screens/home.dart';
import '../screens/game.dart';
import '../screens/manual.dart';
import '../screens/host_lobby.dart';

/// Enum to identify available screens
enum ScreenType { home, game, manual, hostLobby }

/// Factory class that creates screens
class ScreenFactory {
  static Widget createScreen(ScreenType type, {Map<String, dynamic>? arguments}) {
    switch (type) {
      // homepage case
      case ScreenType.home:
        return const DWKHomePage();
      // game screen case
      case ScreenType.game:
        return const GameScreen();
      // manual case
      case ScreenType.manual:
        return const ManualScreen();
      //host lobby case
      case ScreenType.hostLobby:
        final createdLobbyID = int.tryParse(arguments?['createdLobbyID']?.toString() ?? '') ?? 0;
        final subjects = arguments?['subjects'] ?? [];
        final maxPlayers = int.tryParse(arguments?['maxPlayers']?.toString() ?? '') ?? 0;
        final maxGameLength = int.tryParse(arguments?['maxGameLength']?.toString() ?? '') ?? 0;
        final generatedQRCode = arguments?['generatedQRCode']?.toString() ?? '';

        return HostLobbyPage(
          createdLobbyID: createdLobbyID,
          subjects: subjects, // 👈 this is a list of subjects
          maxPlayers: maxPlayers,
          maxGameLength: maxGameLength,
          generatedQRCode: generatedQRCode,
        );
      // Add more screens as needed
      default:
        throw Exception('Unknown screen type: $type');
    }
  }
}
