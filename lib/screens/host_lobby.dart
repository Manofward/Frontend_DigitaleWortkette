import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import '../../services/api_service.dart';
import '../../services/navigation.dart';
import '../Widgets/dropdown_row.dart';
import '../Widgets/player_list_view.dart';
import '../Widgets/footer_nav_bar.dart';
import '../factories/screen_factory.dart';

class HostLobbyPage extends StatefulWidget {
  final Map<String, dynamic> data;
  const HostLobbyPage({super.key, required this.data});

  @override
  State<HostLobbyPage> createState() => _HostLobbyPageState();
}

class _HostLobbyPageState extends State<HostLobbyPage> {
  late final int lobbyID;

  List<String> subjects = [];
  List<int> gameLengths = [];
  List<int> maxPlayersOptions = [];

  String selectedSubject = "";
  int selectedMaxPlayers = 0;
  int selectedGameLength = 0;

  List<dynamic> players = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    final data = widget.data;

    lobbyID = data["lobbyID"] ?? 0;

    subjects = List<String>.from(data["subjectName"] ?? []);
    maxPlayersOptions = List<int>.from(data["maxPlayers"] ?? []);
    gameLengths = List<int>.from(data["maxGameLength"] ?? []);

    selectedSubject = subjects.isNotEmpty ? subjects.first : "";
    selectedMaxPlayers = maxPlayersOptions.isNotEmpty ? maxPlayersOptions.first : 0;
    selectedGameLength = gameLengths.isNotEmpty ? gameLengths.first : 0;

    _startPlayerPolling();
  }

  void _startPlayerPolling() {
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
    if (mounted && res != null) {
      setState(() => players = res);
    }
  }

  Future<void> _updateSetting(String key, dynamic value) async {
    await ApiService.updateHostLobbySetting({key: value.toString()});
  }

  void _showQrCode() {
    final qrData = widget.data['generatedQRCode'] ?? lobbyID.toString();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("QR-Code"),
        content: PrettyQr(data: qrData.toString(), size: 200),
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
            // Thema Dropdown
            DropdownRow(
              label: "Thema",
              value: selectedSubject,
              items: subjects,
              onChanged: (v) {
                if (v == null) return;
                setState(() => selectedSubject = v);
                _updateSetting("subjectName", v);
              },
            ),

            // Game Length Dropdown
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

            // Max Players Dropdown
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
              onPressed: _showQrCode,
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
                  arguments: {'code': lobbyID.toString()},
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
