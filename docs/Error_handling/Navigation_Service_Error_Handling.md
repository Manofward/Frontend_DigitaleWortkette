# Navigation Service Error Handling Guide

This guide covers adding robust error handling to the navigation logic in your Flutter app, specifically for the `NavigationService` and related functions in `lib/services/navigation.dart`. Proper error handling in navigation prevents crashes, provides user feedback, and ensures smooth transitions between screens.

## Common Error Scenarios

1. **Invalid Route Arguments**: Missing or incorrect data passed to screens.
2. **Screen Creation Failures**: Errors when building screens with invalid data.
3. **Navigation Stack Issues**: Problems with popping or pushing routes.
4. **Context Issues**: Using invalid or disposed contexts for navigation.
5. **API-Dependent Navigation**: Failures when navigation depends on API responses.

## Best Practices

- Validate arguments before navigation.
- Handle exceptions during screen creation.
- Provide fallback navigation when primary routes fail.
- Use try-catch blocks around navigation calls.
- Log navigation errors for debugging.
- Show user-friendly error messages.

## Code Examples

### 1. Enhanced NavigationService with Error Handling

**Before:**
```dart
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
```

**After:**
```dart
class NavigationService {
  static void navigate(BuildContext context, ScreenType screen,
      {Map<String, dynamic>? arguments}) {
    try {
      // Validate arguments if required for the screen
      _validateArguments(screen, arguments);

      final route = MaterialPageRoute(
        builder: (_) {
          try {
            return ScreenFactory.createScreen(screen, arguments: arguments);
          } catch (e) {
            debugPrint('Error creating screen $screen: $e');
            // Return error screen instead of crashing
            return _buildErrorScreen('Fehler beim Laden der Seite', e.toString());
          }
        },
        settings: RouteSettings(name: screen.name, arguments: arguments),
      );

      Navigator.push(context, route);
    } catch (e) {
      debugPrint('Navigation error to $screen: $e');
      _showNavigationError(context, 'Navigation fehlgeschlagen');
    }
  }

  static void goHome(BuildContext context) {
    try {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) {
            try {
              return ScreenFactory.createScreen(ScreenType.home);
            } catch (e) {
              debugPrint('Error creating home screen: $e');
              return _buildErrorScreen('Fehler beim Laden der Startseite', e.toString());
            }
          },
          settings: const RouteSettings(name: "home"),
        ),
        (_) => false,
      );
    } catch (e) {
      debugPrint('Error navigating to home: $e');
      _showNavigationError(context, 'Fehler beim Zurückkehren zur Startseite');
    }
  }

  static void goBack(BuildContext context) {
    try {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      } else {
        debugPrint('Cannot go back: no routes to pop');
        // Optionally navigate to home as fallback
        goHome(context);
      }
    } catch (e) {
      debugPrint('Error going back: $e');
      _showNavigationError(context, 'Fehler beim Zurückgehen');
    }
  }

  static void _validateArguments(ScreenType screen, Map<String, dynamic>? arguments) {
    switch (screen) {
      case ScreenType.hostLobby:
      case ScreenType.joinLobby:
      case ScreenType.game:
        if (arguments == null || arguments.isEmpty) {
          throw ArgumentError('Arguments required for $screen');
        }
        if (!arguments.containsKey('lobbyID')) {
          throw ArgumentError('lobbyID required for $screen');
        }
        break;
      // Add validation for other screens as needed
      default:
        break;
    }
  }

  static Widget _buildErrorScreen(String title, String error) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(error, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // This would need access to context, so we might need to modify this approach
                  // For now, just show a message
                },
                child: const Text('Zur Startseite'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void _showNavigationError(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
}
```

### 2. Enhanced createGame Function with Error Handling

**Before:**
```dart
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
```

**After:**
```dart
Future<void> createGame(BuildContext context) async {
  try {
    final Map<String, dynamic> response = await ApiService.createLobby();

    if (response.isNotEmpty) {
      NavigationService.navigate(
        context,
        ScreenType.hostLobby,
        arguments: response,
      );
    } else {
      throw Exception('Empty response from createLobby');
    }
  } on NetworkException catch (e) {
    debugPrint('Network error creating game: $e');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Netzwerkfehler beim Erstellen des Spiels'),
          action: SnackBarAction(
            label: 'Erneut versuchen',
            onPressed: () => createGame(context),
          ),
        ),
      );
    }
  } on ApiException catch (e) {
    debugPrint('API error creating game: $e');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Erstellen des Spiels: $e')),
      );
    }
  } catch (e) {
    debugPrint('Unexpected error creating game: $e');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unerwarteter Fehler beim Erstellen des Spiels')),
      );
    }
  }
}
```

### 3. Enhanced joinLobby Function with Error Handling

**Before:**
```dart
Future<void> joinLobby(BuildContext context, int lobbyID) async {
  try {
    final Map<String, dynamic> lobbyData =
        await ApiService.getLobby(lobbyID);

    if (lobbyData.isNotEmpty) {
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
```

**After:**
```dart
Future<void> joinLobby(BuildContext context, int lobbyID) async {
  try {
    final Map<String, dynamic> lobbyData = await ApiService.getLobby(lobbyID);

    if (lobbyData.isNotEmpty) {
      NavigationService.navigate(
        context,
        ScreenType.joinLobby,
        arguments: {
          ...lobbyData,
          'lobbyID': lobbyID, // Ensure lobbyID is included
        },
      );
    } else {
      throw Exception('Lobby data is empty');
    }
  } on NetworkException catch (e) {
    debugPrint('Network error joining lobby $lobbyID: $e');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Netzwerkfehler beim Laden der Lobby'),
          action: SnackBarAction(
            label: 'Erneut versuchen',
            onPressed: () => joinLobby(context, lobbyID),
          ),
        ),
      );
    }
  } on ApiException catch (e) {
    debugPrint('API error joining lobby $lobbyID: $e');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lobby konnte nicht gefunden werden: $e')),
      );
    }
  } catch (e) {
    debugPrint('Unexpected error joining lobby $lobbyID: $e');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unerwarteter Fehler: $e')),
      );
    }
  }
}
```

### 4. Enhanced handleFooterButton with Error Handling

**Before:**
```dart
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
      NavigationService.goHome(context);
      break;
    case FooterButtonType.qrScanner:
      NavigationService.navigate(context, ScreenType.scanQr);
      break;
  }
}
```

**After:**
```dart
Future<void> handleFooterButton(BuildContext context, FooterButtonType type) async {
  try {
    // Handle leave confirmation for certain buttons
    if ((type == FooterButtonType.qrScanner || type == FooterButtonType.home) && LobbySession.isActive) {
      final left = await LeaveLobby.confirmLeave(
        context: context,
        lobbyID: LobbySession.lobbyID!,
        userID: LobbySession.userID!,
        hostID: LobbySession.hostID!,
      );

      if (!left) return; // User cancelled leaving
    }

    switch (type) {
      case FooterButtonType.settings:
        NavigationService.navigate(context, ScreenType.settings);
        break;
      case FooterButtonType.manual:
        NavigationService.navigate(context, ScreenType.manual);
        break;
      case FooterButtonType.home:
        NavigationService.goHome(context);
        break;
      case FooterButtonType.qrScanner:
        NavigationService.navigate(context, ScreenType.scanQr);
        break;
    }
  } catch (e) {
    debugPrint('Error handling footer button $type: $e');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Navigation fehlgeschlagen: $e')),
      );
    }
  }
}
```

## Conclusion

Implementing error handling in your navigation service ensures:

- Graceful handling of navigation failures
- Better user feedback during errors
- Prevention of app crashes due to invalid routes
- Robust argument validation
- Fallback mechanisms for critical navigation

Remember to test navigation flows thoroughly, including edge cases like network failures during navigation and invalid route arguments.
