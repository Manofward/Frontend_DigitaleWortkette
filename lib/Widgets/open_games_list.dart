import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/navigation.dart';
import '../factories/screen_factory.dart';

class OpenGamesList extends StatefulWidget {
  const OpenGamesList({super.key});

  @override
  State<OpenGamesList> createState() => _OpenGamesListState();
}

class _OpenGamesListState extends State<OpenGamesList> {
  List<dynamic> openGames = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await ApiService.homepageGet();
    setState(() {
      openGames = result;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());

    if (openGames.isEmpty) {
      return const Center(child: Text("Keine offenen Spiele verfügbar"));
    }

    return ListView.builder(
      itemCount: openGames.length,
      itemBuilder: (context, index) {
        final game = openGames[index];
        return Card(
          child: ListTile(
            title: Text("Lobby: ${game['lobbyID']}"),
            subtitle: Text("Thema: ${game['topic']} • Max Spieler: ${game['players']}"),
            trailing: IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: () {
                NavigationService.navigate(
                  context,
                  ScreenType.joinLobby,
                  arguments: {"lobbyID": game["lobbyID"]},
                );
              },
            ),
          ),
        );
      },
    );
  }
}
