/*import 'package:flutter/material.dart';
import '../services/navigation.dart';
import '../factories/screen_factory.dart';
import '../Widgets/footer_nav_bar.dart';
import '../utils/theme/app_theme.dart';

class GameScreen extends StatefulWidget {
  final Map<String, dynamic> lobbyData;

  const GameScreen({super.key, required this.lobbyData});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>{
  late final int lobbyID;

  @override
  void initState() {
    super.initState();

    final data = widget.lobbyData;
    lobbyID = data["lobbyID"];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Game Screen - Lobby $lobbyID", style: AppTheme.lightTheme.textTheme.bodyLarge)),
      body: Padding(
        padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Richtext for the lobby Data
              RichText(
                text: TextSpan(
                style: AppTheme.lightTheme.textTheme.bodyLarge, // general font size of the Lobby Data
                children: [
                  // Max Game Length
                  TextSpan(
                    text: "Hier soll später die Ziet in Minuten angezeigt werden die im Spiel übrig sind.",
                    style: TextStyle(
                      color: AppTheme.lightTheme.colorScheme.primary
                    ),
                  ),
                  TextSpan(text: "\n"),

                  // here should also be a list which users are in which order in the game as a list.
                ],
              ),
            ),

            // here should be a List shown with the following format: "$username sagt: $inputWord" 
            //(the word should here be in the following color the last letter of the said word has to be the same as the next words beginning letter)
          ]
        ),
      ),
      // here has to be made a Text field for the Input of the words like a normal chat program
      /*TextField(
        autocorrect: true,
        decoration: InputDecoration(
          label: Text("Bitte gebe ein Wort ein."),
          labelStyle: AppTheme.lightTheme.textTheme.bodySmall,
        ),
      ),*/

      bottomNavigationBar: FooterNavigationBar(
        screenType: ScreenType.game,
        onButtonPressed: (type) => handleFooterButton(context, type),
      ),
    );
  }
}*/



import 'package:flutter/material.dart';
import '../services/navigation.dart';
import '../factories/screen_factory.dart';
import '../Widgets/footer_nav_bar.dart';
import '../utils/theme/app_theme.dart';

class GameScreen extends StatefulWidget {
  final Map<String, dynamic> lobbyData;

  const GameScreen({super.key, required this.lobbyData});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late final int lobbyID;

  // Timer animation
  late AnimationController _timerController;
  final int turnDurationSeconds = 30;

  // Mock game state
  final String localPlayer = "Player1"; // your player
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Game Screen - Lobby $lobbyID",
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
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, index) {
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
                    builder: (_, __) {
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
                          style:
                              AppTheme.lightTheme.textTheme.bodyLarge,
                        ),
                      ),
                      const SizedBox(height: 6),
                      AnimatedBuilder(
                        animation: _timerController,
                        builder: (_, __) {
                          final remaining =
                              (turnDurationSeconds *
                                      (1 - _timerController.value))
                                  .ceil();
                          return Text(
                            "$remaining s",
                            style:
                                AppTheme.lightTheme.textTheme.bodyMedium,
                          );
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
              enabled: isMyTurn,
              onSubmitted: (_) => _submitWord(),
              decoration: InputDecoration(
                labelText: isMyTurn
                    ? "Enter your word"
                    : "Waiting for $currentPlayer",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: isMyTurn ? _submitWord : null,
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// USED WORDS LIST
            Expanded(
              child: ListView.builder(
                reverse: false,
                itemCount: usedWords.length,
                itemBuilder: (context, index) {
                  final entry = usedWords[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      "${entry["user"]} says: ${entry["word"]}",
                      style: TextStyle(
                        color: entry["isValid"]
                            ? Theme.of(context)
                                .colorScheme
                                .primary
                            : Colors.red,
                        fontWeight: entry["isValid"]
                            ? FontWeight.normal
                            : FontWeight.bold,
                      ),
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
        onButtonPressed: (type) =>
            handleFooterButton(context, type),
      ),
    );
  }
}