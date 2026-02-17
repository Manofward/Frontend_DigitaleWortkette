# Game Screen Error Handling Guide

This guide covers adding robust error handling to the game screen (`lib/screens/game.dart`) of your Flutter app. The game screen involves real-time interactions, state management, and user inputs, making error handling crucial for maintaining game integrity and user experience.

## Common Error Scenarios

1. **State Management Errors**: Issues with game state updates or invalid state transitions.
2. **Timer Errors**: Problems with the game timer or turn management.
3. **User Input Validation Errors**: Invalid words or unexpected input formats.
4. **Network Errors**: Failures in real-time game updates or synchronization.
5. **UI Rendering Errors**: Problems with widget building during dynamic content changes.

## Best Practices

- Validate user inputs before processing.
- Handle timer exceptions gracefully.
- Provide clear feedback for invalid actions.
- Implement state recovery mechanisms.
- Use try-catch blocks around critical game logic.
- Log errors without disrupting gameplay.

## Code Examples

### 1. Enhanced GameScreen with Error Handling

**Before:**
```dart
class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late final int lobbyID;
  late AnimationController _timerController;
  final int turnDurationSeconds = 30;

  // Mock game state
  final String localPlayer = "Player1";
  final List<String> turnOrder = ["Player1", "Player2", "Player3"];
  String currentPlayer = "Player1";
  String? lastWord;

  final TextEditingController _wordController = TextEditingController();
  final List<Map<String, dynamic>> usedWords = [];
  bool get isMyTurn => currentPlayer == localPlayer;

  @override
  void initState() {
    super.initState();
    lobbyID = widget.lobbyData["lobbyID"];
    _timerController = AnimationController(
      vsync: this,
      duration: Duration(seconds: turnDurationSeconds),
    )..forward();
  }

  @override
  void dispose() {
    _timerController.dispose();
    _wordController.dispose();
    super.dispose();
  }

  bool _isValidWord(String word) {
    if (lastWord == null) return true;
    return word[0].toLowerCase() ==
        lastWord!.characters.last.toLowerCase();
  }

  void _nextPlayer() {
    final currentIndex = turnOrder.indexOf(currentPlayer);
    currentPlayer =
        turnOrder[(currentIndex + 1) % turnOrder.length];
    _timerController
      ..reset()
      ..forward();
  }

  void _submitWord() {
    final word = _wordController.text.trim();
    if (word.isEmpty || !isMyTurn) return;

    final isValid = _isValidWord(word);

    setState(() {
      usedWords.insert(0, {
        "user": currentPlayer,
        "word": word,
        "isValid": isValid,
      });

      if (isValid) {
        lastWord = word;
        _nextPlayer();
      }

      _wordController.clear();
    });
  }
```

**After:**
```dart
class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late final int lobbyID;
  late AnimationController _timerController;
  final int turnDurationSeconds = 30;

  // Mock game state
  final String localPlayer = "Player1";
  final List<String> turnOrder = ["Player1", "Player2", "Player3"];
  String currentPlayer = "Player1";
  String? lastWord;

  final TextEditingController _wordController = TextEditingController();
  final List<Map<String, dynamic>> usedWords = [];

  bool get isMyTurn => currentPlayer == localPlayer;

  // Error handling state
  String? _errorMessage;
  bool _isSubmittingWord = false;

  @override
  void initState() {
    super.initState();
    try {
      lobbyID = widget.lobbyData["lobbyID"] ?? 0;
      if (lobbyID == 0) {
        throw ArgumentError('Invalid lobbyID');
      }

      _timerController = AnimationController(
        vsync: this,
        duration: Duration(seconds: turnDurationSeconds),
      )..forward();

      // Add error listener to timer
      _timerController.addStatusListener(_onTimerStatusChanged);
    } catch (e) {
      debugPrint('Error initializing game screen: $e');
      _errorMessage = 'Fehler beim Initialisieren des Spiels';
    }
  }

  @override
  void dispose() {
    _timerController.dispose();
    _wordController.dispose();
    super.dispose();
  }

  void _onTimerStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      try {
        _handleTurnTimeout();
      } catch (e) {
        debugPrint('Error handling turn timeout: $e');
        _showError('Fehler beim Wechseln des Spielers');
      }
    }
  }

  void _handleTurnTimeout() {
    if (!mounted) return;

    setState(() {
      _nextPlayer();
    });
  }

  bool _isValidWord(String word) {
    try {
      if (word.isEmpty) return false;
      if (lastWord == null) return true;

      final lastChar = lastWord!.characters.last.toLowerCase();
      final firstChar = word.characters.first.toLowerCase();

      return firstChar == lastChar;
    } catch (e) {
      debugPrint('Error validating word: $e');
      return false;
    }
  }

  void _nextPlayer() {
    try {
      final currentIndex = turnOrder.indexOf(currentPlayer);
      if (currentIndex == -1) {
        throw StateError('Current player not found in turn order');
      }

      currentPlayer = turnOrder[(currentIndex + 1) % turnOrder.length];

      _timerController
        ..reset()
        ..forward();
    } catch (e) {
      debugPrint('Error switching to next player: $e');
      _showError('Fehler beim Wechseln des Spielers');
    }
  }

  void _submitWord() {
    if (_isSubmittingWord || !isMyTurn) return;

    final word = _wordController.text.trim();
    if (word.isEmpty) {
      _showError('Bitte geben Sie ein Wort ein');
      return;
    }

    setState(() => _isSubmittingWord = true);

    try {
      final isValid = _isValidWord(word);

      if (!isValid) {
        _showError('Das Wort muss mit dem letzten Buchstaben beginnen');
        setState(() => _isSubmittingWord = false);
        return;
      }

      // Check for duplicate words
      final isDuplicate = usedWords.any((entry) =>
          entry["word"].toString().toLowerCase() == word.toLowerCase());

      if (isDuplicate) {
        _showError('Dieses Wort wurde bereits verwendet');
        setState(() => _isSubmittingWord = false);
        return;
      }

      setState(() {
        usedWords.insert(0, {
          "user": currentPlayer,
          "word": word,
          "isValid": true,
        });

        lastWord = word;
        _nextPlayer();
        _wordController.clear();
        _isSubmittingWord = false;
      });
    } catch (e) {
      debugPrint('Error submitting word: $e');
      _showError('Fehler beim Übermitteln des Wortes');
      setState(() => _isSubmittingWord = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    setState(() => _errorMessage = message);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );

    // Clear error after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _errorMessage = null);
      }
    });
  }
```

### 2. Enhanced Build Method with Error Handling

```dart
@override
Widget build(BuildContext context) {
  // Show error screen if initialization failed
  if (_errorMessage != null && usedWords.isEmpty) {
    return Scaffold(
      appBar: AppBar(title: const Text("Spiel Fehler")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Zurück'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  return Scaffold(
    appBar: AppBar(
      title: Text(
        "Digitale Wortkette zum Thema: subject",
        style: AppTheme.lightTheme.textTheme.bodyLarge,
      ),
    ),
    body: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          /// TURN ORDER
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: turnOrder.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (_, index) {
                try {
                  final player = turnOrder[index];
                  final isActive = player == currentPlayer;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      player,
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.black,
                      ),
                    ),
                  );
                } catch (e) {
                  debugPrint('Error building turn order item $index: $e');
                  return const SizedBox.shrink();
                }
              },
            ),
          ),

          const SizedBox(height: 20),

          /// TIMER + PLAYER
          SizedBox(
            width: 160,
            height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _timerController,
                  builder: (_, child) {
                    try {
                      final remaining =
                          (turnDurationSeconds *
                                  (1 - _timerController.value))
                              .ceil();

                      final isDanger = remaining <= 5;

                      return CircularProgressIndicator(
                        value: 1 - _timerController.value,
                        strokeWidth: 10,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation(
                          isDanger ? Colors.red : Colors.green,
                        ),
                      );
                    } catch (e) {
                      debugPrint('Error building timer: $e');
                      return const CircularProgressIndicator();
                    }
                  },
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        currentPlayer,
                        key: ValueKey(currentPlayer),
                        style: AppTheme.lightTheme.textTheme.bodyLarge,
                      ),
                    ),
                    const SizedBox(height: 6),
                    AnimatedBuilder(
                      animation: _timerController,
                      builder: (_, child) {
                        try {
                          final remaining =
                              (turnDurationSeconds *
                                      (1 - _timerController.value))
                                  .ceil();
                          return Text(
                            "$remaining s",
                            style: AppTheme.lightTheme.textTheme.bodyMedium,
                          );
                        } catch (e) {
                          return const Text("Error");
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          /// WORD INPUT
          TextField(
            controller: _wordController,
            enabled: isMyTurn && !_isSubmittingWord,
            onSubmitted: (_) => _submitWord(),
            decoration: InputDecoration(
              labelText: _isSubmittingWord
                  ? "Übermitteln..."
                  : (isMyTurn
                      ? "Geben Sie Ihr Wort ein"
                      : "Warten auf $currentPlayer"),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.send),
                onPressed: (isMyTurn && !_isSubmittingWord) ? _submitWord : null,
              ),
            ),
          ),

          // Show current error if any
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),

          const SizedBox(height: 20),

          /// USED WORDS LIST
          Expanded(
            child: ListView.builder(
              reverse: false,
              itemCount: usedWords.length,
              itemBuilder: (context, index) {
                try {
                  final entry = usedWords[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      "${entry["user"]} sagt: ${entry["word"]}",
                      style: TextStyle(
                        color: entry["isValid"] == true
                            ? Theme.of(context).colorScheme.primary
                            : Colors.red,
                        fontWeight: entry["isValid"] == true
                            ? FontWeight.normal
                            : FontWeight.bold,
                      ),
                    ),
                  );
                } catch (e) {
                  debugPrint('Error building word entry $index: $e');
                  return const ListTile(
                    title: Text('Fehler beim Laden des Wortes'),
                  );
                }
              },
            ),
          ),
        ],
      ),
    ),
    bottomNavigationBar: FooterNavigationBar(
      screenType: ScreenType.game,
      onButtonPressed: (type) => _handleFooterButtonWithError(context, type),
    ),
  );
}

Future<void> _handleFooterButtonWithError(BuildContext context, FooterButtonType type) async {
  try {
    await handleFooterButton(context, type);
  } catch (e) {
    debugPrint('Error handling footer button in game: $e');
    _showError('Navigation fehlgeschlagen');
  }
}
```

### 3. Game State Recovery Mechanism

Add a method to recover from corrupted game states:

```dart
void _recoverGameState() {
  try {
    // Validate current state
    if (!turnOrder.contains(currentPlayer)) {
      debugPrint('Invalid currentPlayer, resetting to first player');
      currentPlayer = turnOrder.first;
    }

    if (lastWord != null && lastWord!.isEmpty) {
      lastWord = null;
    }

    // Validate used words
    usedWords.removeWhere((entry) {
      final word = entry["word"]?.toString() ?? '';
      final user = entry["user"]?.toString() ?? '';
      final isValid = entry["isValid"] ?? false;

      if (word.isEmpty || user.isEmpty) {
        debugPrint('Removing invalid word entry: $entry');
        return true;
      }

      return false;
    });

    // Reset timer if needed
    if (_timerController.isCompleted || _timerController.isDismissed) {
      _timerController.reset();
      _timerController.forward();
    }

    setState(() {});
  } catch (e) {
    debugPrint('Error recovering game state: $e');
    _showError('Fehler beim Wiederherstellen des Spielstands');
  }
}
```

## Conclusion

Implementing error handling in your game screen ensures:

- Robust game state management
- Graceful handling of invalid user inputs
- Recovery from timer and animation errors
- Clear user feedback for game-related errors
- Prevention of crashes during gameplay

Remember to thoroughly test error scenarios, including network disconnections, invalid game states, and unexpected user inputs. Use logging to track errors in production while keeping the game experience smooth for users.
