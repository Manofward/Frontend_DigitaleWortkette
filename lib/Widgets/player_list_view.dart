import 'package:flutter/material.dart';

class PlayerListView extends StatelessWidget {
  final List<String> players;

  const PlayerListView({super.key, required this.players});

  @override
  Widget build(BuildContext context) {
    if (players.isEmpty) return const Text('Keine Spieler beigetreten.');
    return ListView.builder(
      itemCount: players.length,
      itemBuilder: (context, index) => Text('- ${players[index]}'),
    );
  }
}
