// i need here to talk with david as to how i get the userID from the backend
// need to add fontsizes
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/navigation.dart';
import '../../factories/screen_factory.dart';
import '../services/polling/poll_manager.dart';
import '../Widgets/pop_leave_game.dart';
import '../Widgets/footer_nav_bar.dart';

import'../utils/theme/app_theme.dart';
import '../utils/get_username.dart';

class JoinLobbyPage extends StatefulWidget {
  final Map<String, dynamic> lobbyData;
  const JoinLobbyPage({super.key, required this.lobbyData});

  @override
  State<JoinLobbyPage> createState() => _JoinLobbyPageState();
}

class _JoinLobbyPageState extends State<JoinLobbyPage> {
  // Backend data
  String chosenSubjectName = "";
  String chosenMaxPlayers = "";
  String chosenMaxGameLength = "";
  List<dynamic> players = [];

  // Local player settings
  bool ready = false;
  String username = getUsername();
  late int hostID = 0;
  late int userID = 0;// this line is the try to change the username unique key to IDs 

  // Controller ONLY for our own username
  late TextEditingController _myUsernameController;

  int get lobbyID => widget.lobbyData['lobbyID'];

  @override
  void initState() {
    super.initState();

    _myUsernameController = TextEditingController(text: username);

    _sendPlayerJoin();

    // --- Poll lobby settings ---
    PollManager.startPolling(
      interval: const Duration(seconds: 3),
      task: () => ApiService.getLobby(lobbyID),
      onUpdate: (res) {
        if (!mounted || res == null) return;

        setState(() {
          chosenSubjectName = res["chosenSubjectName"];
          chosenMaxPlayers = res["chosenMaxPlayers"];
          chosenMaxGameLength = res["chosenMaxGameLength"];
        });
      },
    );

    // --- Poll player list ---
    PollManager.startPolling(
      interval: const Duration(seconds: 3),
      task: () => ApiService.getLobbyPlayers(lobbyID),
      onUpdate: (res) {
        if (!mounted || res == null) return;

        setState(() => players = res);

        // Auto-start if all ready
        if (players.isNotEmpty && players.every((p) => p['ready'] == true)) {
          NavigationService.navigate(
            context,
            ScreenType.game,
            arguments: {'lobbyID': lobbyID},
          );
        }
      },
    );
  }

  Future<void> _sendPlayerJoin() async {
    if (username.isEmpty) return;

    final res = await ApiService.postJoinLobby(lobbyID, userID, hostID, username, ready); // try to change the username unique keys to IDs

    if (userID == 0 && res["userID"] != null) {
      setState(() => userID = res["userID"]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope( // PopScope for adding poping alerts
      canPop: false,
      onPopInvoked: LeaveLobby.onPopInvoked(
        context: context,
        lobbyID: lobbyID,
        userID: userID,
        hostID: hostID, // vieleicht zu host und user id einzeln machen
      ),
      // this is the normal join lobby part
      child: Scaffold(
        appBar: AppBar(title: Text("Lobby #$lobbyID", 
                       style: AppTheme.lightTheme.textTheme.headlineLarge?.copyWith(color: AppTheme.lightTheme.colorScheme.onSurface)),
                      ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Richtext for the lobby Data
              RichText(
                text: TextSpan(
                  style: AppTheme.lightTheme.textTheme.titleLarge, // general font size of the Lobby Data
                  children: <TextSpan>[
                    // subject
                    const TextSpan(text: "Thema: "),
                    TextSpan(
                      text: chosenSubjectName, // should show the subject text
                      style: TextStyle(
                        color: AppTheme.lightTheme.colorScheme.primary//Colors.orange[900],
                      ),
                    ),
                    TextSpan(text:"\n"),

                    // Max Game Length
                    const TextSpan(text: "Spielzeit: "),
                    TextSpan(
                      text: "$chosenMaxGameLength Minuten",
                      style: TextStyle(
                        color: AppTheme.lightTheme.colorScheme.primary
                      ),
                    ),
                    TextSpan(text: "\n"),

                    // max players
                    const TextSpan(text: "Max Spieler: "),
                    TextSpan(
                      text: chosenMaxPlayers, 
                      style: TextStyle(
                        color: AppTheme.lightTheme.colorScheme.primary
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              Text("Spieler:", style: AppTheme.lightTheme.textTheme.bodyLarge),

              Expanded(
                child: ListView(
                  children: players.map((p) {
                    final bool isMe = p["userID"] == userID;
                    final bool isReady = p["isPlayerReady"] == "true";

                    if (isMe) {
                      // --- LOCAL PLAYER ROW (editable) ---
                      return ListTile(
                        title: TextField(
                          enabled: !isReady,
                          controller: _myUsernameController,
                          decoration: InputDecoration(
                            labelText: "Dein Benutzername",
                            labelStyle: AppTheme.lightTheme.textTheme.bodySmall,
                          ),
                          style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(color: AppTheme.lightTheme.colorScheme.primary),
                          onChanged: (v) {
                            username = v;
                          },
                        ),
                        // need to edit the size here (i dont know if everything is alright as of now because of the broken backend)
                        trailing: SizedBox(
                          width: 65,
                          height: 50,
                          child: FittedBox(
                            fit: BoxFit.fill,
                            child: Switch(
                              value: isReady,
                              onChanged: (v) {
                                setState(() {
                                  ready = v;
                                });
                                _sendPlayerJoin();
                              },
                            ),
                          ),
                        ),
                      );
                    }

                    // --- OTHER PLAYER ROW (read only) ---
                    return ListTile(
                      title: Text(p["username"], style: AppTheme.lightTheme.textTheme.bodyLarge),
                      trailing: Icon(
                        isReady ? Icons.check_circle : Icons.cancel,
                        color: isReady ? Colors.green : Colors.red,
                        size: 32,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: FooterNavigationBar(
          screenType: ScreenType.home,
          onButtonPressed: (type) => handleFooterButton(context, type),
        ),
      )
    );
  }
}