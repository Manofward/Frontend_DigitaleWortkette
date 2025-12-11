import 'package:flutter/material.dart';
import '../services/api_service.dart';

class LeaveLobby {
  /// Returns a function that can be used directly as `onPopInvoked`
  static PopInvokedCallback onPopInvoked({
    required BuildContext context,
    required int lobbyID,
    required int userID,
    required int hostID
  }) {
    return (bool didPop) async {
      if (didPop) return;

      final shouldLeave = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Spiel verlassen?"),
          content: const Text("Willst du die Lobby wirklich verlassen?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Nein"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Ja"),
            ),
          ],
        ),
      );

      if (shouldLeave == true) {
        await ApiService.leaveGame(lobbyID, userID, hostID);

        if (context.mounted) {
          Navigator.of(context).pop();
        }
      }
    };
  }
}
