import 'package:flutter/material.dart';
import 'package:flutter_frontend/services/api_service.dart';
import '../factories/screen_factory.dart';
import '../services/navigation.dart';
import '../utils/theme/app_theme.dart';
import '../utils/theme/ranklist_themes.dart';

// Widget Imports
import '../Widgets/footer_nav_bar.dart';
import '../Widgets/rankslistitem.dart';
import '../Widgets/custom_scaffold.dart';
import '../Widgets/build_achievement_text.dart';

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

    wordsPerPlayer = List<dynamic>.from(data["wordsPerPlayer"]);

    mostWordsPlayers = data["mostWordsPlayers"];
    totalWords = data["totalWords"];
    shortestWords = data["shortestWords"];
    longestWords = data["longestWords"];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Ergebnis')
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
                    // Insgesamte Anzahl der Worte
                    TextSpan(text: 'Es wurden: $totalWords Wörter gefunden.\n\n'),

                    TextSpan(
                      text: 'Rangliste der Spieler mit den Meisten Punkten: ',
                      style: AppTheme.lightTheme.textTheme.bodyLarge
                    ),
                  ],
                ),
              ),

              Column(
                children:[
                  //header which shows (Rang    Nutzername      Punkte)
                  buildHeader(AppTheme.lightTheme.textTheme.bodySmall),

                  //Rangliste der besten Spieler
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 300),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
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
                ],
              ),

              RichText(
                text: TextSpan(
                  style: AppTheme.lightTheme.textTheme.bodyLarge,
                  children: [
                    TextSpan(text: 'Diese Erfolge wurden gesammelt:\n\n'),

                    // Längstes Wort in der Runde
                    buildAchievementText(
                      players: longestWords,
                      singularPrefix: 'Das längste Wort wurde von\n',
                      pluralPrefix: 'Die längsten Wörter wurden von\n',
                      suffix: ' eingegeben.\n\n',
                      highlightStyle: TextStyle(color: AppTheme.lightTheme.colorScheme.primary),
                    ),

                    // Shortest Word from user
                    buildAchievementText(
                      players: shortestWords,
                      singularPrefix: 'Das kürzeste Wort wurde von\n',
                      pluralPrefix: 'Die kürzesten Wörter wurden von\n',
                      suffix: ' eingegeben.\n\n',
                      highlightStyle: TextStyle(color: AppTheme.lightTheme.colorScheme.primary),
                    ),

                    //mostWordsPlayers
                    buildAchievementText(
                      players: mostWordsPlayers,
                      singularPrefix: 'Die meisten Wörter sind\n',
                      pluralPrefix: 'Die meisten Wörter sind\n',
                      suffix: ' eingefallen.',
                      highlightStyle: TextStyle(color: AppTheme.lightTheme.colorScheme.primary),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Button um zur homepage zurückzukehren
              ButtonCentered(
                label: 'Zurück zur Startseite',
                icon: Icons.home,
                onPressed: () => {
                  ApiService.leaveGame(LobbySession.lobbyID!, LobbySession.userID!, LobbySession.hostID!),
                  LobbySession.clear(),
                  NavigationService.goHome(context)
                }, // Calls function to create and navigate to new game
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