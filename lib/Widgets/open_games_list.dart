import 'package:flutter/material.dart';
import '../services/polling/poll_manager.dart';
import '../../services/api_service.dart';
import '../../services/navigation.dart';
import '../factories/screen_factory.dart';
import '../utils/theme/app_theme.dart';
import '../Widgets/loading_animation.dart';

// Widget that displays a list of open/available games (lobbies)
// Uses polling to keep the list updated in real-time
class OpenGamesList extends StatefulWidget {
  const OpenGamesList({super.key});

  @override
  State<OpenGamesList> createState() => _OpenGamesListState();
}

class _OpenGamesListState extends State<OpenGamesList> {
  // List to store the open games data fetched from the API
  List<Map<String, dynamic>> openGames = [];
  // Flag to track if initial loading is complete
  bool loading = false;

  @override
  void initState() {
    super.initState();

    // Start polling the homepage API every 5 seconds to get updated game list
    // This ensures the list stays current without manual refresh
    PollManager.startPolling(
      interval: const Duration(seconds: 5),
      task: () => ApiService.homepageGet(), // API call to fetch open games
      onUpdate: (result) {
        // Convert the API result to a list of game maps
        final games = result
            .map<Map<String, dynamic>>(
              (e) => Map<String, dynamic>.from(e as Map),
            )
            .where((game) => game["hasGameStarted"] == false)
            .toList();

        // Update state only if the widget is still mounted (prevents errors)
        if (mounted) {
          setState(() {
            openGames = games;
            loading = true; // Mark loading as complete
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show loading animation while waiting for initial data
    if (!loading) return LoadingAnimation.loadingAnimation();

    // Show message if no games are available
    if (openGames.isEmpty) {
      return Center(child: Text("Keine offenen Spiele verfügbar", style: AppTheme.lightTheme.textTheme.bodySmall));
    }

    // Build a scrollable list of available games
    return ListView.builder(
      itemCount: openGames.length,
      itemBuilder: (context, index) {
        final game = openGames[index]; // Current game data

        return Card( // Material Design card for each game
          child: ListTile(
            // Display lobby ID as the main title
            title: Text("Lobby: ${game['lobbyID']}", style: AppTheme.lightTheme.textTheme.bodyLarge),
            // Rich text subtitle showing game details (topic and max players)
            subtitle: RichText(
                text: TextSpan(
                  style: AppTheme.lightTheme.textTheme.bodyMedium, // Base style for all text
                  children: <TextSpan>[
                    // Topic/Subject label and value
                    const TextSpan(text: "Thema: "),
                    TextSpan(
                      text: "${game['topic']}", // Game topic from API
                      style: TextStyle(
                        color: AppTheme.lightTheme.colorScheme.primary, // Highlighted color
                      ),
                    ),
                    const TextSpan(text: "\n"), // Line break

                    // Max players label and value
                    const TextSpan(text: "Max Spieler: "),
                    TextSpan(
                      text: "${game['players']}", // Max players from API
                      style: TextStyle(
                        color: AppTheme.lightTheme.colorScheme.primary // Highlighted color
                      ),
                    ),
                  ],
                ),
              ),
            // Play button to join the game
            trailing: IconButton(
              icon: const Icon(Icons.play_arrow),
              iconSize: 40,
              onPressed: () {
                // Navigate to join lobby screen with game data as arguments
                NavigationService.navigate(
                  context,
                  ScreenType.joinLobby,
                  arguments: game, // Pass entire game data to join screen
                );
              },
            ),
          ),
        );
      },
    );
  }
}
