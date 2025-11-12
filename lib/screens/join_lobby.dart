import 'package:flutter/material.dart';
import 'dart:async';
import '../services/api_service.dart';
import '../Widgets/footer_nav_bar.dart';
import '../factories/screen_factory.dart';
import '../services/navigation.dart';

class JoinLobbyPage extends StatefulWidget {
  final Map<String, dynamic> lobbyData;

  const JoinLobbyPage({super.key, required this.lobbyData});

  @override
  State<JoinLobbyPage> createState() => _JoinLobbyPageState();
}

class _JoinLobbyPageState extends State<JoinLobbyPage> {
  late String username;
  bool ready = false;
  Timer? _usernameDebounce;
  Timer? _lobbyTimer;

  late TextEditingController _usernameController;

  @override
  void initState() {
    super.initState();
    username = widget.lobbyData['username'] ?? '';
    _usernameController = TextEditingController(text: username);
    _usernameController.addListener(() {
      onUsernameChanged(_usernameController.text);
    });
    _startLobbyPolling();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _lobbyTimer?.cancel();
    _usernameDebounce?.cancel();
    super.dispose();
  }

  void onUsernameChanged(String value) {
    username = value;

    // Debounce to avoid too many API calls
    if (_usernameDebounce?.isActive ?? false) _usernameDebounce!.cancel();
    _usernameDebounce = Timer(const Duration(milliseconds: 500), () {
      ApiService.postJoinLobby(
        widget.lobbyData['lobbyCode'],
        username,
        ready,
      );
    });
  }

  Future<void> toggleReady() async {
    setState(() => ready = !ready);

    await ApiService.postJoinLobby(
      widget.lobbyData['lobbyCode'],
      username.isEmpty ? 'Player' : username,
      ready,
    );
  }

  void _startLobbyPolling() {
    _lobbyTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      final updatedLobby = await ApiService.getJoinLobby(widget.lobbyData['lobbyCode']);

      if (updatedLobby != null) {
        setState(() {
          widget.lobbyData['players'] = updatedLobby['players'];
          widget.lobbyData['maxPlayers'] = updatedLobby['maxPlayers'];
          widget.lobbyData['subject'] = updatedLobby['subject'];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final lobby = widget.lobbyData;
    final players = (lobby['players'] as List<dynamic>? ?? []);

    return Scaffold(
      appBar: AppBar(title: const Text('Lobby')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nickname input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Dein Nutzername'),
                    controller: _usernameController,
                    onChanged: onUsernameChanged,
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
            const SizedBox(height: 16),

            // Ready button
            Center(
              child: ElevatedButton(
                onPressed: toggleReady,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ready ? Colors.green : null,
                ),
                child: Text(ready ? 'Bereit ✅' : 'Bereit'),
              ),
            ),
            const SizedBox(height: 32),

            // Lobby info
            Text('Thema: ${lobby['subject']}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Spieler: ${players.length} / ${lobby['maxPlayers']}'),
            const SizedBox(height: 16),
            const Text('Warten auf Start … ⏳'),
          ],
        ),
      ),
      bottomNavigationBar: FooterNavigationBar(
        screenType: ScreenType.home,
        onButtonPressed: (type) => handleFooterButton(context, type),
      ),
    );
  }
}
