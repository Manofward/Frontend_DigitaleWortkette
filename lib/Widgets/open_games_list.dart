import 'package:flutter/material.dart';
import '../services/polling/poll_manager.dart';
import '../../services/api_service.dart';
import '../../services/navigation.dart';
import '../factories/screen_factory.dart';
import '../utils/theme/app_theme.dart';

import '../Widgets/loading_animation.dart';

class OpenGamesList extends StatefulWidget {
  const OpenGamesList({super.key});

  @override
  State<OpenGamesList> createState() => _OpenGamesListState();
}

class _OpenGamesListState extends State<OpenGamesList> {
  List<Map<String, dynamic>> openGames = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();

    PollManager.startPolling(
      interval: const Duration(seconds: 5),
      task: () => ApiService.homepageGet(),
      onUpdate: (result) {
        final games = result
            .map<Map<String, dynamic>>(
              (e) => Map<String, dynamic>.from(e as Map),
            )
            .toList();

        if (mounted) {
          setState(() {
            openGames = games;
            loading = true;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!loading) return LoadingAnimation.loadingAnimation(); // added a general loading animation for if the loading process takes to long

    if (openGames.isEmpty) {
      return Center(child: Text("Keine offenen Spiele verfügbar", style: AppTheme.lightTheme.textTheme.bodySmall));
    }

    return ListView.builder(
      itemCount: openGames.length,
      itemBuilder: (context, index) {
        final game = openGames[index];

        return Card(
          child: ListTile(
            title: Text("Lobby: ${game['lobbyID']}", style: AppTheme.lightTheme.textTheme.bodyLarge),
            subtitle: RichText(
                text: TextSpan(
                  style: AppTheme.lightTheme.textTheme.bodyMedium, // general font size of the Lobby Data
                  children: <TextSpan>[
                    // subject
                    const TextSpan(text: "Thema: "),
                    TextSpan(
                      text: "${game['topic']}", // should show the subject text
                      style: TextStyle(
                        color: AppTheme.lightTheme.colorScheme.primary//Colors.orange[900],
                      ),
                    ),
                    TextSpan(text:"\n"),

                    // Max Game Length
                    const TextSpan(text: "Max Spieler: "),
                    TextSpan(
                      text: "${game['players']}",
                      style: TextStyle(
                        color: AppTheme.lightTheme.colorScheme.primary
                      ),
                    ),
                  ],
                ),
              ),
            trailing: IconButton(
              icon: const Icon(Icons.play_arrow),
              iconSize: 40,
              onPressed: () {
                NavigationService.navigate(
                  context,
                  ScreenType.joinLobby,
                  arguments: game,
                );
              },
            ),
          ),
        );
      },
    );
  }
}