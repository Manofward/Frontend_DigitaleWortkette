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

class _GameScreenState extends State<GameScreen>{
  int get lobbyID => widget.lobbyData['lobbyID'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Game Screen - Lobby $lobbyID', style: AppTheme.lightTheme.textTheme.bodyLarge)),
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
}