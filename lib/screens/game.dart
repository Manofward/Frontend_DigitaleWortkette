
import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/navigation.dart';
import '../factories/screen_factory.dart';
import '../services/polling/poll_manager.dart';
import '../Widgets/footer_nav_bar.dart';
import '../utils/theme/app_theme.dart';
import '../utils/get_username.dart';

class GameScreen extends StatefulWidget {
  final Map<String, dynamic> lobbyData;

  const GameScreen({super.key, required this.lobbyData});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final int lobbyID;
  String localUsername = getUsername();
  int? localUserID = LobbySession.userID;

  // Game state from backend
  String chosenSubject = "";
  int timeRemaining = 0;
  String currentLetter = "";
  List<String> usedWords = [];
  Map<String, dynamic>? previousWord;
  List<dynamic> players = [];

  // Polling handles
  PollHandle? _gameSessionPollHandle;
  PollHandle? _playersPollHandle;

  // Local timer for countdown
  Timer? _countdownTimer;
  bool isTimeUp = false;

  // UI state
  final TextEditingController _wordController = TextEditingController();
  bool isSubmitting = false;

  String get currentPlayer => players.isNotEmpty ? players[0]['username'] ?? '' : '';
  bool get isMyTurn => currentPlayer == localUsername && !isTimeUp;

  @override
  void initState() {
    super.initState();
    lobbyID = widget.lobbyData["lobbyID"];

    // Start polling for game session and players
    _startPolling();
  }

  void _startPolling() async {
    // Poll game session
    _gameSessionPollHandle = await PollManager.startPolling(
      interval: const Duration(seconds: 3),
      task: () => ApiService.getGameSessionData(lobbyID),
      onUpdate: (res) {
        if (!mounted || res == null) return;

        setState(() {
          chosenSubject = res["chosenSubject"] ?? "";
          timeRemaining = res["time"] ?? 0;
          currentLetter = res["currentLetter"] ?? "";
          usedWords = List<String>.from(res["usedWords"] ?? []);
          previousWord = res["previousWord"];
          isTimeUp = timeRemaining <= 0;
        });
        _syncLocalTimer();
      },
    );

    // Poll players for turn order
    _playersPollHandle = await PollManager.startPolling(
      interval: const Duration(seconds: 3),
      task: () => ApiService.getLobbyPlayers(lobbyID),
      onUpdate: (res) {
        if (!mounted || res == null) return;

        setState(() {
          players = res;
        });
      },
    );
  }

  void _syncLocalTimer() {
    _countdownTimer?.cancel();
    if (timeRemaining > 0) {
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) return;

        setState(() {
          if (timeRemaining > 0) {
            timeRemaining--;
          } else {
            isTimeUp = true;
            timer.cancel();
          }
        });
      });
    }
  }

  @override
  void dispose() {
    // Stop all polling
    _gameSessionPollHandle?.stop();
    _playersPollHandle?.stop();
    PollManager.cancelAll();

    _countdownTimer?.cancel();
    _wordController.dispose();
    super.dispose();
  }

  Future<void> _submitWord() async {
    final word = _wordController.text.trim();
    if (word.isEmpty || !isMyTurn || isSubmitting) return;

    setState(() => isSubmitting = true);
    final res = await ApiService.postGameSession(lobbyID, word);
    setState(() => isSubmitting = false);

    if (res == null || res.isEmpty) {
      // Word already exists or invalid
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Wort bereits verwendet oder ungültig!")),
      );
    } else {
      // Valid word submitted; polling will update the UI
      _wordController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Digitale Wortkette zum Thema: $chosenSubject",
          style: AppTheme.lightTheme.textTheme.bodyLarge,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Turn Order
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: players.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (_, index) {
                  final player = players[index];
                  final isActive = index == 0; // First in list is current
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      player['username'] ?? '',
                      style: TextStyle(color: isActive ? Colors.white : Colors.black),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Timer + Current Player
            SizedBox(
              width: 160,
              height: 160,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: timeRemaining / 30, // Assuming 30s turns; adjust if needed
                    strokeWidth: 10,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation(isTimeUp ? Colors.red : Colors.green),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isTimeUp ? "Zeit abgelaufen!" : currentPlayer,
                        style: AppTheme.lightTheme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isTimeUp ? "0 s" : "$timeRemaining s",
                        style: AppTheme.lightTheme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Current Letter Hint
            if (currentLetter.isNotEmpty)
              Text(
                "Nächstes Wort beginnt mit: $currentLetter",
                style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(color: Colors.blue),
              ),

            const SizedBox(height: 20),

            // Word Input
            TextField(
              controller: _wordController,
              enabled: isMyTurn && !isSubmitting,
              onSubmitted: (_) => _submitWord(),
              decoration: InputDecoration(
                labelText: isMyTurn
                    ? "Gib dein Wort ein"
                    : isTimeUp
                        ? "Zeit abgelaufen"
                        : "Warte auf $currentPlayer",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: (isMyTurn && !isSubmitting) ? _submitWord : null,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Previous Word
            if (previousWord != null)
              Text(
                "Letztes Wort: ${previousWord!['wordUsed']} von ${previousWord!['username']}",
                style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),

            const SizedBox(height: 20),

            // Used Words List
            Expanded(
              child: ListView.builder(
                reverse: true, // Most recent first
                itemCount: usedWords.length,
                itemBuilder: (context, index) {
                  final word = usedWords[usedWords.length - 1 - index]; // Reverse for display
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      word,
                      style: AppTheme.lightTheme.textTheme.bodyMedium,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: FooterNavigationBar(
        screenType: ScreenType.game,
        onButtonPressed: (type) => handleFooterButton(context, type),
      ),
    );
  }
}