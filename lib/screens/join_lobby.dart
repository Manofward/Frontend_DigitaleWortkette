import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/navigation.dart';
import '../../factories/screen_factory.dart';

class JoinLobbyPage extends StatefulWidget {
  final int lobbyID;
  const JoinLobbyPage({super.key, required this.lobbyID});

  @override
  State<JoinLobbyPage> createState() => _JoinLobbyPageState();
}

class _JoinLobbyPageState extends State<JoinLobbyPage> {
  String username = "";
  bool ready = false;

  Map<String, dynamic>? lobbySettings;
  List<dynamic> players = [];

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadPlayers();

    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _loadPlayers());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final res = await ApiService.getJoinLobbySettings();
    setState(() => lobbySettings = res);
  }

  Future<void> _loadPlayers() async {
    final res = await ApiService.getHostLobbyPlayers();
    setState(() => players = res);

    // Auto-start if all ready
    if (players.isNotEmpty && players.every((p) => p["isPlayerReady"] == true)) {
      NavigationService.navigate(
        context,
        ScreenType.game,
        arguments: {"code": widget.lobbyID.toString()},
      );
    }
  }

  Future<void> _sendReady() async {
    if (username.isEmpty) return;

    await ApiService.postJoinLobby(username, ready);
    _loadPlayers();
  }

  @override
  Widget build(BuildContext context) {
    if (lobbySettings == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text("Lobby #${widget.lobbyID}")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Thema: ${lobbySettings!['subject']}"),
            Text("Spielzeit: ${lobbySettings!['gameLength']} Minuten"),
            Text("Max Spieler: ${lobbySettings!['maxPlayers']}"),
            const SizedBox(height: 20),

            TextField(
              decoration: const InputDecoration(labelText: "Dein Name"),
              onChanged: (v) => username = v,
            ),

            SwitchListTile(
              title: const Text("Bereit"),
              value: ready,
              onChanged: (v) {
                setState(() => ready = v);
                _sendReady();
              },
            ),

            const SizedBox(height: 20),
            const Text("Spieler:", style: TextStyle(fontSize: 18)),

            Expanded(
              child: ListView(
                children: players
                    .map((p) => ListTile(
                          title: Text(p["username"]),
                          trailing: Icon(
                            p["isPlayerReady"] ? Icons.check : Icons.close,
                            color: p["isPlayerReady"] ? Colors.green : Colors.red,
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
