import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import '../../services/api_service.dart';
import '../../services/navigation.dart';
import '../Widgets/dropdown_row.dart';
import '../Widgets/footer_nav_bar.dart';
import '../Widgets/pop_leave_game.dart';
import '../factories/screen_factory.dart';

class HostLobbyPage extends StatefulWidget {
  final Map<String, dynamic> data;
  const HostLobbyPage({super.key, required this.data});

  @override
  State<HostLobbyPage> createState() => _HostLobbyPageState();
}

class _HostLobbyPageState extends State<HostLobbyPage> {
  late final int lobbyID;
  late int userID;
  late int hostID; // id of the Host that will be used
  List<dynamic> players = [];

  List<String> subjects = [];
  List<int> gameLengths = [];
  List<int> maxPlayersOptions = [];

  late String selectedSubject;
  late int selectedMaxPlayers;
  late int selectedGameLength;

  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();

    final data = widget.data;

    lobbyID = data["lobbyID"] ?? 0;
    hostID = data["hostID"];
    userID = data["userID"];

    subjects = List<String>.from(data["subjectName"] ?? []);
    maxPlayersOptions = List<int>.from(data["maxPlayers"] ?? []);
    gameLengths = List<int>.from(data["maxGameLength"] ?? []);

    selectedSubject = subjects.isNotEmpty ? subjects.first : "";
    selectedMaxPlayers = maxPlayersOptions.isNotEmpty ? maxPlayersOptions.first : 0;
    selectedGameLength = gameLengths.isNotEmpty ? gameLengths.first : 0;

    _startPlayerPolling();
  }

  void _startPlayerPolling() {
    _pollTimer ??= Timer.periodic(const Duration(seconds: 5), (_) async {
      final res = await ApiService.getLobbyPlayers(lobbyID);
      if (mounted) {
        setState(() => players = res);
      }
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
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
    return PopScope( // PopScope for adding poping alerts
      canPop: false,
      onPopInvoked: LeaveLobby.onPopInvoked(
        context: context,
        lobbyID: lobbyID,
        userID: userID,
        hostID: hostID, // vieleicht zu user und host id einzeln ändern
      ),
      // Scaffold is the part for the main part for the showing of the site
      child: Scaffold(
        appBar: AppBar(title: Text("Lobby #$lobbyID")),
        body: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Thema Dropdown (self-contained)
              DropdownRow(
                label: "Thema",
                initialValue: selectedSubject,
                items: subjects,
                onChanged: (v) {
                  if (v == null) return;
                  selectedSubject = v;
                  _updateSetting("subjectName", v);
                },
              ),

              // Game Length Dropdown
              DropdownRow(
                label: "Spiellänge",
                initialValue: "$selectedGameLength Min",
                items: gameLengths.map((e) => "$e Min").toList(),
                onChanged: (v) {
                  if (v == null) return;
                  final parsed = int.tryParse(v.split(" ").first) ?? selectedGameLength;
                  selectedGameLength = parsed;
                  _updateSetting("maxGameLength", parsed);
                },
              ),

              // Max Players Dropdown
              DropdownRow(
                label: "Max Spieler",
                initialValue: selectedMaxPlayers.toString(),
                items: maxPlayersOptions.map((e) => e.toString()).toList(),
                onChanged: (v) {
                  if (v == null) return;
                  final parsed = int.tryParse(v) ?? selectedMaxPlayers;
                  selectedMaxPlayers = parsed;
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

              // Player list updates continuously without dropdown interference
              Expanded(
                child: ListView(
                  children: players
                      .map((p) => ListTile(
                            title: Text(p['username'] ?? '-'),
                            trailing: Icon(
                              p['isPlayerReady'] == "true"
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color: p['isPlayerReady'] == "true"
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ))
                      .toList(),
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
              ),
            ],
          ),
        ),
        bottomNavigationBar: FooterNavigationBar(
          screenType: ScreenType.home,
          onButtonPressed: (type) => handleFooterButton(context, type),
        ),
      )
    );
  }
}

