import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/navigation.dart';
import '../../factories/screen_factory.dart';
import '../services/polling/poll_manager.dart';

class JoinLobbyPage extends StatefulWidget {
  final Map<String, dynamic> lobbyData;
  const JoinLobbyPage({super.key, required this.lobbyData});

  @override
  State<JoinLobbyPage> createState() => _JoinLobbyPageState();
}

class _JoinLobbyPageState extends State<JoinLobbyPage> {
  // Backend data
  String chosenSubjectName = "";
  String chosenMaxPlayers = "";
  String chosenMaxGameLength = "";
  List<dynamic> players = [];

  // Local player settings
  bool ready = false;
  String username = "";

  int get lobbyID => widget.lobbyData['lobbyID'];

  @override
  void initState() {
    super.initState();

    // --- Poll lobby settings ---
    PollManager.startPolling(
      interval: const Duration(seconds: 3),
      task: () => ApiService.getLobby(lobbyID),
      onUpdate: (res) {
        if (!mounted || res == null) return;

        setState(() {
          chosenSubjectName = res["chosenSubjectName"];
          chosenMaxPlayers = res["chosenMaxPlayers"];
          chosenMaxGameLength = res["chosenMaxGameLength"];
        });
      },
    );

    // --- Poll player list ---
    PollManager.startPolling(
      interval: const Duration(seconds: 3),
      task: () => ApiService.getLobbyPlayers(lobbyID),
      onUpdate: (res) {
        if (!mounted || res == null) return;

        setState(() => players = res);

        // Auto-start if all ready
        if (players.isNotEmpty && players.every((p) => p['ready'] == true)) {
          NavigationService.navigate(
            context,
            ScreenType.game,
            arguments: {'lobbyID': lobbyID},
          );
        }
      },
    );
  }

  Future<void> _sendPlayerJoin() async {
    if (username.isEmpty) return;
    await ApiService.postJoinLobby(lobbyID, username, ready);
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
            Text("Thema: $chosenSubjectName"),
            Text("Spielzeit: $chosenMaxGameLength Minuten"),
            Text("Max Spieler: $chosenMaxPlayers"),
            const SizedBox(height: 20),

            TextField(
              decoration: InputDecoration(
                labelText: "Bitte Usernamen eingeben",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send_rounded),
                  onPressed: _sendPlayerJoin,
                ),
              ),
              onChanged: (v) => username = v,
            ),

            SwitchListTile(
              title: const Text("Bereit"),
              value: ready,
              onChanged: (v) {
                setState(() => ready = v);
                _sendPlayerJoin();
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
                            p['ready'] == true
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: p['ready'] == true
                                ? Colors.green
                                : Colors.red,
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


/*import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/navigation.dart';
import '../../factories/screen_factory.dart';
import '../services/polling/poll_manager.dart';

class JoinLobbyPage extends StatefulWidget {
  final Map<String, dynamic> lobbyData;
  const JoinLobbyPage({super.key, required this.lobbyData});

  @override
  State<JoinLobbyPage> createState() => _JoinLobbyPageState();
}

class _JoinLobbyPageState extends State<JoinLobbyPage> {
  // daten die von Flask kommen
  String chosenSubjectName = "";
  String chosenMaxPlayers = "";
  String chosenMaxGameLength = "";
  List<dynamic> players = [];

  // daten die vom Mitspieler angepasst werden können
  bool ready = false;
  String username = "";

  Timer? timerPlayerList;
  Timer? timerLobbySettings;

  int get lobbyID => widget.lobbyData['lobbyID'];

  @override
  void initState() {
    timerLobbySettings = PollManager.register(
      Timer.periodic(const Duration(seconds: 5), (_) => _loadLobbySettings()),
    );

    timerPlayerList = PollManager.register(
      Timer.periodic(const Duration(seconds: 5), (_) => _loadPlayers()),
    );

    super.initState();
  }

  @override
  void dispose() {
    timerPlayerList?.cancel();
    timerLobbySettings?.cancel();
    super.dispose();
  }

  Future<void> _loadLobbySettings() async {
    final res = await ApiService.getLobby(lobbyID);
    setState(() {
      chosenSubjectName = res["chosenSubjectName"];
      chosenMaxPlayers = res["chosenMaxPlayers"];
      chosenMaxGameLength = res["chosenMaxGameLength"];
    });
    debugPrint("$chosenMaxGameLength = game Length, $chosenMaxPlayers = maxPlayers, $chosenSubjectName = Thema");
  }

  Future<void> _loadPlayers() async {
    final res = await ApiService.getLobbyPlayers(lobbyID);
    setState(() => players = res ?? []);
    debugPrint("$players");

    // Auto-start if all ready
    if (players.isNotEmpty && players.every((p) => p['ready'] == true)) {
      NavigationService.navigate(
        context,
        ScreenType.game,
        arguments: {'lobbyID': lobbyID},
      );
    }
  }

  Future<void> _sendPlayerJoin() async {
    if (username.isEmpty) return;
    await ApiService.postJoinLobby(lobbyID, username, ready);
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
            Text("Thema: $chosenSubjectName"),
            Text("Spielzeit: $chosenMaxGameLength Minuten"),
            Text("Max Spieler: $chosenMaxPlayers"),
            const SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(labelText: "Bitte Usernamen eingeben", 
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send_rounded),
                  onPressed: () {
                    _sendPlayerJoin();
                  },
                ),
              ),
              onChanged: (v) => username = v,
            ),
            SwitchListTile(
              title: const Text("Bereit"),
              value: ready,
              onChanged: (v) {
                setState(() => ready = v);
                _sendPlayerJoin();
              },
            ),
            const SizedBox(height: 20),
            const Text("Spieler:", style: TextStyle(fontSize: 18)),

            // hier muss noch hinzugefügt werden, dass sich der Icon und die farbe ändert bei true und false
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
*/