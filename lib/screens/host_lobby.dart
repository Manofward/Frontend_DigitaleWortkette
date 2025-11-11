// need to make the imports for the list of available subject, maxgame length, maxPlayers
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
  final int createdLobbyID;
  final List<dynamic> subjects;
  final int maxPlayers;
  final int maxGameLength;
  final String generatedQRCode;

  const HostLobbyPage({
    super.key,
    required this.createdLobbyID,
    required this.subjects,
    required this.maxPlayers,
    required this.maxGameLength,
    required this.generatedQRCode,
  });

  @override
  State<HostLobbyPage> createState() => _HostLobbyPageState();
}

class _HostLobbyPageState extends State<HostLobbyPage> {
  late String selectedSubject;
  late int selectedMaxPlayers;
  late int selectedMaxGameLength;
  List<Map<String, dynamic>> playerList = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    selectedSubject = widget.subjects.isNotEmpty ? widget.subjects.first['name'] : 'Thema wählen';
    selectedMaxPlayers = widget.maxPlayers;
    selectedMaxGameLength = widget.maxGameLength;

    _loadPlayers();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _loadPlayers());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadPlayers() async {
    final response = await ApiService.get('host-lobby/${widget.createdLobbyID}/players');
    if (response != null && response['players'] != null) {
      setState(() {
        playerList = List<Map<String, dynamic>>.from(response['players']);
      });
    }
  }

  Future<void> _updateSetting(String key, dynamic value) async {
    await ApiService.post('host-lobby/${widget.createdLobbyID}/update', {key: value});
  }

  void _showQrCode() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('QR-Code anzeigen'),
        content: PrettyQr(
          data: widget.generatedQRCode,
          size: 200,
          roundEdges: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Schließen'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subjects = widget.subjects.map<String>((s) => s['name'] as String).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Lobby erstellen')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownRow(
              label: 'Thema wählen:',
              value: selectedSubject,
              items: subjects,
              onChanged: (val) {
                if (val == null) return;
                setState(() => selectedSubject = val);
                _updateSetting('chosenSubjectName', val);
              },
            ),
            const SizedBox(height: 12),
            DropdownRow(
              label: 'Spiellänge:',
              value: '${selectedMaxGameLength} Min',
              items: [5, 10, 15, 20, 30].map((e) => '$e Min').toList(),
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
              items: List.generate(8, (i) => (i + 2).toString()),
              onChanged: (val) {
                if (val == null) return;
                final parsed = int.parse(val);
                setState(() => selectedMaxPlayers = parsed);
                _updateSetting('chosenMaxPlayer', parsed);
              },
            ),
            const Divider(height: 40),
            Text('Lobby-Code: ${widget.createdLobbyID}', style: const TextStyle(fontSize: 18)),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => NavigationService.navigate(context, ScreenType.game),
              ),
            ),
            const Divider(height: 40),
            const Text(
              'Spieler in Lobby:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: PlayerListView(
                players: playerList.map((p) => p['username'] as String).toList(),
              ),
            ),
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
