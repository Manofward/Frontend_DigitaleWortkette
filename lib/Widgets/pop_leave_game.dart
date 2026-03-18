import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/theme/app_theme.dart';
import '../services/navigation.dart';

class LeaveLobby {
  /// Returns a function that can be used directly as `onPopInvoked`
  /*static PopInvokedCallback onPopInvoked({
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
          title: Text("Spiel verlassen?", style: AppTheme.lightTheme.textTheme.titleLarge),
          content: Text("Willst du die Lobby wirklich verlassen?", style: AppTheme.lightTheme.textTheme.bodyMedium),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text("Nein", style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.secondary),
                      ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text("Ja", style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.secondary),
                     ),
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
  }*/

  static Future<bool> confirmLeave({
    required BuildContext context,
    required int lobbyID,
    required int userID,
    required int hostID,
  }) async {
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          "Spiel verlassen?",
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        content: Text(
          "Willst du die Lobby wirklich verlassen?",
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
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
      LobbySession.clear();

      return true;
    }

    return false;
  }

  /// existing code — unchanged
  static PopInvokedCallback onPopInvoked({
    required BuildContext context,
    required int lobbyID,
    required int userID,
    required int hostID,
  }) {
    return (bool didPop) async {
      if (didPop) return;

      final left = await confirmLeave(
        context: context,
        lobbyID: lobbyID,
        userID: userID,
        hostID: hostID,
      );

      if (left && context.mounted) {
        Navigator.of(context).pop();
      }
    };
  }
}
