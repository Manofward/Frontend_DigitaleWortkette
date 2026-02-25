
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:square_progress_indicator/square_progress_indicator.dart';
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
  List<dynamic> usedWords = [];
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
  bool get isMyTurn => turnOrder.isNotEmpty && localUserID != null && currentPlayerID == localUserID;
  ValueNotifier<bool> isMyTurnNotifier = ValueNotifier(false); // Notifier for Notifying the timer to do something

  @override
  void initState() {
    super.initState();

    lobbyID = widget.lobbyData["lobbyID"];

    // Listen for turn changes
    isMyTurnNotifier.addListener(() {
      if (isMyTurnNotifier.value) {
        _startLocalTimer();
      } else {
        // My turn ended
        _countdownTimer?.cancel();
        timeRemaining = 30;
      }
    });

    _startPolling();
  }

  @override
   void dispose() {
    _countdownTimer?.cancel();
    _wordController.dispose();
    super.dispose();
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
          usedWords = res["usedWords"] ?? [];
          previousWord = res["previousWord"];
          isGameOver = res["isGameOver"];
        });

        if (isMyTurn != isMyTurnNotifier.value) {
          isMyTurnNotifier.value = isMyTurn;
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
    skippedTurn = true;
    await ApiService.getSkipTurn(lobbyID);
    
    debugPrint("Skipped player ${turnOrder[0]['username']}");

    if (isMyTurnNotifier.value) {
      _startLocalTimer();
    }
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

      // query if the user is still the first in the turnOrder reset the timer
      if(_countdownTimer?.isActive == true) {
        _countdownTimer?.cancel();
        timeRemaining = 0;

        if (isMyTurnNotifier.value) {
          skippedTurn == true;
          _startLocalTimer();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text("Digitale Wortkette zum Thema: $chosenSubject",
          style: AppTheme.lightTheme.textTheme.bodyLarge),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
                        color: isActive ? AppTheme.lightTheme.colorScheme.secondary : Colors.grey.shade300,//Theme.of(context).colorScheme.primary : Colors.grey.shade300, 
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        player['username'] ?? '',
                        style: TextStyle(color: isActive ? Colors.grey.shade50 : Colors.black),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Timer + Current Player
              SizedBox(
                width: 160,
                height: 60,
                child: SquareProgressIndicator(
                  value: timeRemaining / 30, // Assuming 30s turns
                  strokeWidth: 10,
                  emptyStrokeColor: Colors.grey.shade300,
                  color: AppTheme.lightTheme.colorScheme.secondary,
                  child: Center(
                    child: Text(
                      timeRemaining <= 0 ? "Übersprungen" : "${timeRemaining}s bis Überspringen",
                      textAlign: TextAlign.center,
                      style: AppTheme.lightTheme.textTheme.bodyMedium,
                    ),
                  ),
                ),    
              ),

              const SizedBox(height: 20),

              // Current Letter Hint
              if (currentLetter.isNotEmpty)
                RichText(
                  text: TextSpan(
                    style: AppTheme.lightTheme.textTheme.bodyLarge,
                    children: [
                      const TextSpan(text: "Nächstes Wort beginnt mit: "),
                      TextSpan(
                        text: currentLetter,
                        style: TextStyle(color: AppTheme.lightTheme.colorScheme.primary),
                      ),
                    ],
                  ),
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
                RichText(
                  text: TextSpan(
                    style: AppTheme.lightTheme.textTheme.bodyLarge,
                    children: [
                      const TextSpan(text: "Letztes Wort: "),
                      TextSpan(
                        text: previousWord!['wordUsed'],
                        style: TextStyle(color: AppTheme.lightTheme.colorScheme.secondary),
                      ),
                      const TextSpan(text: " von "),
                      TextSpan(
                        text: previousWord!['username'],
                        style: TextStyle(color: AppTheme.lightTheme.colorScheme.primary),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              // Used Words List
              // TODO: here needs the size and the layout to be tweaked
              SizedBox(
                height: 300,
                child: ListView.builder(
                  reverse: true,
                  itemCount: usedWords.length,
                  itemBuilder: (context, index) {
                    final word = usedWords[usedWords.length - 1 - index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Text(
                            word['word'],
                            style: AppTheme.lightTheme.textTheme.bodyLarge,
                          ),
                          Spacer(), // pushes username to the right
                          Text(
                            word['username'],
                            style: AppTheme.lightTheme.textTheme.bodyLarge,
                          ),
                        ],
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