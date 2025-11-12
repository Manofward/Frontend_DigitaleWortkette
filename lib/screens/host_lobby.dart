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
  late int createdLobbyID;
  late List<dynamic> subjects;
  late int maxPlayers;
  late int maxGameLength;
  late String generatedQRCode;

  late String selectedSubject;
  late int selectedMaxPlayers;
  late int selectedMaxGameLength;

  List<Map<String, dynamic>> playerList = [];
  List<String> availableSubjects = [];
  List<int> availableMaxPlayers = [];
  List<int> availableGameLengths = [];

  bool _loadingOptions = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    createdLobbyID = widget.data['createdLobbyID'] ?? 0;
    subjects = widget.data['subjects'] ?? [];
    maxPlayers = widget.data['maxPlayers'] ?? 0;
    maxGameLength = widget.data['maxGameLength'] ?? 0;
    generatedQRCode = widget.data['generatedQRCode'] ?? '';

    selectedSubject = subjects.isNotEmpty ? subjects.first['name'] : 'Thema wählen';
    selectedMaxPlayers = maxPlayers;
    selectedMaxGameLength = maxGameLength;

    _loadAvailableOptions();
    _loadPlayers();

    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _loadPlayers());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadAvailableOptions() async {
    setState(() => _loadingOptions = true);
    final response = await ApiService.getHostLobbyOptions(createdLobbyID);
    if (response != null) {
      setState(() {
        availableSubjects = List<String>.from(response['availableSubjects'] ?? []);
        availableMaxPlayers = List<int>.from(response['availableMaxPlayers'] ?? []);
        availableGameLengths = List<int>.from(response['availableGameLengths'] ?? []);
        selectedSubject = availableSubjects.contains(selectedSubject) ? selectedSubject : availableSubjects.first;
        selectedMaxPlayers = availableMaxPlayers.contains(selectedMaxPlayers) ? selectedMaxPlayers : availableMaxPlayers.first;
        selectedMaxGameLength = availableGameLengths.contains(selectedMaxGameLength) ? selectedMaxGameLength : availableGameLengths.first;
        _loadingOptions = false;
      });
    } else {
      setState(() => _loadingOptions = false);
    }
  }

  Future<void> _loadPlayers() async {
    final response = await ApiService.getHostLobbyPlayers(createdLobbyID);
    if (response != null && response['players'] != null) {
      setState(() => playerList = List<Map<String, dynamic>>.from(response['players']));
    }
  }

  Future<void> _updateSetting(String key, dynamic value) async {
    await ApiService.updateHostLobbySetting(createdLobbyID, {key: value});
  }

  void _showQrCode() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('QR-Code anzeigen'),
        content: PrettyQr(data: generatedQRCode, size: 200, roundEdges: true),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Schließen'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingOptions) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: Text('Lobby #$createdLobbyID')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownRow(label: 'Thema wählen:', value: selectedSubject, items: availableSubjects, onChanged: (val) {
              if (val == null) return;
              setState(() => selectedSubject = val);
              _updateSetting('chosenSubjectName', val);
            }),
            const SizedBox(height: 12),
            DropdownRow(
              label: 'Spiellänge:',
              value: '$selectedMaxGameLength Min',
              items: availableGameLengths.map((e) => '$e Min').toList(),
              onChanged: (val) {
                if (val == null) return;
                final parsed = int.parse(val.split(' ').first);
                setState(() => selectedMaxGameLength = parsed);
                _updateSetting('chosenGameLength', parsed);
              },
            ),
            const SizedBox(height: 12),
            DropdownRow(
              label: 'Max. Spieler:',
              value: selectedMaxPlayers.toString(),
              items: availableMaxPlayers.map((e) => e.toString()).toList(),
              onChanged: (val) {
                if (val == null) return;
                final parsed = int.parse(val);
                setState(() => selectedMaxPlayers = parsed);
                _updateSetting('chosenMaxPlayer', parsed);
              },
            ),
            const Divider(height: 40),
            Text('Lobby-Code: $createdLobbyID', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.qr_code),
                label: const Text('QR-Code anzeigen'),
                onPressed: _showQrCode,
              ),
            ),
            const Divider(height: 40),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: const Text('Spiel starten'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                onPressed: () => NavigationService.navigate(context, ScreenType.game, arguments: {'code': createdLobbyID.toString()}),
              ),
            ),
            const Divider(height: 40),
            const Text('Spieler in Lobby:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(child: PlayerListView(players: playerList.map((p) => p['username'] as String).toList())),
          ],
        ),
      ),
      bottomNavigationBar: FooterNavigationBar(screenType: ScreenType.home, onButtonPressed: (type) => handleFooterButton(context, type)),
    );
  }
}
