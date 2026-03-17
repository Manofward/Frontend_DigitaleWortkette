import 'package:flutter/material.dart';
import '../factories/screen_factory.dart';
import '../services/navigation.dart';
import '../Widgets/footer_nav_bar.dart';
import '../utils/theme/app_theme.dart';
import '../utils/theme/ranklist_themes.dart';
import '../Widgets/rankslistitem.dart';

class ResultScreen extends StatefulWidget {
  final Map<String, dynamic> lobbyData;

  const ResultScreen({super.key, required this.lobbyData});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late final int lobbyID;
  int? localUserID = LobbySession.userID;

  List<dynamic> wordsPerPlayer = [];

  late List<dynamic> mostWordsPlayers;
  late List<dynamic> shortestWords;
  late int totalWords;
  late List<dynamic> longestWords;

  @override
  void initState() {
    super.initState();

    final data = widget.lobbyData;
    mostWordsPlayers = data["mostWordsPlayers"];
    totalWords = data["totalWords"];
    longestWords = data["longestWords"];
    shortestWords = data["shortestWords"];

    wordsPerPlayer = List<dynamic>.from(data["wordsPerPlayer"]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Ergebniss')
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Ranglist Spieler Überschrift
              RichText(
                text: TextSpan(
                  style: AppTheme.lightTheme.textTheme.bodyLarge,
                  children: [
                    TextSpan(
                      text: 'Rangliste der Spieler mit den Meisten Punkten: ',
                      style: AppTheme.lightTheme.textTheme.bodyLarge
                    ),
                  ],
                ),
              ),

              //Rangliste der besten Spieler
              SizedBox(
                height: 300,
                child: ListView.builder(
                  //reverse: true,
                  itemCount: wordsPerPlayer.length,
                  itemBuilder: (context, index) {
                    final countPoints = wordsPerPlayer[wordsPerPlayer.length - 1 - index];

                    /*This sets the style of the ranklist so that the following is:
                      first player has golden color
                      second player has silver
                      third player has bronze
                      the rest players have a default
                    */
                    final style = index < RanklistThemes.rankStyles.length
                        ? RanklistThemes.rankStyles[index]
                        : RanklistThemes.defaultStyle;

                    return RankListItem(
                      rank: index + 1,
                      username: countPoints['username'],
                      points: countPoints['count'],
                      style: style,
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              RichText(
                text: TextSpan(
                  style: AppTheme.lightTheme.textTheme.bodyLarge,
                  children: [
                    // Insgesamte Anzahl der Worte
                    TextSpan(text: 'Es wurden: $totalWords Wörter gefunden.\n'),

                    TextSpan(text: 'Davon hatten diese Spieler Erfolge:\n\n'),

                    // Längstes Wort in der Runde
                    // Muss vom backend noch den Usernamen bekommen
                    const TextSpan(text: "Das Längste Wort hatte: "),
                    TextSpan(
                      text: longestWords[0], // ändern zu dem usernamen
                      style: TextStyle(color: AppTheme.lightTheme.colorScheme.primary),
                    ),

                    const TextSpan(text: '\n\n'),

                    // Shortest Word from user
                    const TextSpan(text: 'Das kürzeste Wort hatte: '),
                    TextSpan(
                      text: shortestWords[0],
                      style: TextStyle(color: AppTheme.lightTheme.colorScheme.primary),
                    ),

                    const TextSpan(text: '\n\n'),

                    //mostWordsPlayers
                    const TextSpan(text: 'Die meisten Wörter sind '),
                    TextSpan(
                      text: mostWordsPlayers[0],
                      style: TextStyle(color: AppTheme.lightTheme.colorScheme.primary),
                    ),
                    const TextSpan(text: ' eingefallen.'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      // usage of the footer bar
      bottomNavigationBar: FooterNavigationBar (
        screenType: ScreenType.results,
        onButtonPressed: (type) => handleFooterButton(context, type),
      ),
    );
  }
}