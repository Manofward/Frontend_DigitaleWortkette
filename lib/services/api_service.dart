import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:5000';

  static Future<dynamic> get(String endpoint) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$endpoint'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint('GET $endpoint failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('GET request error: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint('POST $endpoint failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('POST request error: $e');
    }
    return null;
  }

  // --------------------------
  // 1. Homepage
  // --------------------------
  static Future<List<dynamic>?> homepageGet() async {
    //return await get('home');
    return [
      {"lobbyID": "1", "topic": "Tiere", "players": 3},
      {"lobbyID": "2", "topic": "Städte", "players": 5},
      {"lobbyID": "3", "topic": "Filme", "players": 2},
      {"lobbyID": "4", "topic": "Technik", "players": 4}
    ];
  }

  // --------------------------
  // 2. Host Lobby
  // --------------------------
  static Future<Map<String, dynamic>?> createLobbyPost({
    required String chosenSubjectName,
    required int chosenGameLength,
    required int chosenMaxPlayer,
  }) async {
    //return await post('host-lobby', {
    //   'chosenSubjectName': chosenSubjectName,
    //   'chosenGameLength': chosenGameLength,
    //   'chosenMaxPlayer': chosenMaxPlayer,
    //});

    return {
      "lobbyID": 42,
      "subjects": [
        {"name": "Tiere", "icon": "🐶"},
        {"name": "Städte", "icon": "🌆"},
        {"name": "Filme", "icon": "🎬"},
      ],
      "maxPlayers": chosenMaxPlayer,
      "maxGameLength": chosenGameLength,
      "generatedQRCode": "https://example.com/qr/lobby42",
    };
  }

  // wierd code that isnt used
  /*static Future<Map<String, dynamic>?> getHostLobby(int lobbyId) async {
    //return await get('host-lobby/$lobbyId');
    return {
      "lobbyId": lobbyId,
      "subject": "Tiere",
      "players": 4,
      "maxPlayers": 6,
    };
  }*/

  static Future<Map<String, dynamic>?> getHostLobbyPlayers(int lobbyId) async {
    //return await get('host-lobby/$lobbyId/players');
    return {
      "players": [
        {"username": "Alice", "readyPlayer": true},
        {"username": "Bob", "readyPlayer": false},
        {"username": "Charlie", "readyPlayer": true},
      ]
    };
  }

  static Future<Map<String, dynamic>?> getHostLobbyOptions(int lobbyId) async {
    //return await get('host-lobby/$lobbyId/options');
    return {
      "availableSubjects": ["Tiere", "Städte", "Filme"],
      "availableMaxPlayers": [2, 4, 6, 8],
      "availableGameLengths": [5, 10, 15],
    };
  }

  static Future<void> updateHostLobbySetting(int lobbyId, Map<String, dynamic> data) async {
    //await post('host-lobby/$lobbyId/update', data);
    debugPrint('Dummy updateHostLobbySetting called with $data');
  }

  // --------------------------
  // 3. Join Lobby
  // --------------------------
  static Future<Map<String, dynamic>?> getJoinLobby(String code) async {
    //return await get('join-lobby/$code');
    return {
      "lobbyID": code,
      "subject": "Tiere",
      "players": [
        {"username": "Alice", "ready": true},
        {"username": "Bob", "ready": false},
      ],
      "maxPlayers": 6,
    };
  }

  static Future<Map<String, dynamic>?> postJoinLobby(String code, String username, bool ready) async {
    //return await post('join-lobby/$code', {'username': username, 'ready': ready});
    return {"joined": true, "username": username, "ready": ready};
  }

  // --------------------------
  // 4. Waiting Room
  // --------------------------
  static Future<Map<String, dynamic>?> getLobby(String code) async {
    //return await get('lobby/$code');
    return {
      "lobbyID": code,
      "subject": "Städte",
      "players": ["Alice", "Bob", "Charlie"],
      "readyPlayers": 2,
      "maxPlayers": 6,
    };
  }

  // --------------------------
  // 5. Start Game
  // --------------------------
  static Future<Map<String, dynamic>?> startGame(String code, String firstLetter) async {
    //return await post('start-game/$code', {'startGame': true, 'firstLetter': firstLetter});
    return {"started": true, "firstLetter": firstLetter, "code": code};
  }

  // --------------------------
  // 6. Game
  // --------------------------
  static Future<Map<String, dynamic>?> getGame(String code) async {
    //return await get('game/$code');
    return {
      "round": 3,
      "currentLetter": "B",
      "playerTurn": "Alice",
      "words": ["Ball", "Boot", "Baum"],
    };
  }

  static Future<Map<String, dynamic>?> postWord(String code, String wordInput) async {
    //return await post('game/$code', {'wordInput': wordInput});
    return {
      "accepted": true,
      "newLetter": wordInput.characters.last.toUpperCase(),
      "nextPlayer": "Bob",
    };
  }

  static Future<Map<String, dynamic>?> postPlayerStatus(String code, String status) async {
    //return await post('game/$code', {'playerStatus': status});
    return {"statusUpdated": true, "playerStatus": status};
  }

  // --------------------------
  // 7. Game State / Word Submit (optional)
  // --------------------------
  static Future<Map<String, dynamic>?> getGameState(String code) async {
    //return await get('api/game-state/$code');
    return {
      "round": 2,
      "letter": "A",
      "activePlayer": "Charlie",
      "submittedWords": ["Apfel", "Ameise"],
    };
  }

  static Future<Map<String, dynamic>?> submitWord(String code, String word) async {
    //return await post('api/submit-word/$code', {'wordInput': word});
    return {"accepted": true, "word": word};
  }

  // --------------------------
  // 8. Results
  // --------------------------
  static Future<Map<String, dynamic>?> getResults(String code) async {
    //return await get('results/$code');
    return {
      "winner": "Alice",
      "scoreboard": [
        {"username": "Alice", "points": 12},
        {"username": "Bob", "points": 9},
        {"username": "Charlie", "points": 8},
      ]
    };
  }

  // --------------------------
  // 9. Manual
  // --------------------------
  static Future<Map<String, dynamic>?> getManual() async {
    //return await get('manual');
    return {
      "sections": [
        {"title": "Einleitung", "content": "Willkommen zur Digitalen Wortkette!"},
        {"title": "Regeln", "content": "Bilde ein Wort mit dem letzten Buchstaben des vorherigen."},
        {"title": "Spielende", "content": "Das Spiel endet, wenn niemand mehr ein Wort findet."},
      ]
    };
  }
}