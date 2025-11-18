import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/navigation.dart';
import '../../factories/screen_factory.dart';

class JoinLobbyPage extends StatefulWidget {
  final Map<String, dynamic> lobbyData;
  const JoinLobbyPage({super.key, required this.lobbyData});

  @override
  State<JoinLobbyPage> createState() => _JoinLobbyPageState();
}

class _JoinLobbyPageState extends State<JoinLobbyPage> {
  String username = "";
  bool ready = false;
  List<dynamic> players = [];
  Timer? _timer;

  String get lobbyID => widget.lobbyData['lobbyID']?.toString() ?? '-';
  String get topic => widget.lobbyData['topic']?.toString() ?? '-';
  int get maxPlayers => widget.lobbyData['maxPlayers'] ?? 0;
  int get gameLength => widget.lobbyData['gameLength'] ?? 0;

  @override
  void initState() {
    super.initState();
    _loadPlayers();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _loadPlayers());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadPlayers() async {
    final res = await ApiService.getHostLobbyPlayers();
    setState(() => players = res ?? []);

    // Auto-start if all ready
    if (players.isNotEmpty && players.every((p) => p['ready'] == true)) {
      NavigationService.navigate(
        context,
        ScreenType.game,
        arguments: {'code': lobbyID},
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
    return Scaffold(
      appBar: AppBar(title: Text("Lobby #$lobbyID")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Thema: $topic"),
            Text("Spielzeit: $gameLength Minuten"),
            Text("Max Spieler: $maxPlayers"),
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
                          title: Text(p['username'] ?? '-'),
                          trailing: Icon(
                            p['ready'] == true ? Icons.check : Icons.close,
                            color: p['ready'] == true ? Colors.green : Colors.red,
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
