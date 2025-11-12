import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/services/navigation.dart';
import '../services/api_service.dart';

class OpenGamesList extends StatefulWidget {
  const OpenGamesList({super.key});

  @override
  State<OpenGamesList> createState() => _OpenGamesListState();
}

class _OpenGamesListState extends State<OpenGamesList> {
  List<dynamic> openGames = [];
  bool isLoading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchGames();
    // Auto-refresh every 5 seconds
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _fetchGames());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchGames() async {
    final data = await ApiService.homepageGet();
    if (mounted) {
      setState(() {
        openGames = data ?? [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (openGames.isEmpty) {
      return const Text('Keine offenen Spiele gefunden');
    }

    return Expanded(
      child: ListView.builder(
        itemCount: openGames.length,
        itemBuilder: (context, index) {
          final game = openGames[index];
          return Card(
            child: ListTile(
              // uses the parsed json values
              title: Text('Lobby: ${game['lobbyID']}'),
              subtitle: Text('Thema: ${game['topic']} • Spieler: ${game['players']}'),
              // new join Game Button for joining a game from the game List
              trailing: IconButton(
                icon: const Icon(Icons.play_arrow_sharp),
                tooltip: 'Dem Spiel Beitretten',
                onPressed: () => joinLobby(context ,game['lobbyID']),
              ),
            ),
          );
        },
      ),
    );
  }
}
