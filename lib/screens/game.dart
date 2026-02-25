
import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/navigation.dart';
import '../factories/screen_factory.dart';
import '../services/polling/poll_manager.dart';
import '../Widgets/footer_nav_bar.dart';
import '../utils/theme/app_theme.dart';

class GameScreen extends StatefulWidget {
  final Map<String, dynamic> lobbyData;

  const GameScreen({super.key, required this.lobbyData});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final int lobbyID;
  int? localUserID = LobbySession.userID;

  // Game state from backend
  String chosenSubject = "";
  String currentLetter = "";
  List<String> usedWords = [];
  Map<String, dynamic>? previousWord;
  List<dynamic> turnOrder = [];
  bool isGameOver = false;

  // Local timer for countdown
  int timeRemaining = 30;
  bool skippedTurn = true;
  Timer? _countdownTimer;
  

  // UI state
  final TextEditingController _wordController = TextEditingController();
  bool isSubmitting = false;

  int? get currentPlayerID => turnOrder.isNotEmpty ? turnOrder[0]['userID'] as int? : null;
  bool get isMyTurn => turnOrder.isNotEmpty && localUserID != null && currentPlayerID == LobbySession.userID;

  @override
  void initState() {
    super.initState();

    lobbyID = widget.lobbyData["lobbyID"];

    _startPolling();
  }

  void _startPolling() async {
    // Poll game session
    PollManager.startPolling(
      interval: const Duration(seconds: 3),
      task: () => ApiService.getGameSessionData(lobbyID),
      onUpdate: (res) {
        if (!mounted || res == null) return;
        setState(() {
          turnOrder = res["turnOrder"] ?? [];
          chosenSubject = res["chosenSubject"] ?? "";
          currentLetter = res["currentLetter"] ?? "";
          usedWords = List<String>.from(res["usedWords"] ?? []);
          previousWord = res["previousWord"];
          isGameOver = res["isGameOver"];
        });

        if (isMyTurn) {
          _startLocalTimer();
        }

        if (isGameOver) {
          NavigationService.navigate(
            context,
            ScreenType.results,
            arguments: {"lobbyID": lobbyID},
          );
        }
      },
    );
  }

  void _startLocalTimer() {
    _countdownTimer?.cancel();      // prevent duplicate timers

    if (skippedTurn) {
      timeRemaining = 30;
      skippedTurn = false;
    }
    
    _countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted) return;

        if (timeRemaining > 0) {
          setState(() {
            timeRemaining--;
          });
        } 
        else {
          timer.cancel();
          timeRemaining = 0;
          _sendSkip(); // optional if you want auto skip
        }
      },
    );
  }

  Future<void> _sendSkip() async {
    //await ApiService.postSkipTurn(lobbyID);
    skippedTurn = true;
    debugPrint("Skipped player ${turnOrder[0]['username']}");
  }

  Future<void> _submitWord() async {
    final word = _wordController.text.trim();
    if (word.isEmpty || !isMyTurn || isSubmitting) return;

    setState(() => isSubmitting = true);
    final res = await ApiService.postGameSession(lobbyID, word, localUserID);
    setState(() => isSubmitting = false);

    if (res == null || res.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Wort bereits verwendet oder ungültig!")),
      );
    } else {
      _wordController.clear();

      if(_countdownTimer?.isActive == true) {
        _countdownTimer?.cancel();
        timeRemaining = 0;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          "Digitale Wortkette zum Thema: $chosenSubject",
          style: AppTheme.lightTheme.textTheme.bodyLarge,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Turn Order
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: turnOrder.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (_, index) {
                    final player = turnOrder[index];
                    final isActive = index == 0;
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
                width: 160, // 160 width before change
                height: 160, // 160 height before change
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: timeRemaining / 30, // Assuming 30s turns
                      strokeWidth: 10,
                      backgroundColor: Colors.grey.shade300,
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 30),
                        Text(
                          timeRemaining <= 0 ? "Übersprungen" : "$timeRemaining s bis Überspringen",
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
                      : "Warte auf ${turnOrder.isNotEmpty ? turnOrder[0]['username'] : 'Spieler'}",
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
              Flexible(
                child: ListView.builder(
                  reverse: true,
                  itemCount: usedWords.length,
                  itemBuilder: (context, index) {
                    final word = usedWords[usedWords.length - 1 - index];
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
      ),
      bottomNavigationBar: FooterNavigationBar(
        screenType: ScreenType.game,
        onButtonPressed: (type) => handleFooterButton(context, type),
      ),
    );
  }
}