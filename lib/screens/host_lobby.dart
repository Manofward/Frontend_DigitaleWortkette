import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import '../../services/api_service.dart';
import '../../services/navigation.dart';
import '../../factories/screen_factory.dart';
import '../Widgets/dropdown_row.dart';
import '../Widgets/player_list_view.dart';
import '../Widgets/footer_nav_bar.dart';

class HostLobbyPage extends StatefulWidget {
  final Map<String, dynamic> data;

  const HostLobbyPage({super.key, required this.data});

  @override
  State<HostLobbyPage> createState() => _HostLobbyPageState();
}

class _HostLobbyPageState extends State<HostLobbyPage> {
  late int lobbyID;

  List<String> subjects = [];
  List<int> gameLengths = [];
  List<int> maxPlayersOptions = [];

  String selectedSubject = "";
  int selectedMaxPlayers = 5;
  int selectedGameLength = 10;

  List<Map<String, dynamic>> players = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    lobbyID = widget.data["lobbyID"] ?? 0;

    // Initialize with safe defaults
    selectedSubject = widget.data["subjects"]?.first?["name"] ?? "";
    selectedMaxPlayers = widget.data["maxPlayers"] ?? 5;
    selectedGameLength = widget.data["maxGameLength"] ?? 10;

    _loadOptions();
    _loadPlayers();

    // Poll players every 5 seconds
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _loadPlayers());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Load dropdown options
  Future<void> _loadOptions() async {
    final options = await ApiService.getHostLobbyOptions();
    if (options == null) return;

    setState(() {
      subjects = List<String>.from(options["availableSubjects"] ?? []);
      gameLengths = List<int>.from(options["availableGameLengths"] ?? []);
      maxPlayersOptions = List<int>.from(options["availableMaxPlayers"] ?? []);

      // Ensure current selections are valid
      if (!subjects.contains(selectedSubject) && subjects.isNotEmpty) {
        selectedSubject = subjects.first;
      }
      if (!maxPlayersOptions.contains(selectedMaxPlayers) && maxPlayersOptions.isNotEmpty) {
        selectedMaxPlayers = maxPlayersOptions.first;
      }
      if (!gameLengths.contains(selectedGameLength) && gameLengths.isNotEmpty) {
        selectedGameLength = gameLengths.first;
      }
    });
  }

  // Load players in the lobby
  Future<void> _loadPlayers() async {
    final res = await ApiService.getHostLobbyPlayers();
    if (res == null) return;

    setState(() {
      players = res;
    });
  }

  // Update a lobby setting
  Future<void> _updateSetting(String key, dynamic value) async {
  // Convert value to string to match backend expectation
  final payload = {key: value.toString()};
  await ApiService.updateHostLobbySetting(payload);
}


  // Show QR code
  void _showQr() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("QR-Code"),
        content: PrettyQr(data: lobbyID.toString(), size: 200),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Lobby #$lobbyID")),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Dropdown Thema/subject
            DropdownRow(
              label: "Thema",
              value: selectedSubject,
              items: subjects,
              onChanged: (v) {
                if (v == null) return;
                setState(() => selectedSubject = v);
                _updateSetting("subject", v);
              },
            ),

            // Dropdown Spiellänge/maxGameLength
            DropdownRow(
              label: "Spiellänge",
              value: "$selectedGameLength Min",
              items: gameLengths.map((e) => "$e Min").toList(),
              onChanged: (v) {
                if (v == null) return;
                final parsed = int.tryParse(v.split(" ").first) ?? selectedGameLength;
                setState(() => selectedGameLength = parsed);
                _updateSetting("maxGameLength", parsed);
              },
            ),

            // Dropdown MaxSpieler/maxPlayers
            DropdownRow(
              label: "Max Spieler",
              value: selectedMaxPlayers.toString(),
              items: maxPlayersOptions.map((e) => e.toString()).toList(),
              onChanged: (v) {
                if (v == null) return;
                final parsed = int.tryParse(v) ?? selectedMaxPlayers;
                setState(() => selectedMaxPlayers = parsed);
                _updateSetting("maxPlayers", parsed);
              },
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              icon: const Icon(Icons.qr_code),
              label: const Text("QR Code anzeigen"),
              onPressed: _showQr,
            ),
            const Divider(height: 30),
            const Text("Spieler:", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Expanded(
              child: PlayerListView(
                players: players.map((e) => e["username"] as String).toList(),
              ),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: const Text("Spiel starten"),
              onPressed: () {
                NavigationService.navigate(
                  context,
                  ScreenType.game,
                  arguments: {"code": lobbyID.toString()},
                );
              },
            )
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
